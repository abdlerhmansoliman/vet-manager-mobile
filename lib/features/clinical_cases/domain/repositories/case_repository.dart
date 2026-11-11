import '../entities/case_entity.dart';
import '../entities/progress_note_entity.dart';
import '../entities/visit_entity.dart';
import '../entities/dose_administration_entity.dart';

/// Repository contract for Clinical Cases, Visits, Triage, and SOAP progress notes.
abstract class ICaseRepository {
  /// Watches the active clinical cases with patient & owner details for the triage board.
  Stream<List<CaseSummaryEntity>> watchCases({
    String? priority,
    String? query,
  });

  /// Watches all historical and active clinical cases/visits for a specific patient.
  Stream<List<CaseSummaryEntity>> watchCasesForPatient(String patientId);

  /// Real-time stream watching a specific case encounter with visits, notes, and diagnoses.
  Stream<CaseDetailEntity?> watchCaseDetail(String caseId);

  /// One-time fetch of full encounter details.
  Future<CaseDetailEntity?> getCaseDetail(String caseId);

  /// Watches all clinical visits for a case.
  Stream<List<VisitEntity>> watchVisits(String caseId);

  /// Real-time stream watching a specific visit encounter with scoped SOAP notes, doses, and addenda.
  Stream<VisitEntity?> watchVisitDetail(String visitId);

  /// One-time fetch of visit details.
  Future<VisitEntity?> getVisitDetail(String visitId);

  /// Starts a new clinical visit encounter for a case.
  Future<VisitEntity> startVisit({
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    required String title,
    String visitType = 'consultation',
    DateTime? visitDate,
  });

  /// Formally signs and locks a visit encounter.
  Future<void> signVisit({
    required String visitId,
    required String signedBy,
  });

  /// Registers an administered medication dose within a specific visit.
  Future<DoseAdministrationEntity> administerMedication({
    required String visitId,
    required String caseId,
    required String patientId,
    required String medicineName,
    required String doseQuantity,
    required String unit,
    required String route,
    String? clinicalNotes,
    required String veterinarianId,
    required String veterinarianName,
  });

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

  /// Appends an examination SOAP progress note with vitals (optionally scoped to a visit).
  Future<ProgressNoteEntity> addSoapNote({
    required String caseId,
    String? visitId,
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

  /// Appends an immutable signed addendum to a clinical case or visit.
  Future<ProgressNoteEntity> addAddendum({
    required String caseId,
    String? visitId,
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

  /// Updates case chief complaint.
  Future<void> updateChiefComplaint({
    required String caseId,
    required String chiefComplaint,
  });

  /// Updates visit title, type, and details.
  Future<void> updateVisitDetails({
    required String visitId,
    String? title,
    String? visitType,
  });
}
