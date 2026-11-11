import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/dose_administration_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/prescription_item.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/progress_note_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/visit_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/visit_detail_bloc.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/visit_detail_event.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/bloc/visit_detail_state.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  final now = DateTime(2026, 11, 11, 10, 0);

  final sampleVisit = VisitEntity(
    id: 'vis-101',
    caseId: 'case-101',
    patientId: 'pat-101',
    veterinarianId: 'vet-101',
    veterinarianName: 'Dr. Jane Smith',
    title: 'Follow-up Visit - Nov 11, 2026',
    visitType: 'follow_up',
    status: 'open',
    isSigned: false,
    visitDate: now,
    createdAt: now,
    updatedAt: now,
  );

  final signedVisit = sampleVisit.copyWith(
    isSigned: true,
    status: 'signed',
    signedAt: now.add(const Duration(hours: 1)),
    signedBy: 'Dr. Jane Smith',
  );

  setUp(() {
    mockRepo = MockCaseRepository();
  });

  group('VisitDetailBloc', () {
    test('initial state is correct', () {
      final bloc = VisitDetailBloc(repository: mockRepo);
      expect(bloc.state.status, VisitDetailStatus.initial);
      expect(bloc.state.visit, isNull);
    });

    blocTest<VisitDetailBloc, VisitDetailState>(
      'loads visit details via stream on VisitDetailLoaded',
      build: () {
        when(() => mockRepo.watchVisitDetail('vis-101'))
            .thenAnswer((_) => Stream.value(sampleVisit));
        return VisitDetailBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const VisitDetailLoaded('vis-101')),
      expect: () => [
        const VisitDetailState(status: VisitDetailStatus.loading),
        VisitDetailState(
          status: VisitDetailStatus.success,
          visit: sampleVisit,
        ),
      ],
    );

    blocTest<VisitDetailBloc, VisitDetailState>(
      'records SOAP note and auto-signs visit on VisitSoapRecorded',
      build: () {
        when(() => mockRepo.addSoapNote(
              caseId: 'case-101',
              visitId: 'vis-101',
              patientId: 'pat-101',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
              subjective: 'Alert, eating well',
              objective: 'No signs of pain',
              temperatureCelsius: 38.5,
            )).thenAnswer((_) async => ProgressNoteEntity(
              id: 'soap-101',
              visitId: 'vis-101',
              caseId: 'case-101',
              patientId: 'pat-101',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
              subjective: 'Alert, eating well',
              objective: 'No signs of pain',
              temperatureCelsius: 38.5,
              recordedAt: now,
              createdAt: now,
            ));

        when(() => mockRepo.signVisit(
              visitId: 'vis-101',
              signedBy: 'Dr. Jane Smith',
            )).thenAnswer((_) async {});

        return VisitDetailBloc(repository: mockRepo);
      },
      seed: () => VisitDetailState(
        status: VisitDetailStatus.success,
        visit: sampleVisit,
      ),
      act: (bloc) => bloc.add(const VisitSoapRecorded(
        subjective: 'Alert, eating well',
        objective: 'No signs of pain',
        temperatureCelsius: 38.5,
        veterinarianName: 'Dr. Jane Smith',
        autoSign: true,
      )),
      expect: () => [
        VisitDetailState(
          status: VisitDetailStatus.success,
          visit: sampleVisit,
          actionFeedback: 'SOAP Examination Note recorded and signed. Encounter locked.',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.signVisit(visitId: 'vis-101', signedBy: 'Dr. Jane Smith')).called(1);
      },
    );

    blocTest<VisitDetailBloc, VisitDetailState>(
      'appends immutable addendum on VisitAddendumAppended',
      build: () {
        when(() => mockRepo.addAddendum(
              caseId: 'case-101',
              visitId: 'vis-101',
              patientId: 'pat-101',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
              addendumText: 'Re-checked vitals; patient stable.',
            )).thenAnswer((_) async => ProgressNoteEntity(
              id: 'add-101',
              visitId: 'vis-101',
              caseId: 'case-101',
              patientId: 'pat-101',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
              noteType: 'addendum',
              assessment: 'Re-checked vitals; patient stable.',
              recordedAt: now,
              createdAt: now,
            ));

        return VisitDetailBloc(repository: mockRepo);
      },
      seed: () => VisitDetailState(
        status: VisitDetailStatus.success,
        visit: signedVisit,
      ),
      act: (bloc) => bloc.add(const VisitAddendumAppended(
        addendumText: 'Re-checked vitals; patient stable.',
        veterinarianName: 'Dr. Jane Smith',
      )),
      expect: () => [
        VisitDetailState(
          status: VisitDetailStatus.success,
          visit: signedVisit,
          actionFeedback: 'Immutable Addendum signed and appended.',
        ),
      ],
    );

    blocTest<VisitDetailBloc, VisitDetailState>(
      'administers medication on VisitMedicationAdministered',
      build: () {
        when(() => mockRepo.administerMedication(
              visitId: 'vis-101',
              caseId: 'case-101',
              patientId: 'pat-101',
              medicineName: 'Amoxicillin',
              doseQuantity: '2.5',
              unit: 'ml',
              route: 'SQ (Subcutaneous)',
              clinicalNotes: 'Well tolerated',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
            )).thenAnswer((_) async => DoseAdministrationEntity(
              id: 'dose-101',
              visitId: 'vis-101',
              caseId: 'case-101',
              patientId: 'pat-101',
              medicineName: 'Amoxicillin',
              doseQuantity: '2.5',
              unit: 'ml',
              route: 'SQ (Subcutaneous)',
              clinicalNotes: 'Well tolerated',
              veterinarianId: 'vet-101',
              veterinarianName: 'Dr. Jane Smith',
              administeredAt: now,
              createdAt: now,
            ));

        return VisitDetailBloc(repository: mockRepo);
      },
      seed: () => VisitDetailState(
        status: VisitDetailStatus.success,
        visit: sampleVisit,
      ),
      act: (bloc) => bloc.add(const VisitMedicationAdministered(
        prescription: PrescriptionItem(
          medicineName: 'Amoxicillin',
          doseQuantity: '2.5',
          unit: 'ml',
          route: 'SQ (Subcutaneous)',
        ),
        veterinarianName: 'Dr. Jane Smith',
        clinicalNotes: 'Well tolerated',
      )),
      expect: () => [
        VisitDetailState(
          status: VisitDetailStatus.success,
          visit: sampleVisit,
          actionFeedback: 'Administered 2.5 ml Amoxicillin',
        ),
      ],
    );

    blocTest<VisitDetailBloc, VisitDetailState>(
      'signs and locks visit on VisitSigned',
      build: () {
        when(() => mockRepo.signVisit(
              visitId: 'vis-101',
              signedBy: 'Dr. Jane Smith',
            )).thenAnswer((_) async {});
        return VisitDetailBloc(repository: mockRepo);
      },
      seed: () => VisitDetailState(
        status: VisitDetailStatus.success,
        visit: sampleVisit,
      ),
      act: (bloc) => bloc.add(const VisitSigned('Dr. Jane Smith')),
      expect: () => [
        VisitDetailState(
          status: VisitDetailStatus.success,
          visit: sampleVisit,
          actionFeedback: 'Encounter formally signed and locked.',
        ),
      ],
    );
  });
}
