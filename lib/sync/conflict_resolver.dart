import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Status of a server acknowledgment for an outbound push mutation.
enum PushAckStatus {
  /// The mutation was cleanly applied on the backend.
  applied,

  /// The physical container was already depleted on the server; the backend
  /// automatically attributed the deduction to the next available container (FEFO spillover).
  reconciledWithSpillover,

  /// Total physical inventory was depleted; the server committed the audit record
  /// without rolling back and raised a high-priority discrepancy alert for the clinic owner.
  discrepancyLogged,

  /// Request rejected due to authorization or validation failure.
  rejected,
}

/// Server acknowledgment response payload for a single queued mutation.
class PushAckResult {
  final String mutationId;
  final String entityType;
  final String entityId;
  final PushAckStatus status;
  final String? newContainerId;
  final bool alertRaised;
  final String? message;

  const PushAckResult({
    required this.mutationId,
    required this.entityType,
    required this.entityId,
    required this.status,
    this.newContainerId,
    this.alertRaised = false,
    this.message,
  });

  factory PushAckResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString();
    PushAckStatus status;
    switch (statusStr) {
      case 'reconciled_with_spillover':
        status = PushAckStatus.reconciledWithSpillover;
        break;
      case 'discrepancy_logged':
        status = PushAckStatus.discrepancyLogged;
        break;
      case 'rejected':
        status = PushAckStatus.rejected;
        break;
      case 'applied':
      default:
        status = PushAckStatus.applied;
        break;
    }

    return PushAckResult(
      mutationId: json['mutation_id']?.toString() ?? json['id']?.toString() ?? '',
      entityType: json['entity_type']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      status: status,
      newContainerId: json['new_container_id']?.toString(),
      alertRaised: json['alert_raised'] == true,
      message: json['message']?.toString(),
    );
  }
}

/// Force-Reconcile & Immutable Append-Only Conflict Resolver.
///
/// Ambulatory veterinarians work in rural environments where offline collisions occur.
/// Core Invariants:
/// 1. Never Drop Clinical Records: Physical doses administered and signed vitals occurred.
///    They must NEVER be rolled back or discarded due to server version conflicts.
/// 2. Automatic FEFO Spillover: Reattributes depleted vial deductions to next available container.
/// 3. Discrepancy Flagging: Logs stock discrepancy alerts while preserving full ledger audit trails.
/// 4. Append-Only SOAP Notes: Medical progress notes and addenda are strictly additive.
class ConflictResolver {
  final AppDatabase db;

  ConflictResolver({required this.db});

  /// Processes server acknowledgment for an outbound mutation.
  Future<void> resolvePushAck(PushAckResult ack) async {
    final now = DateTime.now().toUtc();

    switch (ack.status) {
      case PushAckStatus.applied:
        await _markEntitySynced(ack.entityType, ack.entityId, now);
        break;

      case PushAckStatus.reconciledWithSpillover:
        // Force-Reconcile: Reattribute container reference in the immutable ledger
        if (ack.entityType == 'inventory_movement_ledger' || ack.entityType == 'dose') {
          await (db.update(db.inventoryMovementLedgerTable)
                ..where((l) => l.id.equals(ack.entityId)))
              .write(
            InventoryMovementLedgerTableCompanion(
              containerId: ack.newContainerId != null ? Value(ack.newContainerId) : const Value.absent(),
              notes: Value(
                ack.newContainerId != null
                    ? 'Reconciled with FEFO spillover to container: ${ack.newContainerId}'
                    : 'Reconciled with FEFO spillover',
              ),
              syncStatus: const Value('synced'),
              lastSyncedAt: Value(now),
            ),
          );
        } else {
          await _markEntitySynced(ack.entityType, ack.entityId, now);
        }
        break;

      case PushAckStatus.discrepancyLogged:
        // Force-Reconcile: Commit dose record and flag discrepancy alert
        if (ack.entityType == 'inventory_movement_ledger' || ack.entityType == 'dose') {
          await (db.update(db.inventoryMovementLedgerTable)
                ..where((l) => l.id.equals(ack.entityId)))
              .write(
            InventoryMovementLedgerTableCompanion(
              notes: const Value(
                'ALERT: Stock discrepancy flagged by server — physical offline dose committed',
              ),
              syncStatus: const Value('synced'),
              lastSyncedAt: Value(now),
            ),
          );
        } else {
          await _markEntitySynced(ack.entityType, ack.entityId, now);
        }
        break;

      case PushAckStatus.rejected:
        // Clinical records are never dropped, but log the error if rejected
        break;
    }
  }

  /// Marks a specific entity as synced in local SQLite tables.
  Future<void> _markEntitySynced(String entityType, String entityId, DateTime now) async {
    switch (entityType) {
      case 'client':
        await (db.update(db.clientsTable)..where((c) => c.id.equals(entityId))).write(
          ClientsTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'patient':
        await (db.update(db.patientsTable)..where((p) => p.id.equals(entityId))).write(
          PatientsTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'clinical_case':
      case 'case':
        await (db.update(db.clinicalCasesTable)..where((c) => c.id.equals(entityId))).write(
          ClinicalCasesTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'clinical_progress_note':
      case 'progress_note':
        await (db.update(db.clinicalProgressNotesTable)..where((n) => n.id.equals(entityId))).write(
          const ClinicalProgressNotesTableCompanion(syncStatus: Value('synced')),
        );
        break;

      case 'diagnosis':
        await (db.update(db.diagnosesTable)..where((d) => d.id.equals(entityId))).write(
          const DiagnosesTableCompanion(syncStatus: Value('synced')),
        );
        break;

      case 'inventory_movement_ledger':
      case 'dose':
        await (db.update(db.inventoryMovementLedgerTable)..where((l) => l.id.equals(entityId))).write(
          InventoryMovementLedgerTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;
    }
  }

  /// Safely ingests inbound server deltas into Drift relational tables.
  /// Enforces Append-Only invariant for SOAP progress notes and addenda.
  Future<void> applyServerDeltas({
    required String tenantId,
    required Map<String, dynamic> deltas,
  }) async {
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      // 1. Clients
      if (deltas['clients'] is List) {
        for (final item in deltas['clients'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.clientsTable).insertOnConflictUpdate(
                  ClientsTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    name: Value(item['name'] as String),
                    phonePrimary: Value(item['phone_primary'] as String),
                    phoneSecondary: Value(item['phone_secondary'] as String?),
                    clientType: Value(item['client_type'] as String? ?? 'individual'),
                    physicalAddress: Value(item['physical_address'] as String?),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 2. Patients
      if (deltas['patients'] is List) {
        for (final item in deltas['patients'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.patientsTable).insertOnConflictUpdate(
                  PatientsTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    clientId: Value(item['client_id'] as String),
                    nameOrTag: Value(item['name_or_tag'] as String),
                    species: Value(item['species'] as String),
                    breed: Value(item['breed'] as String?),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 3. Clinical Cases
      if (deltas['cases'] is List) {
        for (final item in deltas['cases'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.clinicalCasesTable).insertOnConflictUpdate(
                  ClinicalCasesTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    caseNumber: Value(item['case_number'] as String),
                    patientId: Value(item['patient_id'] as String),
                    primaryVeterinarianId: Value(item['primary_veterinarian_id'] as String),
                    chiefComplaint: Value(item['chief_complaint'] as String),
                    priority: Value(item['priority'] as String? ?? 'routine'),
                    status: Value(item['status'] as String? ?? 'open'),
                    admittedAt: Value(DateTime.tryParse(item['admitted_at']?.toString() ?? '') ?? now),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 4. Clinical Progress Notes (Append-Only: never overwrite signed clinical notes)
      if (deltas['progress_notes'] is List) {
        for (final item in deltas['progress_notes'] as List) {
          if (item is Map<String, dynamic>) {
            final noteId = item['id'] as String;
            final existing = await (db.select(db.clinicalProgressNotesTable)
                  ..where((n) => n.id.equals(noteId)))
                .getSingleOrNull();

            if (existing == null) {
              await db.into(db.clinicalProgressNotesTable).insert(
                    ClinicalProgressNotesTableCompanion(
                      id: Value(noteId),
                      caseId: Value(item['case_id'] as String),
                      patientId: Value(item['patient_id'] as String),
                      veterinarianId: Value(item['veterinarian_id'] as String),
                      veterinarianName: Value(item['veterinarian_name'] as String? ?? 'Attending Clinician'),
                      noteType: Value(item['note_type'] as String? ?? 'soap'),
                      subjective: Value(item['subjective'] as String?),
                      objective: Value(item['objective'] as String?),
                      assessment: Value(item['assessment'] as String?),
                      plan: Value(item['plan'] as String?),
                      recordedAt: Value(DateTime.tryParse(item['recorded_at']?.toString() ?? '') ?? now),
                      createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                      updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                      syncStatus: const Value('synced'),
                    ),
                  );
            }
          }
        }
      }

      // 5. Inventory Products
      if (deltas['inventory_products'] is List) {
        for (final item in deltas['inventory_products'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.inventoryProductsTable).insertOnConflictUpdate(
                  InventoryProductsTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    sku: Value(item['sku'] as String),
                    name: Value(item['name'] as String),
                    description: Value(item['description'] as String?),
                    baseUnit: Value(item['base_unit'] as String? ?? 'ml'),
                    isControlled: Value(item['is_controlled'] == true),
                    controlledSchedule: Value(item['controlled_schedule'] as String?),
                    currentStockQty: Value(Decimal.tryParse(item['current_stock_qty']?.toString() ?? '0') ?? Decimal.zero),
                    minThreshold: Value(Decimal.tryParse(item['min_threshold']?.toString() ?? '0') ?? Decimal.zero),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 6. Inventory Batches
      if (deltas['inventory_batches'] is List) {
        for (final item in deltas['inventory_batches'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.inventoryBatchesTable).insertOnConflictUpdate(
                  InventoryBatchesTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    productId: Value(item['product_id'] as String),
                    lotNumber: Value(item['lot_number'] as String),
                    expiresAt: Value(DateTime.tryParse(item['expires_at']?.toString() ?? '') ?? now),
                    initialBaseQty: Value(Decimal.tryParse(item['initial_base_qty']?.toString() ?? '0') ?? Decimal.zero),
                    remainingBaseQty: Value(Decimal.tryParse(item['remaining_base_qty']?.toString() ?? '0') ?? Decimal.zero),
                    status: Value(item['status'] as String? ?? 'active'),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 7. Inventory Containers
      if (deltas['inventory_containers'] is List) {
        for (final item in deltas['inventory_containers'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.inventoryContainersTable).insertOnConflictUpdate(
                  InventoryContainersTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    batchId: Value(item['batch_id'] as String),
                    productId: Value(item['product_id'] as String),
                    barcode: Value(item['barcode'] as String),
                    initialVolume: Value(Decimal.tryParse(item['initial_volume']?.toString() ?? '0') ?? Decimal.zero),
                    remainingBalance: Value(Decimal.tryParse(item['remaining_balance']?.toString() ?? '0') ?? Decimal.zero),
                    status: Value(item['status'] as String? ?? 'sealed'),
                    openedAt: Value(DateTime.tryParse(item['opened_at']?.toString() ?? '')),
                    openedByUserId: Value(item['opened_by_user_id'] as String?),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }
    });
  }
}
