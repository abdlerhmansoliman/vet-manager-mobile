import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/app/router/app_router.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/auth/data/auth_repository.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:vet_manager_mobile/features/settings/presentation/screens/delete_account_screen.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const AuthLogoutRequested());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestScreen() {
    return MaterialApp(
      routes: {
        AppRoutes.login: (_) => const Scaffold(body: Text('Login Screen')),
      },
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: DeleteAccountScreen(
          authRepository: mockAuthRepository,
          authBloc: mockAuthBloc,
        ),
      ),
    );
  }

  Future<void> checkAcknowledgment(WidgetTester tester) async {
    final cbFinder = find.byKey(const Key('confirm_deletion_checkbox'));
    await tester.ensureVisible(cbFinder);
    await tester.pumpAndSettle();
    await tester.tap(cbFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapConfirmDeleteButton(WidgetTester tester) async {
    final deleteBtnFinder = find.byKey(const Key('confirm_delete_account_button'));
    await tester.ensureVisible(deleteBtnFinder);
    await tester.pumpAndSettle();
    await tester.tap(deleteBtnFinder);
    await tester.pumpAndSettle();
  }

  Future<void> enterPassword(WidgetTester tester, String password) async {
    final pwdFinder = find.byKey(const Key('delete_account_password_field'));
    await tester.ensureVisible(pwdFinder);
    await tester.pumpAndSettle();
    await tester.enterText(pwdFinder, password);
    await tester.pumpAndSettle();
  }

  group('DeleteAccountScreen (App Store Guideline 5.1.1(v))', () {
    testWidgets('renders warning banner, legal notice, consequences, checkbox, and password field', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.text('Permanent & Irreversible Action'), findsOneWidget);
      expect(find.text('Medical Audit Record Preservation'), findsOneWidget);
      expect(find.text('What happens when your account is deleted:'), findsOneWidget);

      expect(find.byKey(const Key('confirm_deletion_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('delete_account_password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_delete_account_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_delete_account_button')), findsOneWidget);

      // Confirm button is initially disabled because checkbox is not checked
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('confirm_delete_account_button')));
      expect(button.onPressed, isNull);
    });

    testWidgets('checking acknowledgment checkbox enables confirm button', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Checkbox is unchecked
      Checkbox checkbox = tester.widget<Checkbox>(find.byKey(const Key('confirm_deletion_checkbox')));
      expect(checkbox.value, isFalse);

      // Tap checkbox to check it
      await checkAcknowledgment(tester);

      checkbox = tester.widget<Checkbox>(find.byKey(const Key('confirm_deletion_checkbox')));
      expect(checkbox.value, isTrue);

      // Button is now enabled
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('confirm_delete_account_button')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('dual-confirmation dialog cancel does not invoke deleteAccount', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check the checkbox and enter password
      await checkAcknowledgment(tester);
      await enterPassword(tester, 'DoctorSecret123!');

      // Tap Delete button
      await tapConfirmDeleteButton(tester);

      // Verify dialog is shown
      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(find.byKey(const Key('confirm_deletion_dialog_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_deletion_dialog_button')), findsOneWidget);

      // Tap Cancel in dialog
      await tester.tap(find.byKey(const Key('cancel_deletion_dialog_button')));
      await tester.pumpAndSettle();

      // Dialog is dismissed and deleteAccount was NOT called
      expect(find.text('Confirm Deletion'), findsNothing);
      verifyNever(() => mockAuthRepository.deleteAccount(password: any(named: 'password')));
    });

    testWidgets('shows validation error when password is empty on confirm', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check the checkbox
      await checkAcknowledgment(tester);

      // Tap Delete without password
      await tapConfirmDeleteButton(tester);
      await tester.pumpAndSettle();

      // Form validation error appears immediately without opening confirmation dialog
      expect(find.text('Please enter your password to authorize deletion.'), findsOneWidget);
      expect(find.text('Confirm Deletion'), findsNothing);
      verifyNever(() => mockAuthRepository.deleteAccount(password: any(named: 'password')));
    });

    testWidgets('in-flight loading state disables inputs and shows indicator during deletion', (tester) async {
      final completer = Completer<void>();
      when(() => mockAuthRepository.deleteAccount(password: 'DoctorSecret123!'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check checkbox and enter password
      await checkAcknowledgment(tester);
      await enterPassword(tester, 'DoctorSecret123!');

      // Tap delete and confirm dialog
      await tapConfirmDeleteButton(tester);
      await tester.tap(find.byKey(const Key('confirm_deletion_dialog_button')));
      await tester.pump(); // Start async request

      // Verify loading indicator is displayed and buttons are disabled
      expect(find.byKey(const Key('delete_account_loading_indicator')), findsOneWidget);
      final deleteBtn = tester.widget<ElevatedButton>(find.byKey(const Key('confirm_delete_account_button')));
      expect(deleteBtn.onPressed, isNull);

      // Complete async request
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('successful account deletion triggers repository, logout, and success snackbar', (tester) async {
      when(() => mockAuthRepository.deleteAccount(password: 'DoctorSecret123!'))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check checkbox and enter password
      await checkAcknowledgment(tester);
      await enterPassword(tester, 'DoctorSecret123!');

      // Tap delete and confirm dialog
      await tapConfirmDeleteButton(tester);
      await tester.tap(find.byKey(const Key('confirm_deletion_dialog_button')));
      await tester.pumpAndSettle();

      // Verify repository contract
      verify(() => mockAuthRepository.deleteAccount(password: 'DoctorSecret123!')).called(1);
      verify(() => mockAuthBloc.add(const AuthLogoutRequested())).called(1);

      // Verify success snackbar
      expect(
        find.text('Your practitioner account has been deleted successfully.'),
        findsOneWidget,
      );
    });

    testWidgets('422 validation failure displays shielded error and re-enables submit', (tester) async {
      when(() => mockAuthRepository.deleteAccount(password: 'wrong-pass'))
          .thenThrow(const ValidationException(
            message: 'The provided password was incorrect.',
            fieldErrors: {
              'password': ['The provided password was incorrect.']
            },
          ));

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check checkbox and enter wrong password
      await checkAcknowledgment(tester);
      await enterPassword(tester, 'wrong-pass');

      // Tap delete and confirm
      await tapConfirmDeleteButton(tester);
      await tester.tap(find.byKey(const Key('confirm_deletion_dialog_button')));
      await tester.pumpAndSettle();

      // Verify inline error banner & snackbar (shielded from technical dumps)
      expect(find.byKey(const Key('delete_account_inline_error')), findsOneWidget);
      expect(find.text('The provided password was incorrect.'), findsAtLeastNWidgets(1));

      // Button is re-enabled for retry
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('confirm_delete_account_button')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('network exception displays shielded offline error without technical dump', (tester) async {
      when(() => mockAuthRepository.deleteAccount(password: 'DoctorSecret123!'))
          .thenThrow(const NetworkException(message: 'Connection reset by peer'));

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Check checkbox and enter password
      await checkAcknowledgment(tester);
      await enterPassword(tester, 'DoctorSecret123!');

      // Tap delete and confirm
      await tapConfirmDeleteButton(tester);
      await tester.tap(find.byKey(const Key('confirm_deletion_dialog_button')));
      await tester.pumpAndSettle();

      // Verify shielded network message appears and raw technical error is shielded
      expect(
        find.text('You are currently working offline. Data will sync automatically when connected.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('Connection reset by peer'), findsNothing);
    });
  });
}
