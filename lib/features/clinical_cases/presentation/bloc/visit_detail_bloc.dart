import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/clinical_error_formatter.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/repositories/case_repository.dart';
import 'visit_detail_event.dart';
import 'visit_detail_state.dart';

class VisitDetailBloc extends Bloc<VisitDetailEvent, VisitDetailState> {
  final ICaseRepository _repository;

  VisitDetailBloc({required ICaseRepository repository})
      : _repository = repository,
        super(const VisitDetailState()) {
    on<VisitDetailLoaded>(_onLoaded);
    on<VisitSoapRecorded>(_onSoapRecorded);
    on<VisitAddendumAppended>(_onAddendumAppended);
    on<VisitMedicationAdministered>(_onMedicationAdministered);
    on<VisitSigned>(_onSigned);
    on<VisitDetailsUpdated>(_onDetailsUpdated);
  }

  Future<void> _onLoaded(
    VisitDetailLoaded event,
    Emitter<VisitDetailState> emit,
  ) async {
    emit(state.copyWith(status: VisitDetailStatus.loading, clearFeedback: true, clearError: true));
    await emit.forEach<VisitEntity?>(
      _repository.watchVisitDetail(event.visitId),
      onData: (visit) {
        if (visit == null) {
          return state.copyWith(
            status: VisitDetailStatus.failure,
            errorMessage: 'Clinical visit encounter not found',
          );
        }
        return state.copyWith(
          status: VisitDetailStatus.success,
          visit: visit,
          clearFeedback: true,
          clearError: true,
        );
      },
      onError: (Object error, StackTrace stackTrace) => state.copyWith(
        status: VisitDetailStatus.failure,
        errorMessage: ClinicalErrorFormatter.format(
          error,
          fallbackMessage: 'Clinical visit encounter not found.',
        ),
      ),
    );
  }

  Future<void> _onSoapRecorded(
    VisitSoapRecorded event,
    Emitter<VisitDetailState> emit,
  ) async {
    final visit = state.visit;
    if (visit == null) return;
    try {
      final vetName = event.veterinarianName ?? visit.veterinarianName;
      await _repository.addSoapNote(
        caseId: visit.caseId,
        visitId: visit.id,
        patientId: visit.patientId,
        veterinarianId: visit.veterinarianId,
        veterinarianName: vetName,
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

      if (event.autoSign) {
        await _repository.signVisit(
          visitId: visit.id,
          signedBy: vetName,
        );
        emit(state.copyWith(
          actionFeedback: 'SOAP Examination Note recorded and signed. Encounter locked.',
        ));
      } else {
        emit(state.copyWith(
          actionFeedback: 'SOAP Examination Note recorded.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: ClinicalErrorFormatter.format(
          e,
          fallbackMessage: 'Failed to record SOAP note. Please try again.',
        ),
      ));
    }
  }

  Future<void> _onAddendumAppended(
    VisitAddendumAppended event,
    Emitter<VisitDetailState> emit,
  ) async {
    final visit = state.visit;
    if (visit == null) return;
    try {
      await _repository.addAddendum(
        caseId: visit.caseId,
        visitId: visit.id,
        patientId: visit.patientId,
        veterinarianId: visit.veterinarianId,
        veterinarianName: event.veterinarianName,
        addendumText: event.addendumText,
      );
      emit(state.copyWith(
        actionFeedback: 'Immutable Addendum signed and appended.',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: ClinicalErrorFormatter.format(
          e,
          fallbackMessage: 'Failed to append addendum. Please try again.',
        ),
      ));
    }
  }

  Future<void> _onMedicationAdministered(
    VisitMedicationAdministered event,
    Emitter<VisitDetailState> emit,
  ) async {
    final visit = state.visit;
    if (visit == null) return;
    try {
      await _repository.administerMedication(
        visitId: visit.id,
        caseId: visit.caseId,
        patientId: visit.patientId,
        medicineName: event.prescription.medicineName,
        doseQuantity: event.prescription.doseQuantity,
        unit: event.prescription.unit,
        route: event.prescription.route,
        clinicalNotes: event.clinicalNotes,
        veterinarianId: visit.veterinarianId,
        veterinarianName: event.veterinarianName,
      );
      emit(state.copyWith(
        actionFeedback: 'Administered ${event.prescription.doseQuantity} ${event.prescription.unit} ${event.prescription.medicineName}',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: ClinicalErrorFormatter.format(
          e,
          fallbackMessage: 'Failed to record administered medication. Please try again.',
        ),
      ));
    }
  }

  Future<void> _onSigned(
    VisitSigned event,
    Emitter<VisitDetailState> emit,
  ) async {
    final visit = state.visit;
    if (visit == null) return;
    try {
      await _repository.signVisit(
        visitId: visit.id,
        signedBy: event.signedBy,
      );
      emit(state.copyWith(
        actionFeedback: 'Encounter formally signed and locked.',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: ClinicalErrorFormatter.format(
          e,
          fallbackMessage: 'Failed to sign visit. Please try again.',
        ),
      ));
    }
  }

  Future<void> _onDetailsUpdated(
    VisitDetailsUpdated event,
    Emitter<VisitDetailState> emit,
  ) async {
    final visit = state.visit;
    if (visit == null) return;
    try {
      await _repository.updateVisitDetails(
        visitId: visit.id,
        title: event.title,
        visitType: event.visitType,
      );
      emit(state.copyWith(
        actionFeedback: 'Visit details updated successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: ClinicalErrorFormatter.format(
          e,
          fallbackMessage: 'Failed to update visit details. Please try again.',
        ),
      ));
    }
  }
}
