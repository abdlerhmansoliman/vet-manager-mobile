import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/progress_note_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/visit_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/case_detail_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/visit_detail_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/start_visit_sheet.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/visit_card.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final now = DateTime(2026, 10, 24, 15, 0);

  final sampleSummary = CaseSummaryEntity(
    id: 'case-test-1',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-2026-0042',
    patientId: 'pat-101',
    patientName: 'Rusty',
    species: 'Canine',
    breed: 'Golden Retriever',
    ageFormatted: '5 yrs',
    currentWeightKg: 31.5,
    clientId: 'cl-101',
    clientName: 'John Smith',
    clientPhone: '555-9999',
    primaryVeterinarianId: 'vet-1',
    primaryVeterinarianName: 'Dr. Anna Stone',
    priority: 'urgent',
    status: 'open',
    chiefComplaint: 'Dyspnea and acute respiratory distress',
    provisionalDiagnosis: 'Congestive Heart Failure',
    finalDiagnosis: 'Dilated Cardiomyopathy',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final sampleVisit = VisitEntity(
    id: 'vis-test-1',
    caseId: 'case-test-1',
    patientId: 'pat-101',
    veterinarianId: 'vet-1',
    veterinarianName: 'Dr. Anna Stone',
    title: 'Follow-up Visit - Nov 11, 2026',
    visitType: 'follow_up',
    status: 'open',
    isSigned: false,
    visitDate: now,
    createdAt: now,
    updatedAt: now,
    soapNote: ProgressNoteEntity(
      id: 'note-1',
      visitId: 'vis-test-1',
      caseId: 'case-test-1',
      patientId: 'pat-101',
      veterinarianId: 'vet-1',
      veterinarianName: 'Dr. Anna Stone',
      subjective: 'Owner reports rapid breathing while resting',
      temperatureCelsius: 38.6,
      heartRateBpm: 144,
      recordedAt: now,
      createdAt: now,
    ),
  );

  final sampleDetail = CaseDetailEntity(
    summary: sampleSummary,
    allergies: const ['Cephalexin'],
    diagnoses: const [],
    visits: [sampleVisit],
  );

  setUp(() {
    mockRepo = MockCaseRepository();
    when(() => mockRepo.watchCaseDetail('case-test-1'))
        .thenAnswer((_) => Stream.value(sampleDetail));
    when(() => mockRepo.watchVisitDetail('vis-test-1'))
        .thenAnswer((_) => Stream.value(sampleVisit));
  });

  testWidgets('CaseDetailScreen renders patient demographics, allergies, diagnoses, and Visits list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CAS-2026-0042'), findsOneWidget);
    expect(find.text('URGENT'), findsWidgets);
    expect(find.text('Rusty'), findsOneWidget);
    expect(find.text('Canine • Golden Retriever • 5 yrs'), findsOneWidget);
    expect(find.text('Weight: 31.5 kg'), findsOneWidget);
    expect(find.text('ALLERGIES: Cephalexin'), findsOneWidget);
    expect(find.text('John Smith • 555-9999'), findsOneWidget);

    expect(find.text('Triage Severity Level'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Urgent'), findsWidgets);
    expect(find.text('Critical'), findsOneWidget);

    expect(find.text('Encounter Status'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);

    expect(find.text('Chief Complaint'), findsOneWidget);
    expect(find.text('Dyspnea and acute respiratory distress'), findsOneWidget);

    expect(find.text('Congestive Heart Failure'), findsOneWidget);
    expect(find.text('Dilated Cardiomyopathy'), findsOneWidget);

    // Hierarchical Visits section
    expect(find.text('Clinical Visits & Encounters'), findsOneWidget);
    expect(find.text('Start New Visit'), findsOneWidget);
    expect(find.byType(VisitCard), findsOneWidget);
    expect(find.text('Follow-up Visit - Nov 11, 2026'), findsOneWidget);
    expect(find.text('ACTIVE ENCOUNTER'), findsOneWidget);
  });

  testWidgets('CaseDetailScreen priority switcher triggers repository update', (tester) async {
    when(() => mockRepo.updatePriority(
          caseId: 'case-test-1',
          priority: 'critical',
        )).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Critical priority pill
    await tester.tap(find.text('Critical'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.updatePriority(caseId: 'case-test-1', priority: 'critical')).called(1);
    expect(find.text('Triage priority updated to CRITICAL'), findsOneWidget);
  });

  testWidgets('CaseDetailScreen status switcher triggers repository update', (tester) async {
    when(() => mockRepo.updateStatus(
          caseId: 'case-test-1',
          status: 'in_progress',
        )).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap In Progress status pill
    await tester.tap(find.text('In Progress'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.updateStatus(caseId: 'case-test-1', status: 'in_progress')).called(1);
    expect(find.text('Status updated to IN PROGRESS'), findsOneWidget);
  });

  testWidgets('CaseDetailScreen edit diagnoses button opens update dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final diagBtn = find.byKey(const Key('edit_diagnoses_button'));
    await tester.ensureVisible(diagBtn);
    await tester.tap(diagBtn);
    await tester.pumpAndSettle();

    expect(find.text('Update Diagnoses'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('CaseDetailScreen edit chief complaint button opens edit dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ccBtn = find.byKey(const Key('edit_chief_complaint_button'));
    await tester.ensureVisible(ccBtn);
    await tester.tap(ccBtn);
    await tester.pumpAndSettle();

    expect(find.text('Edit Chief Complaint'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Tapping VisitCard navigates to VisitDetailScreen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(VisitCard));
    await tester.tap(find.byType(VisitCard));
    await tester.pumpAndSettle();

    expect(find.byType(VisitDetailScreen), findsOneWidget);
    expect(find.text('Follow-up Visit - Nov 11, 2026'), findsWidgets);
  });

  testWidgets('Tapping Start New Visit opens StartVisitSheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaseDetailScreen(
          caseId: 'case-test-1',
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start New Visit'));
    await tester.tap(find.text('Start New Visit'));
    await tester.pumpAndSettle();

    expect(find.byType(StartVisitSheet), findsOneWidget);
    expect(find.text('Start New Visit Encounter'), findsOneWidget);
    expect(find.text('Begin Visit Encounter'), findsOneWidget);
  });
}
