import 'package:equatable/equatable.dart';
import 'case_entity.dart';
import 'dose_administration_entity.dart';
import 'progress_note_entity.dart';

/// Clinical Visit & Encounter domain entity scoped to a parent Clinical Case.
class VisitEntity extends Equatable {
  final String id;
  final String tenantId;
  final String caseId;
  final String patientId;
  final String veterinarianId;
  final String veterinarianName;
  final String title;
  final String visitType;
  final String status; // 'open', 'signed', 'closed'
  final bool isSigned;
  final DateTime? signedAt;
  final String? signedBy;
  final DateTime visitDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  /// The primary physical examination SOAP note for this visit (if authored).
  final ProgressNoteEntity? soapNote;

  /// Immutable addenda appended to this visit after signing.
  final List<ProgressNoteEntity> addenda;

  /// Medication doses administered during this specific encounter.
  final List<DoseAdministrationEntity> doseAdministrations;

  const VisitEntity({
    required this.id,
    this.tenantId = 'default',
    required this.caseId,
    required this.patientId,
    required this.veterinarianId,
    required this.veterinarianName,
    required this.title,
    this.visitType = 'consultation',
    this.status = 'open',
    this.isSigned = false,
    this.signedAt,
    this.signedBy,
    required this.visitDate,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.soapNote,
    this.addenda = const [],
    this.doseAdministrations = const [],
  });

  bool get isOpen => !isSigned && status.toLowerCase() == 'open';
  bool get isLocked => isSigned || status.toLowerCase() == 'signed' || status.toLowerCase() == 'closed';
  bool get hasSoap => soapNote != null;
  bool get hasDoses => doseAdministrations.isNotEmpty;
  bool get hasAddenda => addenda.isNotEmpty;

  String get visitTypeDisplay {
    switch (visitType.toLowerCase()) {
      case 'follow_up':
        return 'Follow-up Visit';
      case 'emergency':
        return 'Emergency Visit';
      case 'routine':
        return 'Routine Checkup';
      case 'surgery_recheck':
        return 'Surgery Recheck';
      case 'consultation':
      default:
        return 'Consultation';
    }
  }

  VisitEntity copyWith({
    String? id,
    String? tenantId,
    String? caseId,
    String? patientId,
    String? veterinarianId,
    String? veterinarianName,
    String? title,
    String? visitType,
    String? status,
    bool? isSigned,
    DateTime? signedAt,
    String? signedBy,
    DateTime? visitDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    ProgressNoteEntity? soapNote,
    List<ProgressNoteEntity>? addenda,
    List<DoseAdministrationEntity>? doseAdministrations,
  }) {
    return VisitEntity(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      caseId: caseId ?? this.caseId,
      patientId: patientId ?? this.patientId,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      title: title ?? this.title,
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      isSigned: isSigned ?? this.isSigned,
      signedAt: signedAt ?? this.signedAt,
      signedBy: signedBy ?? this.signedBy,
      visitDate: visitDate ?? this.visitDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      soapNote: soapNote ?? this.soapNote,
      addenda: addenda ?? this.addenda,
      doseAdministrations: doseAdministrations ?? this.doseAdministrations,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        caseId,
        patientId,
        veterinarianId,
        veterinarianName,
        title,
        visitType,
        status,
        isSigned,
        signedAt,
        signedBy,
        visitDate,
        createdAt,
        updatedAt,
        syncStatus,
        soapNote,
        addenda,
        doseAdministrations,
      ];
}

/// Clinical alias for ClinicalCase
typedef ClinicalCase = CaseSummaryEntity;
/// Clinical alias for Visit
typedef Visit = VisitEntity;
/// Clinical alias for DoseAdministration
typedef DoseAdministration = DoseAdministrationEntity;
