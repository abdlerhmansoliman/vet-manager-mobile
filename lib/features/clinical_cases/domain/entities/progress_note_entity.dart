import 'package:equatable/equatable.dart';

/// Domain entity representing a veterinary SOAP clinical examination or immutable addendum.
class ProgressNoteEntity extends Equatable {
  final String id;
  final String caseId;
  final String patientId;
  final String veterinarianId;
  final String veterinarianName;
  final String noteType; // 'soap', 'addendum', 'nursing_log', 'discharge_summary'
  final String? subjective;
  final String? objective;
  final String? assessment;
  final String? plan;
  final double? temperatureCelsius;
  final int? heartRateBpm;
  final int? respiratoryRateBpm;
  final int? bodyConditionScore; // 1-9
  final int? painScore; // 0-4
  final DateTime recordedAt;
  final DateTime createdAt;
  final String syncStatus;

  const ProgressNoteEntity({
    required this.id,
    required this.caseId,
    required this.patientId,
    required this.veterinarianId,
    required this.veterinarianName,
    this.noteType = 'soap',
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
    this.temperatureCelsius,
    this.heartRateBpm,
    this.respiratoryRateBpm,
    this.bodyConditionScore,
    this.painScore,
    required this.recordedAt,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  bool get isAddendum => noteType.toLowerCase() == 'addendum';
  bool get isSoap => noteType.toLowerCase() == 'soap';

  bool get hasVitals =>
      temperatureCelsius != null ||
      heartRateBpm != null ||
      respiratoryRateBpm != null ||
      bodyConditionScore != null ||
      painScore != null;

  String get vitalsSummary {
    final parts = <String>[];
    if (temperatureCelsius != null) parts.add('${temperatureCelsius!.toStringAsFixed(1)}°C');
    if (heartRateBpm != null) parts.add('HR: $heartRateBpm bpm');
    if (respiratoryRateBpm != null) parts.add('RR: $respiratoryRateBpm bpm');
    if (painScore != null) parts.add('Pain: $painScore/4');
    if (bodyConditionScore != null) parts.add('BCS: $bodyConditionScore/9');
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        id,
        caseId,
        patientId,
        veterinarianId,
        veterinarianName,
        noteType,
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        recordedAt,
        createdAt,
        syncStatus,
      ];
}
