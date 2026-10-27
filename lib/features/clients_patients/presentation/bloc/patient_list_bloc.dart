import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import 'patient_list_event.dart';
import 'patient_list_state.dart';

/// Predictable state management for Patients directory screen.
class PatientListBloc extends Bloc<PatientListEvent, PatientListState> {
  final IPatientRepository _repository;

  PatientListBloc({required IPatientRepository repository})
      : _repository = repository,
        super(const PatientListState()) {
    on<PatientListSubscriptionRequested>(_onSubscriptionRequested);
    on<PatientSearchQueryChanged>(_onSearchQueryChanged);
    on<PatientSpeciesFilterChanged>(_onSpeciesFilterChanged);
  }

  Future<void> _onSubscriptionRequested(
    PatientListSubscriptionRequested event,
    Emitter<PatientListState> emit,
  ) async {
    emit(state.copyWith(status: PatientListStatus.loading));
    await _subscribeToStream(emit);
  }

  Future<void> _onSearchQueryChanged(
    PatientSearchQueryChanged event,
    Emitter<PatientListState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      status: PatientListStatus.loading,
    ));
    await _subscribeToStream(emit);
  }

  Future<void> _onSpeciesFilterChanged(
    PatientSpeciesFilterChanged event,
    Emitter<PatientListState> emit,
  ) async {
    emit(state.copyWith(
      selectedSpecies: event.species,
      status: PatientListStatus.loading,
    ));
    await _subscribeToStream(emit);
  }

  Future<void> _subscribeToStream(Emitter<PatientListState> emit) async {
    await emit.forEach<List<PatientEntity>>(
      _repository.watchPatients(
        query: state.searchQuery,
        speciesFilter: state.selectedSpecies,
      ),
      onData: (patients) => state.copyWith(
        status: PatientListStatus.success,
        patients: patients,
      ),
      onError: (error, stackTrace) => state.copyWith(
        status: PatientListStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }
}
