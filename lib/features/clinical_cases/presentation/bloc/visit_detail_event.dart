import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription_item.dart';

abstract class VisitDetailEvent extends Equatable {
  const VisitDetailEvent();

  @override
  List<Object?> get props => [];
}

class VisitDetailLoaded extends VisitDetailEvent {
  final String visitId;

  const VisitDetailLoaded(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class VisitSoapRecorded extends VisitDetailEvent {
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
  final bool autoSign;

  const VisitSoapRecorded({
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
    this.autoSign = true,
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
        autoSign,
      ];
}

class VisitAddendumAppended extends VisitDetailEvent {
  final String addendumText;
  final String veterinarianName;

  const VisitAddendumAppended({
    required this.addendumText,
    required this.veterinarianName,
  });

  @override
  List<Object?> get props => [addendumText, veterinarianName];
}

class VisitMedicationAdministered extends VisitDetailEvent {
  final PrescriptionItem prescription;
  final String veterinarianName;
  final String? clinicalNotes;

  const VisitMedicationAdministered({
    required this.prescription,
    required this.veterinarianName,
    this.clinicalNotes,
  });

  @override
  List<Object?> get props => [prescription, veterinarianName, clinicalNotes];
}

class VisitSigned extends VisitDetailEvent {
  final String signedBy;

  const VisitSigned(this.signedBy);

  @override
  List<Object?> get props => [signedBy];
}

class VisitDetailsUpdated extends VisitDetailEvent {
  final String? title;
  final String? visitType;

  const VisitDetailsUpdated({
    this.title,
    this.visitType,
  });

  @override
  List<Object?> get props => [title, visitType];
}
