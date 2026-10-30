import 'package:equatable/equatable.dart';

/// Domain entity representing a clinical diagnosis for a patient/encounter.
class DiagnosisEntity extends Equatable {
  final String id;
  final String patientId;
  final String? caseId;
  final String userId;
  final String diagnosis;
  final String? description;
  final String status; // 'active', 'resolved', 'rule_out', 'chronic'
  final String? notes;
  final DateTime diagnosedAt;

  const DiagnosisEntity({
    required this.id,
    required this.patientId,
    this.caseId,
    required this.userId,
    required this.diagnosis,
    this.description,
    this.status = 'active',
    this.notes,
    required this.diagnosedAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        caseId,
        userId,
        diagnosis,
        description,
        status,
        notes,
        diagnosedAt,
      ];
}
