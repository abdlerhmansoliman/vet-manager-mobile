import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/cases_board_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/case_card.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository mockRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final now = DateTime(2026, 10, 24);

  final sampleCaseCritical = CaseSummaryEntity(
    id: 'case-1',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-CRIT-01',
    patientId: 'pat-1',
    patientName: 'Atlas',
    species: 'Canine',
    breed: 'Rottweiler',
    ageFormatted: '4 yrs',
    currentWeightKg: 42.0,
    clientId: 'cl-1',
    clientName: 'Mark Vance',
    clientPhone: '555-1234',
    primaryVeterinarianId: 'vet-1',
    priority: 'critical',
    chiefComplaint: 'Heatstroke / collapse',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  final sampleCaseRoutine = CaseSummaryEntity(
    id: 'case-2',
    tenantId: 'tenant-1',
    caseNumber: 'CAS-ROUT-02',
    patientId: 'pat-2',
    patientName: 'Chloe',
    species: 'Feline',
    breed: 'Persian',
    ageFormatted: '2 yrs',
    currentWeightKg: 3.8,
    clientId: 'cl-2',
    clientName: 'Diana Prince',
    clientPhone: '555-5678',
    primaryVeterinarianId: 'vet-1',
    priority: 'routine',
    chiefComplaint: 'Nail trim and ear check',
    admittedAt: now,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepo = MockCaseRepository();
    when(() => mockRepo.watchCases(query: any(named: 'query')))
        .thenAnswer((_) => Stream.value([sampleCaseCritical, sampleCaseRoutine]));
  });

  testWidgets('CasesBoardScreen renders tabs, case cards, and priority badges', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CasesBoardScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Triage Board'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);

    expect(find.byType(CaseCard), findsNWidgets(2));
    expect(find.text('Atlas'), findsOneWidget);
    expect(find.text('Chloe'), findsOneWidget);
    expect(find.text('CAS-CRIT-01'), findsOneWidget);
    expect(find.text('CAS-ROUT-02'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('ROUTINE'), findsOneWidget);
  });

  testWidgets('CasesBoardScreen filters cases when tapping priority tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CasesBoardScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Critical filter tab
    await tester.tap(find.text('Critical'));
    await tester.pumpAndSettle();

    // Only Critical case should be displayed
    expect(find.text('Atlas'), findsOneWidget);
    expect(find.text('Chloe'), findsNothing);
    expect(find.byType(CaseCard), findsOneWidget);

    // Tap on Routine filter tab
    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();

    // Only Routine case should be displayed
    expect(find.text('Chloe'), findsOneWidget);
    expect(find.text('Atlas'), findsNothing);
    expect(find.byType(CaseCard), findsOneWidget);
  });

  testWidgets('CasesBoardScreen empty state displays when category has no cases', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CasesBoardScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Urgent (which has 0 cases in our test dataset)
    await tester.tap(find.text('Urgent'));
    await tester.pumpAndSettle();

    expect(find.text('No urgent cases'), findsOneWidget);
    expect(find.byType(CaseCard), findsNothing);
  });

  testWidgets('CasesBoardScreen FAB triggers triage new case dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CasesBoardScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Triage Case'));
    await tester.pumpAndSettle();

    expect(find.text('Triage New Encounter'), findsOneWidget);
    expect(find.text('Patient ID'), findsOneWidget);
    expect(find.text('Chief Complaint'), findsOneWidget);
    expect(find.text('Triage Priority'), findsOneWidget);
    expect(find.text('Open Case'), findsOneWidget);
  });
}
