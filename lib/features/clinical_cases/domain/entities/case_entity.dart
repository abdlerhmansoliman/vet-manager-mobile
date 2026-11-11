import 'package:equatable/equatable.dart';
import 'progress_note_entity.dart';
import 'diagnosis_entity.dart';
import 'visit_entity.dart';

/// Clinical summary entity for triage boards and case cards.
class CaseSummaryEntity extends Equatable {
  final String id;
  final String tenantId;
  final String caseNumber;
  final String patientId;
  final String patientName;
  final String species;
  final String? breed;
  final String? ageFormatted;
  final double? currentWeightKg;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String primaryVeterinarianId;
  final String? primaryVeterinarianName;
  final String caseType; // 'outpatient', 'inpatient', 'emergency', 'surgery', 'herd_check'
  final String status; // 'open', 'in_progress', 'under_observation', 'closed'
  final String priority; // 'routine', 'urgent', 'critical'
  final String chiefComplaint;
  final String? provisionalDiagnosis;
  final String? finalDiagnosis;
  final DateTime admittedAt;
  final DateTime? dischargedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const CaseSummaryEntity({
    required this.id,
    required this.tenantId,
    required this.caseNumber,
    required this.patientId,
    required this.patientName,
    required this.species,
    this.breed,
    this.ageFormatted,
    this.currentWeightKg,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.primaryVeterinarianId,
    this.primaryVeterinarianName,
    this.caseType = 'outpatient',
    this.status = 'open',
    this.priority = 'routine',
    required this.chiefComplaint,
    this.provisionalDiagnosis,
    this.finalDiagnosis,
    required this.admittedAt,
    this.dischargedAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  bool get isCritical => priority.toLowerCase() == 'critical' || priority.toLowerCase() == 'emergency_critical' || priority.toLowerCase() == 'emergency';
  bool get isUrgent => priority.toLowerCase() == 'urgent';
  bool get isRoutine => priority.toLowerCase() == 'routine';

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isClosed => status.toLowerCase() == 'closed' || status.toLowerCase() == 'discharged';

  @override
  List<Object?> get props => [
        id,
        tenantId,
        caseNumber,
        patientId,
        patientName,
        species,
        breed,
        ageFormatted,
        currentWeightKg,
        clientId,
        clientName,
        clientPhone,
        primaryVeterinarianId,
        primaryVeterinarianName,
        caseType,
        status,
        priority,
        chiefComplaint,
        provisionalDiagnosis,
        finalDiagnosis,
        admittedAt,
        dischargedAt,
        createdAt,
        updatedAt,
        syncStatus,
      ];
}

/// Comprehensive relational encounter entity including notes, vitals, visits, and diagnoses.
class CaseDetailEntity extends Equatable {
  final CaseSummaryEntity summary;
  final String? clientAddress;
  final List<String> allergies;
  final List<ProgressNoteEntity> progressNotes;
  final List<DiagnosisEntity> diagnoses;
  final List<VisitEntity> visits;

  const CaseDetailEntity({
    required this.summary,
    this.clientAddress,
    this.allergies = const [],
    this.progressNotes = const [],
    required this.diagnoses,
    this.visits = const [],
  });

  List<ProgressNoteEntity> get soapNotes =>
      progressNotes.where((n) => !n.isAddendum).toList();

  List<ProgressNoteEntity> get addenda =>
      progressNotes.where((n) => n.isAddendum).toList();

  @override
  List<Object?> get props => [
        summary,
        clientAddress,
        allergies,
        progressNotes,
        diagnoses,
        visits,
      ];
}
