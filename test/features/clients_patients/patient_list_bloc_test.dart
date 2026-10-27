import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/bloc/patient_list_bloc.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/bloc/patient_list_event.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/bloc/patient_list_state.dart';

class MockPatientRepository extends Mock implements IPatientRepository {}

void main() {
  late MockPatientRepository mockRepository;

  const sampleClient = ClientSummaryEntity(
    id: 'client-1',
    tenantId: 'tenant-1',
    clientType: 'individual',
    name: 'Emily Thorne',
    phonePrimary: '+1-555-0199',
  );

  final samplePatientDog = PatientEntity(
    id: 'pat-1',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Sammy',
    species: 'Canine',
    breed: 'Golden Retriever',
    gender: 'male_neutered',
    age: 4,
    currentWeightKg: 28.5,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  final samplePatientCat = PatientEntity(
    id: 'pat-2',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Mochi',
    species: 'Feline',
    breed: 'Siamese',
    gender: 'female_spayed',
    age: 2,
    currentWeightKg: 4.2,
    createdAt: DateTime(2026, 1, 2),
    updatedAt: DateTime(2026, 1, 2),
    client: sampleClient,
  );

  setUp(() {
    mockRepository = MockPatientRepository();
  });

  group('PatientListBloc', () {
    test('initial state has initial status and empty patients', () {
      final bloc = PatientListBloc(repository: mockRepository);
      expect(bloc.state.status, equals(PatientListStatus.initial));
      expect(bloc.state.patients, isEmpty);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.selectedSpecies, equals('All'));
    });

    blocTest<PatientListBloc, PatientListState>(
      'emits [loading, success] when PatientListSubscriptionRequested succeeds',
      build: () {
        when(
          () => mockRepository.watchPatients(
            query: any(named: 'query'),
            speciesFilter: any(named: 'speciesFilter'),
          ),
        ).thenAnswer((_) => Stream.value([samplePatientDog, samplePatientCat]));
        return PatientListBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const PatientListSubscriptionRequested()),
      expect: () => [
        const PatientListState(status: PatientListStatus.loading),
        PatientListState(
          status: PatientListStatus.success,
          patients: [samplePatientDog, samplePatientCat],
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.watchPatients(
            query: '',
            speciesFilter: 'All',
          ),
        ).called(1);
      },
    );

    blocTest<PatientListBloc, PatientListState>(
      'emits [loading, success] with filtered query when PatientSearchQueryChanged is dispatched',
      build: () {
        when(
          () => mockRepository.watchPatients(
            query: 'Sammy',
            speciesFilter: 'All',
          ),
        ).thenAnswer((_) => Stream.value([samplePatientDog]));
        return PatientListBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const PatientSearchQueryChanged('Sammy')),
      expect: () => [
        const PatientListState(
          status: PatientListStatus.loading,
          searchQuery: 'Sammy',
          selectedSpecies: 'All',
        ),
        PatientListState(
          status: PatientListStatus.success,
          searchQuery: 'Sammy',
          selectedSpecies: 'All',
          patients: [samplePatientDog],
        ),
      ],
    );

    blocTest<PatientListBloc, PatientListState>(
      'emits [loading, success] with species filter when PatientSpeciesFilterChanged is dispatched',
      build: () {
        when(
          () => mockRepository.watchPatients(
            query: '',
            speciesFilter: 'Feline',
          ),
        ).thenAnswer((_) => Stream.value([samplePatientCat]));
        return PatientListBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const PatientSpeciesFilterChanged('Feline')),
      expect: () => [
        const PatientListState(
          status: PatientListStatus.loading,
          searchQuery: '',
          selectedSpecies: 'Feline',
        ),
        PatientListState(
          status: PatientListStatus.success,
          searchQuery: '',
          selectedSpecies: 'Feline',
          patients: [samplePatientCat],
        ),
      ],
    );

    blocTest<PatientListBloc, PatientListState>(
      'emits [loading, failure] when repository stream yields an error',
      build: () {
        when(
          () => mockRepository.watchPatients(
            query: any(named: 'query'),
            speciesFilter: any(named: 'speciesFilter'),
          ),
        ).thenAnswer((_) => Stream.error(Exception('SQLite lock timeout')));
        return PatientListBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const PatientListSubscriptionRequested()),
      expect: () => [
        const PatientListState(status: PatientListStatus.loading),
        const PatientListState(
          status: PatientListStatus.failure,
          errorMessage: 'Exception: SQLite lock timeout',
        ),
      ],
    );
  });
}
