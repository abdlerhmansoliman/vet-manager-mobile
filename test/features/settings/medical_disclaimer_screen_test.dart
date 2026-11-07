import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/settings/presentation/screens/medical_disclaimer_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestScreen() {
    return const MaterialApp(
      home: MedicalDisclaimerScreen(),
    );
  }

  group('MedicalDisclaimerScreen (App Store Guideline 1.4.1)', () {
    testWidgets('renders header, title, and all 5 veterinary clinical disclaimer sections', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Title & Back button
      expect(find.text('Medical & Legal Disclaimer'), findsOneWidget);
      expect(find.byKey(const Key('medical_disclaimer_back_button')), findsOneWidget);

      // Hero notice
      expect(find.text('Clinical Decision Support'), findsOneWidget);
      expect(find.text('Regulatory & Clinical Safety Notice'), findsOneWidget);

      // 5 Mandatory clinical disclaimer cards
      expect(find.text('Professional Veterinary Use Only'), findsOneWidget);
      expect(find.text('Auxiliary Decision Support & Independent Judgment'), findsOneWidget);
      expect(find.text('Dosage Calculation & Pharmacological Responsibility'), findsOneWidget);
      expect(find.text('Acute & Life-Threatening Emergencies'), findsOneWidget);
      expect(find.text('Statutory Record Retention & Compliance'), findsOneWidget);

      // Bottom acknowledge button
      expect(find.byKey(const Key('medical_disclaimer_acknowledge_button')), findsOneWidget);
      expect(find.text('I Acknowledge & Understand'), findsOneWidget);
    });

    testWidgets('tapping acknowledge button dismisses screen', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const MedicalDisclaimerScreen(),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicalDisclaimerScreen), findsOneWidget);

      // Scroll until acknowledge button is visible and tap it
      final acknowledgeFinder = find.byKey(const Key('medical_disclaimer_acknowledge_button'));
      await tester.ensureVisible(acknowledgeFinder);
      await tester.pumpAndSettle();
      await tester.tap(acknowledgeFinder);
      await tester.pumpAndSettle();

      // Verify popped back
      expect(popped, isTrue);
      expect(find.byType(MedicalDisclaimerScreen), findsNothing);
    });

    testWidgets('tapping back button dismisses screen', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const MedicalDisclaimerScreen(),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicalDisclaimerScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('medical_disclaimer_back_button')));
      await tester.pumpAndSettle();

      // Verify popped back
      expect(popped, isTrue);
      expect(find.byType(MedicalDisclaimerScreen), findsNothing);
    });
  });
}
