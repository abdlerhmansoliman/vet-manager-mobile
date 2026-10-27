import 'package:equatable/equatable.dart';

/// Events processed by [PatientListBloc].
abstract class PatientListEvent extends Equatable {
  const PatientListEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the patient list screen mounts and begins watching repository changes.
class PatientListSubscriptionRequested extends PatientListEvent {
  const PatientListSubscriptionRequested();
}

/// Dispatched when the user types in the search bar.
class PatientSearchQueryChanged extends PatientListEvent {
  final String query;
  const PatientSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Dispatched when a clinician taps a species filter chip (e.g. All, Canine, Feline, Equine, Bovine).
class PatientSpeciesFilterChanged extends PatientListEvent {
  final String species;
  const PatientSpeciesFilterChanged(this.species);

  @override
  List<Object?> get props => [species];
}
