import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/clients_table.dart';
import '../tables/patients_table.dart';
import '../tables/clinical_cases_table.dart';
import '../tables/visits_table.dart';
import '../tables/clinical_progress_notes_table.dart';
import '../tables/dose_administrations_table.dart';
import '../tables/diagnoses_table.dart';
import '../tables/sync_queue_table.dart';

part 'clinical_case_dao.g.dart';

/// Aggregated Clinical Summary Bundle for Triage Board listings.
class CaseSummaryBundle {
  final ClinicalCaseData clinicalCase;
  final PatientData patient;
  final ClientData client;

  const CaseSummaryBundle({
    required this.clinicalCase,
    required this.patient,
    required this.client,
  });
}

/// Aggregated Clinical Encounter Bundle containing patient, owner, visits, and diagnostic history.
class CaseDetailBundle {
  final ClinicalCaseData clinicalCase;
  final PatientData patient;
  final ClientData client;
  final List<ClinicalProgressNoteData> progressNotes;
  final List<DiagnosisData> diagnoses;
  final List<VisitData> visits;

  const CaseDetailBundle({
    required this.clinicalCase,
    required this.patient,
    required this.client,
    required this.progressNotes,
    required this.diagnoses,
    this.visits = const [],
  });
}

/// Aggregated Clinical Visit Encounter Bundle scoped to a specific Visit.
class VisitDetailBundle {
  final VisitData visit;
  final ClinicalCaseData clinicalCase;
  final PatientData patient;
  final ClientData client;
  final ClinicalProgressNoteData? soapNote;
  final List<ClinicalProgressNoteData> addenda;
  final List<DoseAdministrationData> doseAdministrations;

  const VisitDetailBundle({
    required this.visit,
    required this.clinicalCase,
    required this.patient,
    required this.client,
    this.soapNote,
    required this.addenda,
    required this.doseAdministrations,
  });
}

/// Data Access Object for Clinical Cases, Visits, Encounters, and Triage Boards.
@DriftAccessor(tables: [
  ClientsTable,
  PatientsTable,
  ClinicalCasesTable,
  VisitsTable,
  ClinicalProgressNotesTable,
  DoseAdministrationsTable,
  DiagnosesTable,
  SyncQueueTable,
])
class ClinicalCaseDao extends DatabaseAccessor<AppDatabase> with _$ClinicalCaseDaoMixin {
  final Uuid _uuid;

  ClinicalCaseDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Streams all active (non-deleted, non-closed) clinical cases for a tenant,
  /// ordered by emergency priority (critical -> urgent -> routine) and admission time.
  Stream<List<ClinicalCaseData>> watchActiveCases({required String tenantId}) {
    return (select(clinicalCasesTable)
          ..where((c) =>
              c.tenantId.equals(tenantId) &
              c.deletedAt.isNull() &
              c.status.isNotIn(['closed', 'discharged']))
          ..orderBy([
            // Critical first, then urgent, then routine
            (c) => OrderingTerm(
                  expression: const CustomExpression<int>(
                    "CASE priority WHEN 'critical' THEN 1 WHEN 'urgent' THEN 2 ELSE 3 END",
                  ),
                  mode: OrderingMode.asc,
                ),
            (c) => OrderingTerm(expression: c.admittedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Streams cases filtered by clinical priority (e.g. for Triage Board columns).
  Stream<List<ClinicalCaseData>> watchCasesByPriority({
    required String tenantId,
    required String priority,
  }) {
    return (select(clinicalCasesTable)
          ..where((c) =>
              c.tenantId.equals(tenantId) &
              c.deletedAt.isNull() &
              c.priority.equals(priority) &
              c.status.isNotIn(['closed', 'discharged']))
          ..orderBy([(c) => OrderingTerm(expression: c.admittedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Streams active cases joined with Patient and Client details for the Triage Board,
  /// sorted by severity priority (critical -> urgent -> routine) and admission time.
  Stream<List<CaseSummaryBundle>> watchCasesWithDetails({
    required String tenantId,
    String? priority,
    String? query,
  }) {
    final joinedQuery = select(clinicalCasesTable).join([
      innerJoin(
        patientsTable,
        patientsTable.id.equalsExp(clinicalCasesTable.patientId),
      ),
      innerJoin(
        clientsTable,
        clientsTable.id.equalsExp(patientsTable.clientId),
      ),
    ]);

    joinedQuery.where(
      clinicalCasesTable.tenantId.equals(tenantId) &
          clinicalCasesTable.deletedAt.isNull() &
          clinicalCasesTable.status.isNotIn(['closed', 'discharged']) &
          patientsTable.deletedAt.isNull() &
          clientsTable.deletedAt.isNull(),
    );

    if (priority != null &&
        priority.trim().isNotEmpty &&
        priority.toLowerCase() != 'all') {
      joinedQuery.where(
        clinicalCasesTable.priority.equals(priority.toLowerCase()),
      );
    }

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = '%${query.trim().toLowerCase()}%';
      joinedQuery.where(
        clinicalCasesTable.caseNumber.lower().like(cleanQuery) |
            clinicalCasesTable.chiefComplaint.lower().like(cleanQuery) |
            patientsTable.nameOrTag.lower().like(cleanQuery) |
            clientsTable.name.lower().like(cleanQuery),
      );
    }

    joinedQuery.orderBy([
      OrderingTerm(
        expression: const CustomExpression<int>(
          "CASE cases.priority WHEN 'critical' THEN 1 WHEN 'urgent' THEN 2 ELSE 3 END",
        ),
        mode: OrderingMode.asc,
      ),
      OrderingTerm(
        expression: clinicalCasesTable.admittedAt,
        mode: OrderingMode.desc,
      ),
    ]);

    return joinedQuery.watch().map((rows) {
      return rows.map((row) {
        return CaseSummaryBundle(
          clinicalCase: row.readTable(clinicalCasesTable),
          patient: row.readTable(patientsTable),
          client: row.readTable(clientsTable),
        );
      }).toList();
    });
  }

  /// Streams all historical cases for a specific patient.
  Stream<List<ClinicalCaseData>> watchCasesForPatient(String patientId) {
    return (select(clinicalCasesTable)
          ..where((c) => c.patientId.equals(patientId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.admittedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Streams all historical cases for a specific patient joined with Patient and Client details.
  Stream<List<CaseSummaryBundle>> watchCasesForPatientWithDetails(String patientId) {
    final joinedQuery = select(clinicalCasesTable).join([
      innerJoin(
        patientsTable,
        patientsTable.id.equalsExp(clinicalCasesTable.patientId),
      ),
      innerJoin(
        clientsTable,
        clientsTable.id.equalsExp(patientsTable.clientId),
      ),
    ]);

    joinedQuery.where(
      clinicalCasesTable.patientId.equals(patientId) &
          clinicalCasesTable.deletedAt.isNull() &
          patientsTable.deletedAt.isNull() &
          clientsTable.deletedAt.isNull(),
    );

    joinedQuery.orderBy([
      OrderingTerm(
        expression: clinicalCasesTable.admittedAt,
        mode: OrderingMode.desc,
      ),
    ]);

    return joinedQuery.watch().map((rows) {
      return rows.map((row) {
        return CaseSummaryBundle(
          clinicalCase: row.readTable(clinicalCasesTable),
          patient: row.readTable(patientsTable),
          client: row.readTable(clientsTable),
        );
      }).toList();
    });
  }

  /// Retrieves a single case by its unique UUID.
  Future<ClinicalCaseData?> getCaseById(String caseId) {
    return (select(clinicalCasesTable)..where((c) => c.id.equals(caseId))).getSingleOrNull();
  }

  /// Retrieves the complete relational bundle for an encounter:
  /// Case + Patient + Client + Progress Notes + Diagnoses.
  Future<CaseDetailBundle?> getCaseDetailBundle(String caseId) async {
    final caseRow = await getCaseById(caseId);
    if (caseRow == null) return null;

    final patientRow = await (select(patientsTable)..where((p) => p.id.equals(caseRow.patientId)))
        .getSingleOrNull();
    if (patientRow == null) return null;

    final clientRow = await (select(clientsTable)..where((c) => c.id.equals(patientRow.clientId)))
        .getSingleOrNull();
    if (clientRow == null) return null;

    final notes = await (select(clinicalProgressNotesTable)
          ..where((n) => n.caseId.equals(caseId))
          ..orderBy([(n) => OrderingTerm(expression: n.recordedAt, mode: OrderingMode.desc)]))
        .get();

    final diagnosesList = await (select(diagnosesTable)
          ..where((d) => d.caseId.equals(caseId))
          ..orderBy([(d) => OrderingTerm(expression: d.diagnosedAt, mode: OrderingMode.desc)]))
        .get();

    var visitsList = await (select(visitsTable)
          ..where((v) => v.caseId.equals(caseId) & v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc)]))
        .get();

    if (visitsList.isEmpty) {
      final now = DateTime.now().toUtc();
      await into(visitsTable).insert(
        VisitsTableCompanion.insert(
          id: _uuid.v7(),
          tenantId: caseRow.tenantId,
          caseId: caseRow.id,
          patientId: caseRow.patientId,
          veterinarianId: caseRow.primaryVeterinarianId,
          veterinarianName: caseRow.primaryVeterinarianName ?? 'Attending Clinician',
          title: 'Initial Consultation',
          visitType: Value(caseRow.caseType),
          status: const Value('open'),
          isSigned: const Value(false),
          visitDate: caseRow.admittedAt,
          createdAt: now,
          updatedAt: now,
        ),
      );
      visitsList = await (select(visitsTable)
            ..where((v) => v.caseId.equals(caseId) & v.deletedAt.isNull())
            ..orderBy([(v) => OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc)]))
          .get();
    }

    return CaseDetailBundle(
      clinicalCase: caseRow,
      patient: patientRow,
      client: clientRow,
      progressNotes: notes,
      diagnoses: diagnosesList,
      visits: visitsList,
    );
  }

  /// Real-time stream watching a specific case encounter with notes and diagnoses.
  Stream<CaseDetailBundle?> watchCaseDetailBundle(String caseId) {
    return (select(clinicalCasesTable)..where((c) => c.id.equals(caseId)))
        .watchSingleOrNull()
        .asyncMap((caseRow) async {
      if (caseRow == null) return null;
      return getCaseDetailBundle(caseId);
    });
  }

  /// Inserts a newly opened clinical case.
  Future<int> insertCase(ClinicalCasesTableCompanion entry) {
    return into(clinicalCasesTable).insert(entry);
  }

  /// Atomically inserts a clinical case and adds an offline sync outbox entry.
  Future<ClinicalCaseData> recordCase({
    required String tenantId,
    required ClinicalCasesTableCompanion caseCompanion,
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final savedCase = await into(clinicalCasesTable).insertReturning(caseCompanion);

      if (enqueueSync) {
        final payload = {
          'id': savedCase.id,
          'tenant_id': savedCase.tenantId,
          'case_number': savedCase.caseNumber,
          'patient_id': savedCase.patientId,
          'primary_veterinarian_id': savedCase.primaryVeterinarianId,
          'primary_veterinarian_name': savedCase.primaryVeterinarianName,
          'case_type': savedCase.caseType,
          'status': savedCase.status,
          'priority': savedCase.priority,
          'chief_complaint': savedCase.chiefComplaint,
          'provisional_diagnosis': savedCase.provisionalDiagnosis,
          'final_diagnosis': savedCase.finalDiagnosis,
          'admitted_at': savedCase.admittedAt.toIso8601String(),
          'discharged_at': savedCase.dischargedAt?.toIso8601String(),
          'created_at': savedCase.createdAt.toIso8601String(),
          'updated_at': savedCase.updatedAt.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'case',
            entityId: savedCase.id,
            action: 'create',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      // Automatically initialize the initial clinical visit encounter for this case
      await into(visitsTable).insert(
        VisitsTableCompanion.insert(
          id: _uuid.v7(),
          tenantId: tenantId,
          caseId: savedCase.id,
          patientId: savedCase.patientId,
          veterinarianId: savedCase.primaryVeterinarianId,
          veterinarianName: savedCase.primaryVeterinarianName ?? 'Attending Clinician',
          title: 'Initial Consultation',
          visitType: Value(savedCase.caseType),
          status: const Value('open'),
          isSigned: const Value(false),
          visitDate: savedCase.admittedAt,
          createdAt: now,
          updatedAt: now,
        ),
      );

      return savedCase;
    });
  }

  /// Atomically records a new SOAP Progress Note and enqueues an offline sync mutation.
  Future<ClinicalProgressNoteData> recordProgressNote({
    required String tenantId,
    required ClinicalProgressNotesTableCompanion noteCompanion,
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final savedNote = await into(clinicalProgressNotesTable).insertReturning(noteCompanion);

      // Touch the parent case's updatedAt so reactive streams emit fresh data
      await (update(clinicalCasesTable)..where((c) => c.id.equals(savedNote.caseId))).write(
        ClinicalCasesTableCompanion(
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (savedNote.visitId != null) {
        await (update(visitsTable)..where((v) => v.id.equals(savedNote.visitId!))).write(
          VisitsTableCompanion(
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      if (enqueueSync) {
        final payload = {
          'id': savedNote.id,
          'case_id': savedNote.caseId,
          if (savedNote.visitId != null) 'visit_id': savedNote.visitId,
          'patient_id': savedNote.patientId,
          'veterinarian_id': savedNote.veterinarianId,
          'veterinarian_name': savedNote.veterinarianName,
          'note_type': savedNote.noteType,
          'subjective': savedNote.subjective,
          'objective': savedNote.objective,
          'assessment': savedNote.assessment,
          'plan': savedNote.plan,
          'temperature_celsius': savedNote.temperatureCelsius,
          'heart_rate_bpm': savedNote.heartRateBpm,
          'respiratory_rate_bpm': savedNote.respiratoryRateBpm,
          'body_condition_score': savedNote.bodyConditionScore,
          'pain_score': savedNote.painScore,
          'recorded_at': savedNote.recordedAt.toIso8601String(),
          'created_at': savedNote.createdAt.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'clinical_progress_note',
            entityId: savedNote.id,
            action: 'create',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return savedNote;
    });
  }

  /// Updates an existing clinical case.
  Future<bool> updateCase(ClinicalCasesTableCompanion entry) {
    return update(clinicalCasesTable).replace(entry);
  }

  /// Updates case triage priority (e.g. from 'routine' to 'urgent' or 'critical')
  /// and logs sync mutation.
  Future<int> updateCasePriority(
    String caseId,
    String priority, {
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final rowsAffected = await (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(
        ClinicalCasesTableCompanion(
          priority: Value(priority.toLowerCase()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': caseId,
          'priority': priority.toLowerCase(),
          'updated_at': now.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'case',
            entityId: caseId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Updates case status (e.g. from 'open' to 'in_progress' or 'closed')
  /// and logs sync mutation.
  Future<int> updateCaseStatus(
    String caseId,
    String status, {
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final rowsAffected = await (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(
        ClinicalCasesTableCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': caseId,
          'status': status,
          'updated_at': now.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'case',
            entityId: caseId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Updates provisional and/or final diagnosis on a case and logs sync mutation.
  Future<int> updateCaseDiagnoses(
    String caseId, {
    String? provisionalDiagnosis,
    String? finalDiagnosis,
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final companion = ClinicalCasesTableCompanion(
        provisionalDiagnosis: provisionalDiagnosis != null ? Value(provisionalDiagnosis) : const Value.absent(),
        finalDiagnosis: finalDiagnosis != null ? Value(finalDiagnosis) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(companion);

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': caseId,
          if (provisionalDiagnosis != null) 'provisional_diagnosis': provisionalDiagnosis,
          if (finalDiagnosis != null) 'final_diagnosis': finalDiagnosis,
          'updated_at': now.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'case',
            entityId: caseId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Updates case chief complaint and enqueues sync mutation.
  Future<int> updateCaseChiefComplaint(
    String caseId,
    String chiefComplaint, {
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final rowsAffected = await (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(
        ClinicalCasesTableCompanion(
          chiefComplaint: Value(chiefComplaint),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': caseId,
          'chief_complaint': chiefComplaint,
          'updated_at': now.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'case',
            entityId: caseId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Updates visit title, visit type, and enqueues sync mutation.
  Future<int> updateVisitDetails(
    String visitId, {
    String? title,
    String? visitType,
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final companion = VisitsTableCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        visitType: visitType != null ? Value(visitType) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (update(visitsTable)..where((v) => v.id.equals(visitId))).write(companion);

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': visitId,
          if (title != null) 'title': title,
          if (visitType != null) 'visit_type': visitType,
          'updated_at': now.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'visit',
            entityId: visitId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Performs full-text / prefix search across case numbers and complaints.
  Future<List<ClinicalCaseData>> searchCases({
    required String tenantId,
    required String query,
  }) {
    final cleanQuery = '%$query%';
    return (select(clinicalCasesTable)
          ..where((c) =>
              c.tenantId.equals(tenantId) &
              c.deletedAt.isNull() &
              (c.caseNumber.like(cleanQuery) | c.chiefComplaint.like(cleanQuery)))
          ..orderBy([(c) => OrderingTerm(expression: c.admittedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Soft deletes a case and updates modified timestamp.
  Future<int> softDeleteCase(String caseId) {
    return (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(
      ClinicalCasesTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_delete'),
      ),
    );
  }

  /// Streams all visits for a clinical case, ordered by visitDate descending.
  Stream<List<VisitData>> watchVisitsForCase(String caseId) {
    return (select(visitsTable)
          ..where((v) => v.caseId.equals(caseId) & v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Retrieves all visits for a case.
  Future<List<VisitData>> getVisitsForCase(String caseId) {
    return (select(visitsTable)
          ..where((v) => v.caseId.equals(caseId) & v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Retrieves a single visit by its UUID.
  Future<VisitData?> getVisitById(String visitId) {
    return (select(visitsTable)..where((v) => v.id.equals(visitId))).getSingleOrNull();
  }

  /// Streams a single visit by its UUID.
  Stream<VisitData?> watchVisitById(String visitId) {
    return (select(visitsTable)..where((v) => v.id.equals(visitId))).watchSingleOrNull();
  }

  /// Retrieves full encounter bundle scoped to a single visit:
  /// Visit + Case + Patient + Client + SOAP Note + Addenda + Dose Administrations.
  Future<VisitDetailBundle?> getVisitDetailBundle(String visitId) async {
    final visitRow = await getVisitById(visitId);
    if (visitRow == null) return null;

    final caseRow = await getCaseById(visitRow.caseId);
    if (caseRow == null) return null;

    final patientRow = await (select(patientsTable)..where((p) => p.id.equals(caseRow.patientId)))
        .getSingleOrNull();
    if (patientRow == null) return null;

    final clientRow = await (select(clientsTable)..where((c) => c.id.equals(patientRow.clientId)))
        .getSingleOrNull();
    if (clientRow == null) return null;

    final allVisitNotes = await (select(clinicalProgressNotesTable)
          ..where((n) => n.visitId.equals(visitId) | (n.caseId.equals(visitRow.caseId) & n.visitId.equals(visitId)))
          ..orderBy([(n) => OrderingTerm(expression: n.recordedAt, mode: OrderingMode.asc)]))
        .get();

    ClinicalProgressNoteData? soapNote;
    final addenda = <ClinicalProgressNoteData>[];
    for (final note in allVisitNotes) {
      if (note.noteType.toLowerCase() == 'addendum') {
        addenda.add(note);
      } else {
        soapNote ??= note;
      }
    }

    final doses = await (select(doseAdministrationsTable)
          ..where((d) => d.visitId.equals(visitId))
          ..orderBy([(d) => OrderingTerm(expression: d.administeredAt, mode: OrderingMode.desc)]))
        .get();

    return VisitDetailBundle(
      visit: visitRow,
      clinicalCase: caseRow,
      patient: patientRow,
      client: clientRow,
      soapNote: soapNote,
      addenda: addenda,
      doseAdministrations: doses,
    );
  }

  /// Streams real-time updates for a single visit encounter bundle.
  Stream<VisitDetailBundle?> watchVisitDetailBundle(String visitId) {
    return (select(visitsTable)..where((v) => v.id.equals(visitId)))
        .watchSingleOrNull()
        .asyncMap((visit) async {
      if (visit == null) return null;
      return getVisitDetailBundle(visitId);
    });
  }

  /// Atomically records a new Visit encounter and enqueues offline sync mutation.
  Future<VisitData> recordVisit({
    required String tenantId,
    required VisitsTableCompanion visitCompanion,
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final savedVisit = await into(visitsTable).insertReturning(visitCompanion);

      // Touch parent case's updatedAt
      await (update(clinicalCasesTable)..where((c) => c.id.equals(savedVisit.caseId))).write(
        ClinicalCasesTableCompanion(updatedAt: Value(DateTime.now())),
      );

      if (enqueueSync) {
        final payload = {
          'id': savedVisit.id,
          'tenant_id': savedVisit.tenantId,
          'case_id': savedVisit.caseId,
          'patient_id': savedVisit.patientId,
          'veterinarian_id': savedVisit.veterinarianId,
          'veterinarian_name': savedVisit.veterinarianName,
          'title': savedVisit.title,
          'visit_type': savedVisit.visitType,
          'status': savedVisit.status,
          'is_signed': savedVisit.isSigned,
          'signed_at': savedVisit.signedAt?.toIso8601String(),
          'signed_by': savedVisit.signedBy,
          'visit_date': savedVisit.visitDate.toIso8601String(),
          'created_at': savedVisit.createdAt.toIso8601String(),
          'updated_at': savedVisit.updatedAt.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'visit',
            entityId: savedVisit.id,
            action: 'create',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return savedVisit;
    });
  }

  /// Signs and locks a visit encounter.
  Future<int> signVisit({
    required String visitId,
    required String signedBy,
    String tenantId = 'default',
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now();
      final nowUtc = now.toUtc();
      final rowsAffected = await (update(visitsTable)..where((v) => v.id.equals(visitId))).write(
        VisitsTableCompanion(
          isSigned: const Value(true),
          status: const Value('signed'),
          signedAt: Value(now),
          signedBy: Value(signedBy),
          updatedAt: Value(now),
        ),
      );

      final visitRow = await getVisitById(visitId);
      if (visitRow != null) {
        await (update(clinicalCasesTable)..where((c) => c.id.equals(visitRow.caseId))).write(
          ClinicalCasesTableCompanion(updatedAt: Value(now)),
        );
      }

      if (enqueueSync && rowsAffected > 0) {
        final payload = {
          'id': visitId,
          'is_signed': true,
          'status': 'signed',
          'signed_at': nowUtc.toIso8601String(),
          'signed_by': signedBy,
          'updated_at': nowUtc.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'visit',
            entityId: visitId,
            action: 'update',
            payload: jsonEncode(payload),
            clientTimestamp: nowUtc,
            idempotencyKey: _uuid.v7(),
            createdAt: nowUtc,
          ),
        );
      }

      return rowsAffected;
    });
  }

  /// Records an administered medication dose and enqueues offline sync mutation.
  Future<DoseAdministrationData> recordDoseAdministration({
    required String tenantId,
    required DoseAdministrationsTableCompanion doseCompanion,
    bool enqueueSync = true,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final savedDose = await into(doseAdministrationsTable).insertReturning(doseCompanion);

      // Touch visit updatedAt
      await (update(visitsTable)..where((v) => v.id.equals(savedDose.visitId))).write(
        VisitsTableCompanion(updatedAt: Value(DateTime.now())),
      );

      if (enqueueSync) {
        final payload = {
          'id': savedDose.id,
          'tenant_id': savedDose.tenantId,
          'visit_id': savedDose.visitId,
          'case_id': savedDose.caseId,
          'patient_id': savedDose.patientId,
          'medicine_name': savedDose.medicineName,
          'dose_quantity': savedDose.doseQuantity,
          'unit': savedDose.unit,
          'route': savedDose.route,
          'clinical_notes': savedDose.clinicalNotes,
          'veterinarian_id': savedDose.veterinarianId,
          'veterinarian_name': savedDose.veterinarianName,
          'administered_at': savedDose.administeredAt.toIso8601String(),
          'created_at': savedDose.createdAt.toIso8601String(),
        };

        await into(syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            entityType: 'dose_administration',
            entityId: savedDose.id,
            action: 'create',
            payload: jsonEncode(payload),
            clientTimestamp: now,
            idempotencyKey: _uuid.v7(),
            createdAt: now,
          ),
        );
      }

      return savedDose;
    });
  }

  /// Streams doses administered in a visit.
  Stream<List<DoseAdministrationData>> watchDosesForVisit(String visitId) {
    return (select(doseAdministrationsTable)
          ..where((d) => d.visitId.equals(visitId))
          ..orderBy([(d) => OrderingTerm(expression: d.administeredAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Gets doses administered in a visit.
  Future<List<DoseAdministrationData>> getDosesForVisit(String visitId) {
    return (select(doseAdministrationsTable)
          ..where((d) => d.visitId.equals(visitId))
          ..orderBy([(d) => OrderingTerm(expression: d.administeredAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Streams clinical progress notes filtered by visitId.
  Stream<List<ClinicalProgressNoteData>> watchNotesForVisit(String visitId) {
    return (select(clinicalProgressNotesTable)
          ..where((n) => n.visitId.equals(visitId))
          ..orderBy([(n) => OrderingTerm(expression: n.recordedAt, mode: OrderingMode.asc)]))
        .watch();
  }
}
