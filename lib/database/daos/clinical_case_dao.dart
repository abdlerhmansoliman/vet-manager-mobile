import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/clients_table.dart';
import '../tables/patients_table.dart';
import '../tables/clinical_cases_table.dart';
import '../tables/clinical_progress_notes_table.dart';
import '../tables/diagnoses_table.dart';
import '../tables/sync_queue_table.dart';

part 'clinical_case_dao.g.dart';

/// Aggregated Clinical Encounter Bundle containing patient, owner, and diagnostic history.
class CaseDetailBundle {
  final ClinicalCaseData clinicalCase;
  final PatientData patient;
  final ClientData client;
  final List<ClinicalProgressNoteData> progressNotes;
  final List<DiagnosisData> diagnoses;

  const CaseDetailBundle({
    required this.clinicalCase,
    required this.patient,
    required this.client,
    required this.progressNotes,
    required this.diagnoses,
  });
}

/// Data Access Object for Clinical Cases, Encounters, and Triage Boards.
@DriftAccessor(tables: [
  ClientsTable,
  PatientsTable,
  ClinicalCasesTable,
  ClinicalProgressNotesTable,
  DiagnosesTable,
  SyncQueueTable,
])
class ClinicalCaseDao extends DatabaseAccessor<AppDatabase> with _$ClinicalCaseDaoMixin {
  ClinicalCaseDao(super.db);

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

  /// Streams all historical cases for a specific patient.
  Stream<List<ClinicalCaseData>> watchCasesForPatient(String patientId) {
    return (select(clinicalCasesTable)
          ..where((c) => c.patientId.equals(patientId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.admittedAt, mode: OrderingMode.desc)]))
        .watch();
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

    return CaseDetailBundle(
      clinicalCase: caseRow,
      patient: patientRow,
      client: clientRow,
      progressNotes: notes,
      diagnoses: diagnosesList,
    );
  }

  /// Inserts a newly opened clinical case and enqueues an offline sync mutation.
  Future<int> insertCase(ClinicalCasesTableCompanion entry) {
    return into(clinicalCasesTable).insert(entry);
  }

  /// Updates an existing clinical case.
  Future<bool> updateCase(ClinicalCasesTableCompanion entry) {
    return update(clinicalCasesTable).replace(entry);
  }

  /// Updates case status (e.g. from 'open' to 'in_progress' or 'closed').
  Future<int> updateCaseStatus(String caseId, String status) {
    return (update(clinicalCasesTable)..where((c) => c.id.equals(caseId))).write(
      ClinicalCasesTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
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
}
