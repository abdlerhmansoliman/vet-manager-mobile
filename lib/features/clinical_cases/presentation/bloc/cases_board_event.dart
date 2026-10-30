import 'package:equatable/equatable.dart';
import '../../domain/entities/case_entity.dart';

abstract class CasesBoardEvent extends Equatable {
  const CasesBoardEvent();

  @override
  List<Object?> get props => [];
}

class CasesBoardStarted extends CasesBoardEvent {
  const CasesBoardStarted();
}

class CasesPriorityFilterChanged extends CasesBoardEvent {
  final String priority;

  const CasesPriorityFilterChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class CasesSearchQueryChanged extends CasesBoardEvent {
  final String query;

  const CasesSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class CasesUpdated extends CasesBoardEvent {
  final List<CaseSummaryEntity> cases;

  const CasesUpdated(this.cases);

  @override
  List<Object?> get props => [cases];
}
