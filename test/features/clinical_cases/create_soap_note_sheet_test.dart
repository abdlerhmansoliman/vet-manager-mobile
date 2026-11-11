import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/prescription_item.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/create_soap_note_sheet.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestSheet({
    required void Function({
      String? subjective,
      String? objective,
      String? assessment,
      String? plan,
      double? temperatureCelsius,
      int? heartRateBpm,
      int? respiratoryRateBpm,
      int? bodyConditionScore,
      int? painScore,
      String? vetName,
      List<PrescriptionItem>? prescriptions,
    }) onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CreateSoapNoteSheet.show(
                  context: context,
                  defaultVetName: 'Dr. John Doe, DVM',
                  onConfirm: onConfirm,
                );
              },
              child: const Text('Open SOAP Sheet'),
            );
          },
        ),
      ),
    );
  }

  group('CreateSoapNoteSheet Widget Tests', () {
    testWidgets('renders all SOAP sections and medication prescription builder', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestSheet(onConfirm: ({
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        vetName,
        prescriptions,
      }) {}));

      // Open sheet
      await tester.tap(find.text('Open SOAP Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Record SOAP Progress Note'), findsOneWidget);
      expect(find.text('Attending Veterinarian'), findsOneWidget);
      expect(find.text('Prescribe Medication / Treatment'), findsOneWidget);
      expect(find.text('+ Add Medication to Plan'), findsOneWidget);
      expect(find.text('Save & Sign SOAP Note'), findsOneWidget);
    });

    testWidgets('adds a medication with custom dose, unit, route, and displays in prescriptions list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestSheet(onConfirm: ({
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        vetName,
        prescriptions,
      }) {}));

      await tester.tap(find.text('Open SOAP Sheet'));
      await tester.pumpAndSettle();

      // Enter Medicine name in Autocomplete field
      final medicineSearchFinder = find.widgetWithText(TextFormField, 'Search or enter medication name (e.g. Meloxicam)...');
      await tester.ensureVisible(medicineSearchFinder);
      expect(medicineSearchFinder, findsOneWidget);
      await tester.enterText(medicineSearchFinder, 'Meloxicam 1.5mg/ml');
      await tester.pumpAndSettle();

      // Enter Dose quantity
      final doseFinder = find.widgetWithText(TextFormField, 'e.g. 2.5 or 250');
      await tester.ensureVisible(doseFinder);
      expect(doseFinder, findsOneWidget);
      await tester.enterText(doseFinder, '2.5');
      await tester.pumpAndSettle();

      // Tap + Add Medication to Plan
      final addButtonFinder = find.text('+ Add Medication to Plan');
      await tester.ensureVisible(addButtonFinder);
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      // Verify medication is added to the list
      expect(find.text('Prescriptions to Record'), findsOneWidget);
      expect(find.text('Meloxicam 1.5mg/ml'), findsOneWidget);
      expect(find.textContaining('2.5 ml'), findsOneWidget);
    });

    testWidgets('shows validation error when adding medication without name or dose', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestSheet(onConfirm: ({
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        vetName,
        prescriptions,
      }) {}));

      await tester.tap(find.text('Open SOAP Sheet'));
      await tester.pumpAndSettle();

      // Tap Add without entering name or dose
      final addButtonFinder = find.text('+ Add Medication to Plan');
      await tester.ensureVisible(addButtonFinder);
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please select or enter a medicine name'), findsOneWidget);
    });

    testWidgets('removes a prescribed medication from list upon tapping remove button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestSheet(onConfirm: ({
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        vetName,
        prescriptions,
      }) {}));

      await tester.tap(find.text('Open SOAP Sheet'));
      await tester.pumpAndSettle();

      // Enter medicine and dose
      final medFinder = find.widgetWithText(TextFormField, 'Search or enter medication name (e.g. Meloxicam)...');
      await tester.ensureVisible(medFinder);
      await tester.enterText(medFinder, 'Amoxicillin 250mg');

      final doseFinder = find.widgetWithText(TextFormField, 'e.g. 2.5 or 250');
      await tester.ensureVisible(doseFinder);
      await tester.enterText(doseFinder, '1');

      final addButtonFinder = find.text('+ Add Medication to Plan');
      await tester.ensureVisible(addButtonFinder);
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Amoxicillin 250mg'), findsOneWidget);

      // Tap remove button
      final removeFinder = find.byTooltip('Remove');
      await tester.ensureVisible(removeFinder);
      await tester.tap(removeFinder);
      await tester.pumpAndSettle();

      expect(find.text('Amoxicillin 250mg'), findsNothing);
      expect(find.text('Prescriptions to Record'), findsNothing);
    });

    testWidgets('submitting form formats prescriptions and orders into Plan field for onConfirm', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? capturedPlan;
      List<PrescriptionItem>? capturedPrescriptions;

      await tester.pumpWidget(buildTestSheet(onConfirm: ({
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        vetName,
        prescriptions,
      }) {
        capturedPlan = plan;
        capturedPrescriptions = prescriptions;
      }));

      await tester.tap(find.text('Open SOAP Sheet'));
      await tester.pumpAndSettle();

      // Add medication
      final medFinder = find.widgetWithText(TextFormField, 'Search or enter medication name (e.g. Meloxicam)...');
      await tester.ensureVisible(medFinder);
      await tester.enterText(medFinder, 'Carprofen');

      final doseFinder = find.widgetWithText(TextFormField, 'e.g. 2.5 or 250');
      await tester.ensureVisible(doseFinder);
      await tester.enterText(doseFinder, '75');

      final addButtonFinder = find.text('+ Add Medication to Plan');
      await tester.ensureVisible(addButtonFinder);
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      // Submit form
      final submitFinder = find.text('Save & Sign SOAP Note');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(capturedPlan, contains('Rx Prescriptions:'));
      expect(capturedPlan, contains('• Carprofen: 75 ml'));
      expect(capturedPrescriptions, isNotNull);
      expect(capturedPrescriptions!.length, 1);
      expect(capturedPrescriptions!.first.medicineName, 'Carprofen');
      expect(capturedPrescriptions!.first.doseQuantity, '75');
    });
  });
}
