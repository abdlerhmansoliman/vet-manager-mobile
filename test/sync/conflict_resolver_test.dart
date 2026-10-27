import 'dart:ffi';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/sync/conflict_resolver.dart';

void main() {
  late AppDatabase db;
  late ConflictResolver resolver;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    resolver = ConflictResolver(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ConflictResolver — Force-Reconcile Protocol', () {
    test('resolvePushAck applied updates entity syncStatus to synced', () async {
      final now = DateTime.now().toUtc();
      const clientId = 'c-100';

      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: clientId,
              tenantId: 'tenant-1',
              name: 'Dr. Jane Watson',
              phonePrimary: '555-0100',
              syncStatus: const Value('pending_create'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      const ack = PushAckResult(
        mutationId: 'mut-1',
        entityType: 'client',
        entityId: clientId,
        status: PushAckStatus.applied,
      );

      await resolver.resolvePushAck(ack);

      final client = await (db.select(db.clientsTable)..where((c) => c.id.equals(clientId))).getSingle();
      expect(client.syncStatus, 'synced');
      expect(client.lastSyncedAt, isNotNull);
    });

    test('resolvePushAck reconciledWithSpillover updates container reference without rolling back dose', () async {
      final now = DateTime.now().toUtc();
      const productId = 'prod-1';
      const batchId = 'batch-1';
      const originalContainerId = 'vial-101';
      const spilloverContainerId = 'vial-202';
      const doseId = 'ledger-dose-1';

      // Insert product and batch
      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'KET-100',
              name: 'Ketamine 100mg/ml',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: batchId,
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-KET-1',
              expiresAt: DateTime(2027, 1, 1),
              initialBaseQty: Decimal.parse('50.0'),
              remainingBaseQty: Decimal.parse('50.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert original vial and spillover vial
      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: originalContainerId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: batchId,
              barcode: 'BAR-VIAL-101',
              initialVolume: Decimal.parse('50.0'),
              remainingBalance: Decimal.parse('50.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: spilloverContainerId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: batchId,
              barcode: 'BAR-VIAL-202',
              initialVolume: Decimal.parse('50.0'),
              remainingBalance: Decimal.parse('50.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Record offline dose from original container
      await db.into(db.inventoryMovementLedgerTable).insert(
            InventoryMovementLedgerTableCompanion.insert(
              id: doseId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: const Value(batchId),
              containerId: const Value(originalContainerId),
              movementType: 'consumed',
              quantity: Decimal.parse('2.5'),
              balanceAfter: Decimal.parse('47.5'),
              idempotencyKey: '018d4f20-8000-7000-8000-000000000001',
              recordedByUserId: 'vet-field-doc',
              createdAt: now,
              syncStatus: const Value('pending_push'),
            ),
          );

      // Server returns reconciled_with_spillover because original vial was depleted concurrently
      const ack = PushAckResult(
        mutationId: 'mut-dose-1',
        entityType: 'inventory_movement_ledger',
        entityId: doseId,
        status: PushAckStatus.reconciledWithSpillover,
        newContainerId: spilloverContainerId,
        message: 'Depleted on server; reattributed to vial-202',
      );

      await resolver.resolvePushAck(ack);

      final updatedLedger = await (db.select(db.inventoryMovementLedgerTable)
            ..where((l) => l.id.equals(doseId)))
          .getSingle();

      // Clinical Invariant: Dose was committed and NOT dropped
      expect(updatedLedger.quantity, Decimal.parse('2.5'));
      expect(updatedLedger.containerId, spilloverContainerId);
      expect(updatedLedger.syncStatus, 'synced');
      expect(updatedLedger.notes, contains('FEFO spillover'));
    });

    test('resolvePushAck discrepancyLogged preserves dose in audit ledger and notes discrepancy alert', () async {
      final now = DateTime.now().toUtc();
      const productId = 'prod-morphine';
      const doseId = 'ledger-dose-discrepant';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'MOR-10',
              name: 'Morphine',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryMovementLedgerTable).insert(
            InventoryMovementLedgerTableCompanion.insert(
              id: doseId,
              tenantId: 'tenant-1',
              productId: productId,
              movementType: 'consumed',
              quantity: Decimal.parse('1.0'),
              balanceAfter: Decimal.parse('0.0'),
              idempotencyKey: '018d4f20-8000-7000-8000-000000000002',
              recordedByUserId: 'vet-field-doc',
              createdAt: now,
              syncStatus: const Value('pending_push'),
            ),
          );

      const ack = PushAckResult(
        mutationId: 'mut-dose-2',
        entityType: 'inventory_movement_ledger',
        entityId: doseId,
        status: PushAckStatus.discrepancyLogged,
        alertRaised: true,
        message: 'No containers available; discrepancy flagged for clinic owner',
      );

      await resolver.resolvePushAck(ack);

      final ledger = await (db.select(db.inventoryMovementLedgerTable)..where((l) => l.id.equals(doseId))).getSingle();

      expect(ledger.syncStatus, 'synced');
      expect(ledger.notes, contains('ALERT: Stock discrepancy flagged'));
    });
  });

  group('ConflictResolver — Inbound Server Deltas & Append-Only Invariants', () {
    test('applyServerDeltas ingests relational records into Drift', () async {
      const tenantId = 'tenant-1';
      final deltas = {
        'clients': [
          {
            'id': 'client-remote-1',
            'name': 'Green Meadow Farm',
            'phone_primary': '555-9000',
            'client_type': 'farm',
            'physical_address': 'Route 4, Box 20',
          }
        ],
        'patients': [
          {
            'id': 'patient-remote-1',
            'client_id': 'client-remote-1',
            'name_or_tag': 'Bessie #402',
            'species': 'Bovine',
            'breed': 'Holstein',
          }
        ],
        'cases': [
          {
            'id': 'case-remote-1',
            'case_number': 'CAS-2026-BOV-1',
            'patient_id': 'patient-remote-1',
            'primary_veterinarian_id': 'vet-large-animal',
            'chief_complaint': 'Post-calving ketosis',
            'priority': 'urgent',
            'status': 'open',
          }
        ],
      };

      await resolver.applyServerDeltas(tenantId: tenantId, deltas: deltas);

      final client = await (db.select(db.clientsTable)..where((c) => c.id.equals('client-remote-1'))).getSingleOrNull();
      final patient = await (db.select(db.patientsTable)..where((p) => p.id.equals('patient-remote-1'))).getSingleOrNull();
      final clinicalCase = await (db.select(db.clinicalCasesTable)..where((c) => c.id.equals('case-remote-1'))).getSingleOrNull();

      expect(client, isNotNull);
      expect(client!.name, 'Green Meadow Farm');
      expect(patient, isNotNull);
      expect(patient!.species, 'Bovine');
      expect(clinicalCase, isNotNull);
      expect(clinicalCase!.chiefComplaint, 'Post-calving ketosis');
    });

    test('applyServerDeltas preserves existing signed progress note without mutation (Append-Only)', () async {
      const tenantId = 'tenant-1';
      final now = DateTime.now().toUtc();
      const noteId = 'signed-soap-note-1';

      // Local doctor signed a SOAP note offline
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'c-1',
              tenantId: tenantId,
              name: 'Owner',
              phonePrimary: '555-1234',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'p-1',
              tenantId: tenantId,
              clientId: 'c-1',
              nameOrTag: 'Max',
              species: 'Canine',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-1',
              tenantId: tenantId,
              caseNumber: 'CAS-1',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-local',
              chiefComplaint: 'Limping',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.clinicalProgressNotesTable).insert(
            ClinicalProgressNotesTableCompanion.insert(
              id: noteId,
              caseId: 'case-1',
              patientId: 'p-1',
              veterinarianId: 'vet-local',
              veterinarianName: 'Dr. Local, DVM',
              subjective: const Value('Original local examination observation'),
              recordedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Inbound delta arrives from server with altered subjective text for the same ID
      final deltas = {
        'progress_notes': [
          {
            'id': noteId,
            'case_id': 'case-1',
            'patient_id': 'p-1',
            'veterinarian_id': 'vet-remote',
            'subjective': 'Tampered or conflicting text',
            'is_signed': true,
          }
        ]
      };

      await resolver.applyServerDeltas(tenantId: tenantId, deltas: deltas);

      final note = await (db.select(db.clinicalProgressNotesTable)..where((n) => n.id.equals(noteId))).getSingle();

      // Clinical Invariant: Signed SOAP notes are NEVER overwritten in place!
      expect(note.subjective, 'Original local examination observation');
      expect(note.veterinarianId, 'vet-local');
    });
  });
}
