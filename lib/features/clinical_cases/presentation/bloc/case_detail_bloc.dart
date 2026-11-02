import '../../../../core/errors/clinical_error_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import 'case_detail_event.dart';
import 'case_detail_state.dart';

class CaseDetailBloc extends Bloc<CaseDetailEvent, CaseDetailState> {
  final ICaseRepository _repository;

  CaseDetailBloc({required ICaseRepository repository})
      : _repository = repository,
        super(const CaseDetailState()) {
    on<CaseDetailLoaded>(_onLoaded);
    on<CasePriorityChanged>(_onPriorityChanged);
    on<CaseStatusChanged>(_onStatusChanged);
    on<CaseSoapNoteAdded>(_onSoapNoteAdded);
    on<CaseAddendumAdded>(_onAddendumAdded);
    on<CaseDiagnosesUpdated>(_onDiagnosesUpdated);
  }

  Future<void> _onLoaded(
    CaseDetailLoaded event,
    Emitter<CaseDetailState> emit,
  ) async {
    emit(state.copyWith(status: CaseDetailStatus.loading));
    await emit.forEach<CaseDetailEntity?>(
      _repository.watchCaseDetail(event.caseId),
      onData: (detail) {
        if (detail == null) {
          return state.copyWith(
            status: CaseDetailStatus.failure,
            errorMessage: 'Clinical encounter not found',
          );
        }
        return state.copyWith(
          status: CaseDetailStatus.success,
          caseDetail: detail,
        );
      },
      onError: (Object error, StackTrace stackTrace) => state.copyWith(
        status: CaseDetailStatus.failure,
        errorMessage: ClinicalErrorFormatter.format(error, fallbackMessage: 'Clinical encounter not found.'),
      ),
    );
  }

  Future<void> _onPriorityChanged(
    CasePriorityChanged event,
    Emitter<CaseDetailState> emit,
  ) async {
    final detail = state.caseDetail;
    if (detail == null) return;
    try {
      await _repository.updatePriority(
        caseId: detail.summary.id,
        priority: event.newPriority,
      );
      emit(state.copyWith(
        actionFeedback: 'Triage priority updated to ${event.newPriority.toUpperCase()}',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update priority. Please try again.')));
    }
  }

  Future<void> _onStatusChanged(
    CaseStatusChanged event,
    Emitter<CaseDetailState> emit,
  ) async {
    final detail = state.caseDetail;
    if (detail == null) return;
    try {
      await _repository.updateStatus(
        caseId: detail.summary.id,
        status: event.newStatus,
      );
      emit(state.copyWith(
        actionFeedback: 'Status updated to ${event.newStatus.replaceAll("_", " ").toUpperCase()}',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update status. Please try again.')));
    }
  }

  Future<void> _onSoapNoteAdded(
    CaseSoapNoteAdded event,
    Emitter<CaseDetailState> emit,
  ) async {
    final detail = state.caseDetail;
    if (detail == null) return;
    try {
      await _repository.addSoapNote(
        caseId: detail.summary.id,
        patientId: detail.summary.patientId,
        veterinarianId: detail.summary.primaryVeterinarianId,
        veterinarianName: event.veterinarianName ?? detail.summary.primaryVeterinarianName ?? 'Attending Clinician',
        subjective: event.subjective,
        objective: event.objective,
        assessment: event.assessment,
        plan: event.plan,
        temperatureCelsius: event.temperatureCelsius,
        heartRateBpm: event.heartRateBpm,
        respiratoryRateBpm: event.respiratoryRateBpm,
        bodyConditionScore: event.bodyConditionScore,
        painScore: event.painScore,
      );
      emit(state.copyWith(
        actionFeedback: 'SOAP Examination Note recorded and signed',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to record SOAP note. Please try again.')));
    }
  }

  Future<void> _onAddendumAdded(
    CaseAddendumAdded event,
    Emitter<CaseDetailState> emit,
  ) async {
    final detail = state.caseDetail;
    if (detail == null) return;
    try {
      await _repository.addAddendum(
        caseId: detail.summary.id,
        patientId: detail.summary.patientId,
        veterinarianId: detail.summary.primaryVeterinarianId,
        veterinarianName: event.veterinarianName,
        addendumText: event.addendumText,
      );
      emit(state.copyWith(
        actionFeedback: 'Immutable Addendum signed and appended',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to append addendum. Please try again.')));
    }
  }

  Future<void> _onDiagnosesUpdated(
    CaseDiagnosesUpdated event,
    Emitter<CaseDetailState> emit,
  ) async {
    final detail = state.caseDetail;
    if (detail == null) return;
    try {
      await _repository.updateDiagnoses(
        caseId: detail.summary.id,
        provisionalDiagnosis: event.provisionalDiagnosis,
        finalDiagnosis: event.finalDiagnosis,
      );
      emit(state.copyWith(
        actionFeedback: 'Diagnoses updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update diagnoses. Please try again.')));
    }
  }
}
