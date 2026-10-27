import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';

enum PatientListStatus { initial, loading, success, failure }

/// State model for [PatientListBloc].
class PatientListState extends Equatable {
  final PatientListStatus status;
  final List<PatientEntity> patients;
  final String searchQuery;
  final String selectedSpecies;
  final String? errorMessage;

  const PatientListState({
    this.status = PatientListStatus.initial,
    this.patients = const [],
    this.searchQuery = '',
    this.selectedSpecies = 'All',
    this.errorMessage,
  });

  PatientListState copyWith({
    PatientListStatus? status,
    List<PatientEntity>? patients,
    String? searchQuery,
    String? selectedSpecies,
    String? errorMessage,
  }) {
    return PatientListState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        searchQuery,
        selectedSpecies,
        errorMessage,
      ];
}
