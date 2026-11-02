import '../../../../core/errors/clinical_error_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import 'cases_board_event.dart';
import 'cases_board_state.dart';

class CasesBoardBloc extends Bloc<CasesBoardEvent, CasesBoardState> {
  final ICaseRepository _repository;

  CasesBoardBloc({required ICaseRepository repository})
      : _repository = repository,
        super(const CasesBoardState()) {
    on<CasesBoardStarted>(_onStarted);
    on<CasesPriorityFilterChanged>(_onPriorityFilterChanged);
    on<CasesSearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onStarted(
    CasesBoardStarted event,
    Emitter<CasesBoardState> emit,
  ) async {
    emit(state.copyWith(status: CasesBoardStatus.loading));
    await emit.forEach<List<CaseSummaryEntity>>(
      _repository.watchCases(query: state.searchQuery),
      onData: (casesList) => state.copyWith(
        status: CasesBoardStatus.success,
        cases: casesList,
      ),
      onError: (Object error, StackTrace stackTrace) => state.copyWith(
        status: CasesBoardStatus.failure,
        errorMessage: ClinicalErrorFormatter.format(error, fallbackMessage: 'Unable to load active triage board.'),
      ),
    );
  }

  void _onPriorityFilterChanged(
    CasesPriorityFilterChanged event,
    Emitter<CasesBoardState> emit,
  ) {
    emit(state.copyWith(activePriority: event.priority));
  }

  Future<void> _onSearchQueryChanged(
    CasesSearchQueryChanged event,
    Emitter<CasesBoardState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      status: CasesBoardStatus.loading,
    ));
    await emit.forEach<List<CaseSummaryEntity>>(
      _repository.watchCases(query: event.query),
      onData: (casesList) => state.copyWith(
        status: CasesBoardStatus.success,
        cases: casesList,
      ),
      onError: (Object error, StackTrace stackTrace) => state.copyWith(
        status: CasesBoardStatus.failure,
        errorMessage: ClinicalErrorFormatter.format(error, fallbackMessage: 'Unable to load active triage board.'),
      ),
    );
  }
}
