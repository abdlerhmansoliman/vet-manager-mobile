import '../entities/case_entity.dart';
import '../entities/progress_note_entity.dart';

/// Repository contract for Clinical Cases, Triage, and SOAP progress notes.
abstract class ICaseRepository {
  /// Watches the active clinical cases with patient & owner details for the triage board.
  Stream<List<CaseSummaryEntity>> watchCases({
    String? priority,
    String? query,
  });

  /// Watches all historical and active clinical cases/visits for a specific patient.
  Stream<List<CaseSummaryEntity>> watchCasesForPatient(String patientId);

  /// Real-time stream watching a specific case encounter with notes and diagnoses.
  Stream<CaseDetailEntity?> watchCaseDetail(String caseId);

  /// One-time fetch of full encounter details.
  Future<CaseDetailEntity?> getCaseDetail(String caseId);

  /// Registers / opens a new clinical encounter.
  Future<CaseSummaryEntity> openCase({
    required String patientId,
    required String caseNumber,
    required String chiefComplaint,
    String priority = 'routine',
    String caseType = 'outpatient',
    String? primaryVeterinarianId,
    String? primaryVeterinarianName,
    String? provisionalDiagnosis,
  });

  /// Appends an examination SOAP progress note with vitals.
  Future<ProgressNoteEntity> addSoapNote({
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    double? temperatureCelsius,
    int? heartRateBpm,
    int? respiratoryRateBpm,
    int? bodyConditionScore,
    int? painScore,
    DateTime? recordedAt,
  });

  /// Appends an immutable signed addendum to a clinical case.
  Future<ProgressNoteEntity> addAddendum({
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    required String addendumText,
    DateTime? recordedAt,
  });

  /// Updates triage priority (Routine, Urgent, Critical).
  Future<void> updatePriority({
    required String caseId,
    required String priority,
  });

  /// Updates encounter lifecycle status (Open, In Progress, Closed, etc.).
  Future<void> updateStatus({
    required String caseId,
    required String status,
  });

  /// Updates provisional or final diagnosis.
  Future<void> updateDiagnoses({
    required String caseId,
    String? provisionalDiagnosis,
    String? finalDiagnosis,
  });
}
