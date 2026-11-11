import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/dose_administration_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/progress_note_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/visit_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/visit_detail_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/create_addendum_dialog.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/create_soap_note_sheet.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/dose_administration_card.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/immutable_addendum_card.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/soap_progress_card.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final now = DateTime(2026, 11, 11, 14, 0);

  final openVisit = VisitEntity(
    id: 'vis-open-1',
    caseId: 'case-101',
    patientId: 'pat-101',
    veterinarianId: 'vet-101',
    veterinarianName: 'Dr. Anna Stone',
    title: 'Consultation - Nov 11, 2026',
    visitType: 'consultation',
    status: 'open',
    isSigned: false,
    visitDate: now,
    createdAt: now,
    updatedAt: now,
  );

  final signedVisit = VisitEntity(
    id: 'vis-signed-1',
    caseId: 'case-101',
    patientId: 'pat-101',
    veterinarianId: 'vet-101',
    veterinarianName: 'Dr. Anna Stone',
    title: 'Follow-up Visit - Nov 11, 2026',
    visitType: 'follow_up',
    status: 'signed',
    isSigned: true,
    signedAt: now,
    signedBy: 'Dr. Anna Stone',
    visitDate: now,
    createdAt: now,
    updatedAt: now,
    soapNote: ProgressNoteEntity(
      id: 'soap-1',
      visitId: 'vis-signed-1',
      caseId: 'case-101',
      patientId: 'pat-101',
      veterinarianId: 'vet-101',
      veterinarianName: 'Dr. Anna Stone',
      subjective: 'Patient alert and responsive',
      objective: 'Lungs clear, HR regular',
      assessment: 'Recovering well',
      plan: 'Continue bland diet for 2 days',
      temperatureCelsius: 38.6,
      heartRateBpm: 104,
      recordedAt: now,
      createdAt: now,
    ),
    doseAdministrations: [
      DoseAdministrationEntity(
        id: 'dose-1',
        visitId: 'vis-signed-1',
        caseId: 'case-101',
        patientId: 'pat-101',
        medicineName: 'Amoxicillin Trihydrate',
        doseQuantity: '1.5',
        unit: 'ml',
        route: 'SQ (Subcutaneous)',
        clinicalNotes: 'First dose given',
        veterinarianId: 'vet-101',
        veterinarianName: 'Dr. Anna Stone',
        administeredAt: now,
        createdAt: now,
      ),
    ],
    addenda: [
      ProgressNoteEntity(
        id: 'add-1',
        visitId: 'vis-signed-1',
        caseId: 'case-101',
        patientId: 'pat-101',
        veterinarianId: 'vet-101',
        veterinarianName: 'Dr. Anna Stone',
        noteType: 'addendum',
        assessment: 'Owner called 2 hours later to confirm patient drank water without nausea.',
        recordedAt: now.add(const Duration(hours: 2)),
        createdAt: now.add(const Duration(hours: 2)),
      ),
    ],
  );

  setUp(() {
    mockRepo = MockCaseRepository();
  });

  group('VisitDetailScreen Widget Tests', () {
    testWidgets('Open Visit State: shows Record SOAP Exam and hides Append Addendum', (tester) async {
      when(() => mockRepo.watchVisitDetail('vis-open-1'))
          .thenAnswer((_) => Stream.value(openVisit));

      await tester.pumpWidget(
        MaterialApp(
          home: VisitDetailScreen(
            caseId: 'case-101',
            visitId: 'vis-open-1',
            caseRepository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Consultation - Nov 11, 2026'), findsWidgets);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Record SOAP Exam'), findsOneWidget);
      expect(find.text('Administer Dose'), findsOneWidget);
      expect(find.text('Append Addendum'), findsNothing);
      expect(find.text('No SOAP Exam Recorded Yet'), findsOneWidget);

      // Tap Record SOAP Exam
      await tester.tap(find.text('Record SOAP Exam'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateSoapNoteSheet), findsOneWidget);
    });

    testWidgets('Signed Visit State: locks visit, hides Record SOAP Exam, and shows Append Addendum', (tester) async {
      when(() => mockRepo.watchVisitDetail('vis-signed-1'))
          .thenAnswer((_) => Stream.value(signedVisit));

      await tester.pumpWidget(
        MaterialApp(
          home: VisitDetailScreen(
            caseId: 'case-101',
            visitId: 'vis-signed-1',
            caseRepository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Follow-up Visit - Nov 11, 2026'), findsWidgets);
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.text('Signed & Finalized'), findsOneWidget);

      // "Record SOAP Exam" must be hidden
      expect(find.text('Record SOAP Exam'), findsNothing);

      // "Append Addendum" must be visible
      expect(find.text('Append Addendum'), findsOneWidget);
      expect(find.text('Administer Dose'), findsOneWidget);

      // Scoped content verification
      expect(find.byType(SoapProgressCard), findsOneWidget);
      expect(find.text('SOAP PROGRESS NOTE'), findsOneWidget);
      expect(find.text('Patient alert and responsive'), findsOneWidget);

      expect(find.byType(DoseAdministrationCard), findsOneWidget);
      expect(find.text('Amoxicillin Trihydrate'), findsOneWidget);
      expect(find.text('1.5 ml'), findsOneWidget);

      expect(find.byType(ImmutableAddendumCard), findsOneWidget);
      expect(find.text('IMMUTABLE ADDENDUM'), findsOneWidget);
      expect(find.textContaining('Owner called 2 hours later'), findsOneWidget);

      // Tap Append Addendum
      await tester.tap(find.text('Append Addendum'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAddendumDialog), findsOneWidget);
    });

    testWidgets('Open visit allows editing visit title and type via edit button in AppBar', (tester) async {
      when(() => mockRepo.watchVisitDetail('vis-open-1'))
          .thenAnswer((_) => Stream.value(openVisit));
      when(() => mockRepo.updateVisitDetails(
            visitId: 'vis-open-1',
            title: any(named: 'title'),
            visitType: any(named: 'visitType'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VisitDetailScreen(
            caseId: 'case-101',
            visitId: 'vis-open-1',
            caseRepository: mockRepo,
            initialVisit: openVisit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editBtn = find.byTooltip('Edit Visit');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Edit Visit Details'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
