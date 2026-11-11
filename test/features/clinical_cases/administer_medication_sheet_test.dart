import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/prescription_item.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/widgets/administer_medication_sheet.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestSheet({
    required void Function({
      required PrescriptionItem prescription,
      required String veterinarianName,
      String? clinicalNotes,
    }) onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                AdministerMedicationSheet.show(
                  context: context,
                  defaultVetName: 'Dr. Jane Smith, DVM',
                  onConfirm: onConfirm,
                );
              },
              child: const Text('Open Administer Sheet'),
            );
          },
        ),
      ),
    );
  }

  group('AdministerMedicationSheet Widget Tests', () {
    testWidgets('renders medication administration form with clinician, medicine, and unit fields', (tester) async {
      await tester.pumpWidget(buildTestSheet(
        onConfirm: ({required prescription, required veterinarianName, clinicalNotes}) {},
      ));

      await tester.tap(find.text('Open Administer Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Administer Medication'), findsOneWidget);
      expect(find.text('Administering Veterinarian'), findsOneWidget);
      expect(find.text('Medicine / Pharmaceutical Product'), findsOneWidget);
      expect(find.text('Dose Quantity'), findsOneWidget);
      expect(find.text('Unit'), findsOneWidget);
      expect(find.text('Administration Route'), findsOneWidget);
      expect(find.text('Confirm & Administer Dose'), findsOneWidget);
    });

    testWidgets('quick step chips increment dose quantity', (tester) async {
      await tester.pumpWidget(buildTestSheet(
        onConfirm: ({required prescription, required veterinarianName, clinicalNotes}) {},
      ));

      await tester.tap(find.text('Open Administer Sheet'));
      await tester.pumpAndSettle();

      // Enter initial dose: 1.0
      final doseFinder = find.widgetWithText(TextFormField, 'e.g. 2.5 or 50');
      await tester.enterText(doseFinder, '1.0');
      await tester.pumpAndSettle();

      // Tap +0.5 quick step
      await tester.tap(find.text('+0.5'));
      await tester.pumpAndSettle();

      expect(find.text('1.5'), findsOneWidget);

      // Tap +1.0 quick step
      await tester.tap(find.text('+1.0'));
      await tester.pumpAndSettle();

      expect(find.text('2.5'), findsOneWidget);
    });

    testWidgets('validates required fields on submission', (tester) async {
      await tester.pumpWidget(buildTestSheet(
        onConfirm: ({required prescription, required veterinarianName, clinicalNotes}) {},
      ));

      await tester.tap(find.text('Open Administer Sheet'));
      await tester.pumpAndSettle();

      // Scroll to bottom and tap submit without entering medicine or dose
      await tester.drag(find.text('Administer Medication'), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm & Administer Dose'));
      await tester.pumpAndSettle();

      expect(find.text('Medication name required'), findsOneWidget);
      expect(find.text('Dose required'), findsOneWidget);
    });

    testWidgets('successful administration triggers onConfirm with correct PrescriptionItem', (tester) async {
      PrescriptionItem? submittedPrescription;
      String? submittedVet;
      String? submittedNotes;

      await tester.pumpWidget(buildTestSheet(
        onConfirm: ({required prescription, required veterinarianName, clinicalNotes}) {
          submittedPrescription = prescription;
          submittedVet = veterinarianName;
          submittedNotes = clinicalNotes;
        },
      ));

      await tester.tap(find.text('Open Administer Sheet'));
      await tester.pumpAndSettle();

      // Enter medicine name
      final medFinder = find.widgetWithText(TextFormField, 'Search or enter medication name (e.g. Meloxicam, Ketamine)...');
      await tester.enterText(medFinder, 'Meloxicam 1.5mg/ml');
      await tester.pumpAndSettle();

      // Enter dose
      final doseFinder = find.widgetWithText(TextFormField, 'e.g. 2.5 or 50');
      await tester.enterText(doseFinder, '2.5');
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.text('Administer Medication'), const Offset(0, -250));
      await tester.pumpAndSettle();

      // Enter notes
      final notesFinder = find.widgetWithText(TextFormField, 'e.g., Pre-anesthetic induction, IV catheter flush, wound irrigation...');
      await tester.enterText(notesFinder, 'Pre-op analgesia');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Confirm & Administer Dose'));
      await tester.pumpAndSettle();

      expect(submittedPrescription, isNotNull);
      expect(submittedPrescription!.medicineName, 'Meloxicam 1.5mg/ml');
      expect(submittedPrescription!.doseQuantity, '2.5');
      expect(submittedPrescription!.unit, 'ml');
      expect(submittedVet, 'Dr. Jane Smith, DVM');
      expect(submittedNotes, 'Pre-op analgesia');
    });
  });
}
