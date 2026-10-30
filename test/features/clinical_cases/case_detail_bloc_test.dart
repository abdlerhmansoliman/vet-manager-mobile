import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/progress_note_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/case_detail_bloc.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/case_detail_event.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/case_detail_state.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  final now = DateTime(2026, 10, 24);

  final sampleSummary = CaseSummaryEntity(
    id: 'case-det-1',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-DET-01',
    patientId: 'pat-1',
    patientName: 'Kona',
    species: 'Canine',
    clientId: 'cl-1',
    clientName: 'Daniel',
    clientPhone: '555-400',
    primaryVeterinarianId: 'vet-1',
    primaryVeterinarianName: 'Dr. John Doe',
    priority: 'urgent',
    chiefComplaint: 'Dyspnea and tachypnea',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final sampleDetail = CaseDetailEntity(
    summary: sampleSummary,
    allergies: const ['Cephalexin'],
    progressNotes: [
      ProgressNoteEntity(
        id: 'note-1',
        caseId: 'case-det-1',
        patientId: 'pat-1',
        veterinarianId: 'vet-1',
        veterinarianName: 'Dr. John Doe',
        subjective: 'Open mouth breathing',
        temperatureCelsius: 39.1,
        heartRateBpm: 140,
        respiratoryRateBpm: 48,
        recordedAt: now,
        createdAt: now,
      ),
    ],
    diagnoses: const [],
  );

  setUp(() {
    mockRepo = MockCaseRepository();
  });

  group('CaseDetailBloc', () {
    test('initial state is correct', () {
      final bloc = CaseDetailBloc(repository: mockRepo);
      expect(bloc.state.status, CaseDetailStatus.initial);
      expect(bloc.state.caseDetail, isNull);
    });

    blocTest<CaseDetailBloc, CaseDetailState>(
      'loads case detail via stream on CaseDetailLoaded',
      build: () {
        when(() => mockRepo.watchCaseDetail('case-det-1'))
            .thenAnswer((_) => Stream.value(sampleDetail));
        return CaseDetailBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const CaseDetailLoaded('case-det-1')),
      expect: () => [
        const CaseDetailState(status: CaseDetailStatus.loading),
        CaseDetailState(
          status: CaseDetailStatus.success,
          caseDetail: sampleDetail,
        ),
      ],
    );

    blocTest<CaseDetailBloc, CaseDetailState>(
      'updates triage priority on CasePriorityChanged',
      build: () {
        when(() => mockRepo.updatePriority(
              caseId: 'case-det-1',
              priority: 'critical',
            )).thenAnswer((_) async {});
        return CaseDetailBloc(repository: mockRepo);
      },
      seed: () => CaseDetailState(
        status: CaseDetailStatus.success,
        caseDetail: sampleDetail,
      ),
      act: (bloc) => bloc.add(const CasePriorityChanged('critical')),
      expect: () => [
        CaseDetailState(
          status: CaseDetailStatus.success,
          caseDetail: sampleDetail,
          actionFeedback: 'Triage priority updated to CRITICAL',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.updatePriority(caseId: 'case-det-1', priority: 'critical')).called(1);
      },
    );

    blocTest<CaseDetailBloc, CaseDetailState>(
      'records SOAP note on CaseSoapNoteAdded',
      build: () {
        when(() => mockRepo.addSoapNote(
              caseId: 'case-det-1',
              patientId: 'pat-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Doe',
              subjective: any(named: 'subjective'),
              objective: any(named: 'objective'),
              assessment: any(named: 'assessment'),
              plan: any(named: 'plan'),
              temperatureCelsius: any(named: 'temperatureCelsius'),
              heartRateBpm: any(named: 'heartRateBpm'),
              respiratoryRateBpm: any(named: 'respiratoryRateBpm'),
              bodyConditionScore: any(named: 'bodyConditionScore'),
              painScore: any(named: 'painScore'),
            )).thenAnswer((_) async => sampleDetail.progressNotes.first);
        return CaseDetailBloc(repository: mockRepo);
      },
      seed: () => CaseDetailState(
        status: CaseDetailStatus.success,
        caseDetail: sampleDetail,
      ),
      act: (bloc) => bloc.add(const CaseSoapNoteAdded(
        subjective: 'Mild improvement',
        temperatureCelsius: 38.8,
        heartRateBpm: 115,
      )),
      expect: () => [
        CaseDetailState(
          status: CaseDetailStatus.success,
          caseDetail: sampleDetail,
          actionFeedback: 'SOAP Examination Note recorded and signed',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.addSoapNote(
              caseId: 'case-det-1',
              patientId: 'pat-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Doe',
              subjective: 'Mild improvement',
              temperatureCelsius: 38.8,
              heartRateBpm: 115,
            )).called(1);
      },
    );

    blocTest<CaseDetailBloc, CaseDetailState>(
      'appends immutable addendum on CaseAddendumAdded',
      build: () {
        when(() => mockRepo.addAddendum(
              caseId: 'case-det-1',
              patientId: 'pat-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. Jane Smith',
              addendumText: 'Oxygen cage therapy initiated at 40% FiO2.',
            )).thenAnswer((_) async => ProgressNoteEntity(
              id: 'add-1',
              caseId: 'case-det-1',
              patientId: 'pat-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. Jane Smith',
              noteType: 'addendum',
              assessment: 'Oxygen cage therapy initiated at 40% FiO2.',
              recordedAt: now,
              createdAt: now,
            ));
        return CaseDetailBloc(repository: mockRepo);
      },
      seed: () => CaseDetailState(
        status: CaseDetailStatus.success,
        caseDetail: sampleDetail,
      ),
      act: (bloc) => bloc.add(const CaseAddendumAdded(
        addendumText: 'Oxygen cage therapy initiated at 40% FiO2.',
        veterinarianName: 'Dr. Jane Smith',
      )),
      expect: () => [
        CaseDetailState(
          status: CaseDetailStatus.success,
          caseDetail: sampleDetail,
          actionFeedback: 'Immutable Addendum signed and appended',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.addAddendum(
              caseId: 'case-det-1',
              patientId: 'pat-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. Jane Smith',
              addendumText: 'Oxygen cage therapy initiated at 40% FiO2.',
            )).called(1);
      },
    );
  });
}
