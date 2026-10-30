import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/progress_note_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/create_addendum_dialog.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/create_soap_note_sheet.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/soap_notes_view.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final now = DateTime(2026, 10, 24, 14, 30);

  final sampleSoapNote = ProgressNoteEntity(
    id: 'soap-1',
    caseId: 'case-1',
    patientId: 'pat-1',
    veterinarianId: 'vet-1',
    veterinarianName: 'Dr. Jane Smith',
    noteType: 'soap',
    subjective: 'Patient presented with intermittent lethargy and reduced appetite for 2 days.',
    objective: 'Abdomen slightly tense cranial quadrant. Mucous membranes pink, CRT < 2s.',
    assessment: 'Mild acute gastritis or dietary indiscretion. Low suspicion of obstruction.',
    plan: 'Famotidine 0.5mg/kg PO q24h, bland diet (boiled chicken & rice) for 3 days.',
    temperatureCelsius: 38.7,
    heartRateBpm: 112,
    respiratoryRateBpm: 26,
    bodyConditionScore: 5,
    painScore: 1,
    recordedAt: now,
    createdAt: now,
  );

  final sampleAddendum = ProgressNoteEntity(
    id: 'add-1',
    caseId: 'case-1',
    patientId: 'pat-1',
    veterinarianId: 'vet-1',
    veterinarianName: 'Dr. Jane Smith',
    noteType: 'addendum',
    assessment: 'CBC and biochemistry panel returned normal. Amylase and lipase within reference intervals.',
    recordedAt: now.add(const Duration(hours: 2)),
    createdAt: now.add(const Duration(hours: 2)),
  );

  testWidgets('SoapNotesView renders empty state when no notes exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoapNotesView(
              notes: const [],
              onAddSoapNote: ({
                assessment,
                bodyConditionScore,
                heartRateBpm,
                objective,
                painScore,
                plan,
                respiratoryRateBpm,
                subjective,
                temperatureCelsius,
                vetName,
              }) {},
              onAddAddendum: (text, vetName) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clinical Progress Notes'), findsOneWidget);
    expect(find.text('No Examination Notes Yet'), findsOneWidget);
    expect(find.text('Record SOAP Exam'), findsOneWidget);
    expect(find.text('Append Addendum'), findsOneWidget);
  });

  testWidgets('SoapNotesView renders SOAP examination notes and vitals chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoapNotesView(
              notes: [sampleSoapNote],
              onAddSoapNote: ({
                assessment,
                bodyConditionScore,
                heartRateBpm,
                objective,
                painScore,
                plan,
                respiratoryRateBpm,
                subjective,
                temperatureCelsius,
                vetName,
              }) {},
              onAddAddendum: (text, vetName) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOAP PROGRESS NOTE'), findsOneWidget);
    expect(find.text('S: Subjective'), findsOneWidget);
    expect(find.text('O: Objective'), findsOneWidget);
    expect(find.text('A: Assessment'), findsOneWidget);
    expect(find.text('P: Plan'), findsOneWidget);

    // Verify vitals
    expect(find.text('38.7°C'), findsOneWidget);
    expect(find.text('112 bpm'), findsOneWidget);
    expect(find.text('26 bpm'), findsOneWidget);
    expect(find.text('5/9'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);

    expect(find.text('Dr. Jane Smith'), findsOneWidget);
  });

  testWidgets('SoapNotesView renders immutable addendum card with lock badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoapNotesView(
              notes: [sampleAddendum],
              onAddSoapNote: ({
                assessment,
                bodyConditionScore,
                heartRateBpm,
                objective,
                painScore,
                plan,
                respiratoryRateBpm,
                subjective,
                temperatureCelsius,
                vetName,
              }) {},
              onAddAddendum: (text, vetName) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('IMMUTABLE ADDENDUM'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.textContaining('CBC and biochemistry panel returned normal'), findsOneWidget);
    expect(find.text('Signed by Dr. Jane Smith'), findsOneWidget);
  });

  testWidgets('SoapNotesView button opens CreateAddendumDialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoapNotesView(
              notes: [sampleSoapNote],
              defaultVetName: 'Dr. Jane Smith',
              onAddSoapNote: ({
                assessment,
                bodyConditionScore,
                heartRateBpm,
                objective,
                painScore,
                plan,
                respiratoryRateBpm,
                subjective,
                temperatureCelsius,
                vetName,
              }) {},
              onAddAddendum: (text, vetName) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Append Addendum'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateAddendumDialog), findsOneWidget);
    expect(find.text('Append Clinical Addendum'), findsOneWidget);
    expect(find.text('IMMUTABLE MEDICAL RECORD'), findsOneWidget);
    expect(find.text('Sign & Append'), findsOneWidget);
  });

  testWidgets('SoapNotesView button opens CreateSoapNoteSheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoapNotesView(
              notes: const [],
              defaultVetName: 'Dr. Jane Smith',
              onAddSoapNote: ({
                assessment,
                bodyConditionScore,
                heartRateBpm,
                objective,
                painScore,
                plan,
                respiratoryRateBpm,
                subjective,
                temperatureCelsius,
                vetName,
              }) {},
              onAddAddendum: (text, vetName) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record SOAP Exam'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateSoapNoteSheet), findsOneWidget);
    expect(find.text('Record SOAP Progress Note'), findsOneWidget);
    expect(find.text('Save & Sign SOAP Note'), findsOneWidget);
  });
}
