import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/clients_table.dart';
import '../tables/patients_table.dart';
import '../tables/sync_queue_table.dart';

part 'client_patient_dao.g.dart';

/// Aggregated pair of a Patient and their registered Owner/Client.
class PatientWithClient {
  final PatientData patient;
  final ClientData client;

  const PatientWithClient({
    required this.patient,
    required this.client,
  });
}

/// Data Access Object for Patients and Clients/Owners directory.
///
/// Features:
/// - Real-time reactive stream with cross-entity search and species filtering
/// - Single patient profile lookup with owner details
/// - Atomic transaction for creating client & patient with offline sync queue outbox records
@DriftAccessor(tables: [
  ClientsTable,
  PatientsTable,
  SyncQueueTable,
])
class ClientPatientDao extends DatabaseAccessor<AppDatabase> with _$ClientPatientDaoMixin {
  final Uuid _uuid;

  ClientPatientDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Reactive stream of patients with their registered owner, filtered by tenant,
  /// optional search term, and optional species classification.
  Stream<List<PatientWithClient>> watchPatientsWithClient({
    required String tenantId,
    String? query,
    String? speciesFilter,
  }) {
    final joinedQuery = select(patientsTable).join([
      innerJoin(
        clientsTable,
        clientsTable.id.equalsExp(patientsTable.clientId),
      ),
    ]);

    joinedQuery.where(
      patientsTable.tenantId.equals(tenantId) &
          patientsTable.deletedAt.isNull() &
          clientsTable.deletedAt.isNull(),
    );

    // Apply species filter if specified
    if (speciesFilter != null &&
        speciesFilter.trim().isNotEmpty &&
        speciesFilter.toLowerCase() != 'all') {
      joinedQuery.where(
        patientsTable.species.lower().equals(speciesFilter.trim().toLowerCase()),
      );
    }

    // Apply cross-entity search query if specified
    if (query != null && query.trim().isNotEmpty) {
      final sanitized = '%${query.trim().toLowerCase()}%';
      final queryPredicate = patientsTable.nameOrTag.lower().like(sanitized) |
          patientsTable.microchipNumber.lower().like(sanitized) |
          patientsTable.earTagId.lower().like(sanitized) |
          clientsTable.name.lower().like(sanitized) |
          clientsTable.phonePrimary.lower().like(sanitized) |
          clientsTable.phoneSecondary.lower().like(sanitized);

      joinedQuery.where(queryPredicate);
    }

    // Order by most recently updated patient first
    joinedQuery.orderBy([
      OrderingTerm(expression: patientsTable.updatedAt, mode: OrderingMode.desc),
    ]);

    return joinedQuery.watch().map((rows) {
      return rows.map((row) {
        return PatientWithClient(
          patient: row.readTable(patientsTable),
          client: row.readTable(clientsTable),
        );
      }).toList();
    });
  }

  /// One-time fetch of a specific patient profile joined with client details.
  Future<PatientWithClient?> getPatientWithClient({
    required String tenantId,
    required String patientId,
  }) async {
    final joinedQuery = select(patientsTable).join([
      innerJoin(
        clientsTable,
        clientsTable.id.equalsExp(patientsTable.clientId),
      ),
    ]);

    joinedQuery.where(
      patientsTable.tenantId.equals(tenantId) &
          patientsTable.id.equals(patientId) &
          patientsTable.deletedAt.isNull(),
    );

    final row = await joinedQuery.getSingleOrNull();
    if (row == null) return null;

    return PatientWithClient(
      patient: row.readTable(patientsTable),
      client: row.readTable(clientsTable),
    );
  }

  /// Searches existing active clients for autocomplete or owner association.
  Future<List<ClientData>> searchClients({
    required String tenantId,
    required String query,
  }) {
    final sanitized = '%${query.trim().toLowerCase()}%';
    return (select(clientsTable)
          ..where((c) =>
              c.tenantId.equals(tenantId) &
              c.deletedAt.isNull() &
              (c.name.lower().like(sanitized) |
                  c.phonePrimary.lower().like(sanitized) |
                  c.phoneSecondary.lower().like(sanitized)))
          ..orderBy([(c) => OrderingTerm(expression: c.name, mode: OrderingMode.asc)]))
        .get();
  }

  /// Atomically inserts or associates a client, creates a new patient,
  /// and enqueues offline mutation records into [SyncQueueTable].
  Future<PatientWithClient> registerClientAndPatient({
    required String tenantId,
    required ClientsTableCompanion clientCompanion,
    required PatientsTableCompanion patientCompanion,
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();

      // 1. Check if client already exists or insert new client
      final clientId = clientCompanion.id.value;
      final existingClient = await (select(clientsTable)
            ..where((c) => c.tenantId.equals(tenantId) & c.id.equals(clientId)))
          .getSingleOrNull();

      ClientData savedClient;
      if (existingClient == null) {
        savedClient = await into(clientsTable).insertReturning(clientCompanion);

        if (enqueueSync) {
          final clientPayload = {
            'id': savedClient.id,
            'tenant_id': savedClient.tenantId,
            'client_type': savedClient.clientType,
            'name': savedClient.name,
            'contact_person': savedClient.contactPerson,
            'phone_primary': savedClient.phonePrimary,
            'phone_secondary': savedClient.phoneSecondary,
            'physical_address': savedClient.physicalAddress,
            'notes': savedClient.notes,
            'created_at': savedClient.createdAt.toIso8601String(),
            'updated_at': savedClient.updatedAt.toIso8601String(),
          };

          await into(syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: _uuid.v7(),
              tenantId: tenantId,
              entityType: 'client',
              entityId: savedClient.id,
              action: 'create',
              payload: jsonEncode(clientPayload),
              clientTimestamp: now,
              idempotencyKey: _uuid.v7(),
              createdAt: now,
            ),
          );
        }
      } else {
        savedClient = existingClient;
      }

      // 2. Insert new patient
      final savedPatient = await into(patientsTable).insertReturning(patientCompanion);

      if (enqueueSync) {
        final patientPayload = {
          'id': savedPatient.id,
          'tenant_id': savedPatient.tenantId,
          'client_id': savedPatient.clientId,
          'name_or_tag': savedPatient.nameOrTag,
          'species': savedPatient.species,
          'breed': savedPatient.breed,
          'gender': savedPatient.gender,
          'age': savedPatient.age,
          'date_of_birth': savedPatient.dateOfBirth?.toIso8601String(),
          'is_approximate_age': savedPatient.isApproximateAge,
          'microchip_number': savedPatient.microchipNumber,
          'ear_tag_id': savedPatient.earTagId,
          'coat_color_markings': savedPatient.coatColorMarkings,
          'current_weight_kg': savedPatient.currentWeightKg,
          'weight_recorded_at': savedPatient.weightRecordedAt?.toIso8601String(),
          'history': savedPatient.history,
          'notes': savedPatient.notes,
          'status': savedPatient.status,
          'allergies': savedPatient.allergies,
          'created_at': savedPatient.createdAt.toIso8601String(),
          'updated_at': savedPatient.updatedAt.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'patient',
            entityId: savedPatient.id,
            action: 'create',
            payload: jsonEncode(patientPayload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return PatientWithClient(patient: savedPatient, client: savedClient);
    });
  }
}
