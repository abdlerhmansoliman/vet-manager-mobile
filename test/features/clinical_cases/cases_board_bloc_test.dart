import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/cases_board_bloc.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/cases_board_event.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/cases_board_state.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  final now = DateTime(2026, 10, 24);

  final sampleCaseRoutine = CaseSummaryEntity(
    id: 'c-routine',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-ROUTINE',
    patientId: 'pat-1',
    patientName: 'Bella',
    species: 'Canine',
    clientId: 'cl-1',
    clientName: 'Alice',
    clientPhone: '555-100',
    primaryVeterinarianId: 'vet-1',
    priority: 'routine',
    chiefComplaint: 'Booster vaccination',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final sampleCaseUrgent = CaseSummaryEntity(
    id: 'c-urgent',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-URGENT',
    patientId: 'pat-2',
    patientName: 'Milo',
    species: 'Feline',
    clientId: 'cl-2',
    clientName: 'Bob',
    clientPhone: '555-200',
    primaryVeterinarianId: 'vet-1',
    priority: 'urgent',
    chiefComplaint: 'Corneal ulcer',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final sampleCaseCritical = CaseSummaryEntity(
    id: 'c-critical',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-CRITICAL',
    patientId: 'pat-3',
    patientName: 'Thor',
    species: 'Canine',
    clientId: 'cl-3',
    clientName: 'Charlie',
    clientPhone: '555-300',
    primaryVeterinarianId: 'vet-1',
    priority: 'critical',
    chiefComplaint: 'Gastric Dilatation-Volvulus (GDV)',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final allCases = [sampleCaseCritical, sampleCaseUrgent, sampleCaseRoutine];

  setUp(() {
    mockRepo = MockCaseRepository();
  });

  group('CasesBoardBloc', () {
    test('initial state has default status and active priority all', () {
      final bloc = CasesBoardBloc(repository: mockRepo);
      expect(bloc.state.status, CasesBoardStatus.initial);
      expect(bloc.state.activePriority, 'all');
      expect(bloc.state.cases, isEmpty);
    });

    blocTest<CasesBoardBloc, CasesBoardState>(
      'emits [loading, success] with loaded cases on CasesBoardStarted',
      build: () {
        when(() => mockRepo.watchCases(query: any(named: 'query')))
            .thenAnswer((_) => Stream.value(allCases));
        return CasesBoardBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CasesBoardStarted()),
      expect: () => [
        const CasesBoardState(status: CasesBoardStatus.loading),
        CasesBoardState(
          status: CasesBoardStatus.success,
          cases: allCases,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.criticalCount, 1);
        expect(bloc.state.urgentCount, 1);
        expect(bloc.state.routineCount, 1);
        expect(bloc.state.totalCount, 3);
      },
    );

    blocTest<CasesBoardBloc, CasesBoardState>(
      'filters displayed cases when priority filter changes',
      build: () {
        when(() => mockRepo.watchCases(query: any(named: 'query')))
            .thenAnswer((_) => Stream.value(allCases));
        return CasesBoardBloc(repository: mockRepo);
      },
      seed: () => CasesBoardState(
        status: CasesBoardStatus.success,
        cases: allCases,
      ),
      act: (bloc) => bloc.add(const CasesPriorityFilterChanged('critical')),
      expect: () => [
        CasesBoardState(
          status: CasesBoardStatus.success,
          cases: allCases,
          activePriority: 'critical',
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.displayedCases.length, 1);
        expect(bloc.state.displayedCases.first.id, 'c-critical');
      },
    );

    blocTest<CasesBoardBloc, CasesBoardState>(
      're-fetches cases with query on CasesSearchQueryChanged',
      build: () {
        when(() => mockRepo.watchCases(query: 'ulcer'))
            .thenAnswer((_) => Stream.value([sampleCaseUrgent]));
        return CasesBoardBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CasesSearchQueryChanged('ulcer')),
      expect: () => [
        const CasesBoardState(
          status: CasesBoardStatus.loading,
          searchQuery: 'ulcer',
        ),
        CasesBoardState(
          status: CasesBoardStatus.success,
          cases: [sampleCaseUrgent],
          searchQuery: 'ulcer',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.watchCases(query: 'ulcer')).called(1);
      },
    );
  });
}
