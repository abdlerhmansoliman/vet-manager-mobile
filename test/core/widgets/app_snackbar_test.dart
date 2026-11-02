import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/core/widgets/app_snackbar.dart';

void main() {
  Widget buildTestScaffold({required void Function(BuildContext) triggerAction}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => triggerAction(context),
              child: const Text('Trigger'),
            );
          },
        ),
      ),
    );
  }

  group('AppSnackbar', () {
    testWidgets('showSuccess displays message with success icon', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(
          triggerAction: (ctx) => AppSnackbar.showSuccess(ctx, 'Patient registered successfully!'),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300)); // Animate in

      expect(find.text('Patient registered successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('showError masks technical InvalidDataException into clinical message', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(
          triggerAction: (ctx) => AppSnackbar.showError(
            ctx,
            InvalidDataException('phonePrimary: Must at least be 3 characters long'),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should display the human-friendly message, NEVER the raw InvalidDataException
      expect(find.text('Primary phone number must be at least 3 digits.'), findsOneWidget);
      expect(find.textContaining('InvalidDataException'), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('showError handles NetworkException cleanly', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(
          triggerAction: (ctx) => AppSnackbar.showError(ctx, const NetworkException()),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('You are currently working offline. Data will sync automatically when connected.'),
        findsOneWidget,
      );
    });

    testWidgets('showWarning displays warning badge with warning icon', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(
          triggerAction: (ctx) => AppSnackbar.showWarning(ctx, 'Please review highlighted fields.'),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please review highlighted fields.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('showInfo displays notice with cloud icon', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(
          triggerAction: (ctx) => AppSnackbar.showInfo(ctx, 'Syncing offline queue...'),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Syncing offline queue...'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });
}
