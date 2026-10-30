import 'package:equatable/equatable.dart';
import '../../domain/entities/case_entity.dart';

abstract class CaseDetailEvent extends Equatable {
  const CaseDetailEvent();

  @override
  List<Object?> get props => [];
}

class CaseDetailLoaded extends CaseDetailEvent {
  final String caseId;

  const CaseDetailLoaded(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class CaseDetailStreamUpdated extends CaseDetailEvent {
  final CaseDetailEntity? caseDetail;

  const CaseDetailStreamUpdated(this.caseDetail);

  @override
  List<Object?> get props => [caseDetail];
}

class CasePriorityChanged extends CaseDetailEvent {
  final String newPriority;

  const CasePriorityChanged(this.newPriority);

  @override
  List<Object?> get props => [newPriority];
}

class CaseStatusChanged extends CaseDetailEvent {
  final String newStatus;

  const CaseStatusChanged(this.newStatus);

  @override
  List<Object?> get props => [newStatus];
}

class CaseSoapNoteAdded extends CaseDetailEvent {
  final String? subjective;
  final String? objective;
  final String? assessment;
  final String? plan;
  final double? temperatureCelsius;
  final int? heartRateBpm;
  final int? respiratoryRateBpm;
  final int? bodyConditionScore;
  final int? painScore;
  final String? veterinarianName;

  const CaseSoapNoteAdded({
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
    this.temperatureCelsius,
    this.heartRateBpm,
    this.respiratoryRateBpm,
    this.bodyConditionScore,
    this.painScore,
    this.veterinarianName,
  });

  @override
  List<Object?> get props => [
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        veterinarianName,
      ];
}

class CaseAddendumAdded extends CaseDetailEvent {
  final String addendumText;
  final String veterinarianName;

  const CaseAddendumAdded({
    required this.addendumText,
    required this.veterinarianName,
  });

  @override
  List<Object?> get props => [addendumText, veterinarianName];
}

class CaseDiagnosesUpdated extends CaseDetailEvent {
  final String? provisionalDiagnosis;
  final String? finalDiagnosis;

  const CaseDiagnosesUpdated({
    this.provisionalDiagnosis,
    this.finalDiagnosis,
  });

  @override
  List<Object?> get props => [provisionalDiagnosis, finalDiagnosis];
}
