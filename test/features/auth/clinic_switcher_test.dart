import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/auth/data/auth_repository.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_session.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_user.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/clinic_tenant.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:vet_manager_mobile/features/auth/presentation/widgets/clinic_switcher_bottom_sheet.dart';
import 'package:vet_manager_mobile/features/auth/presentation/widgets/clinic_switcher_pill.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthRepository mockRepository;
  late MockAuthBloc mockAuthBloc;

  const sampleTenantA = ClinicTenant(
    id: 'tenant-alpha',
    name: 'Alpha Vet Care',
    slug: 'alpha-vet',
    status: 'active',
    plan: 'pro',
  );

  const sampleTenantB = ClinicTenant(
    id: 'tenant-beta',
    name: 'Beta Pet Hospital',
    slug: 'beta-hospital',
    status: 'active',
    plan: 'enterprise',
  );

  const sampleUser = AuthUser(
    id: 'user-doc-1',
    name: 'Dr. Sarah Connor',
    email: 'sarah@vetcare.com',
    role: 'veterinarian',
    isActive: true,
  );

  const sessionAlpha = AuthSession(
    token: 'token-alpha',
    user: sampleUser,
    tenant: sampleTenantA,
  );

  const sessionBeta = AuthSession(
    token: 'token-beta',
    user: sampleUser,
    tenant: sampleTenantB,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    mockAuthBloc = MockAuthBloc();
  });

  group('AuthBloc Multi-Clinic Switcher', () {
    blocTest<AuthBloc, AuthState>(
      'emits updated availableClinics on AuthClinicsRequested',
      build: () {
        when(() => mockRepository.resolveTenants('sarah@vetcare.com'))
            .thenAnswer((_) async => [sampleTenantA, sampleTenantB]);
        return AuthBloc(authRepository: mockRepository);
      },
      seed: () => const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [],
      ),
      act: (bloc) => bloc.add(const AuthClinicsRequested()),
      expect: () => [
        const AuthAuthenticated(
          sessionAlpha,
          availableClinics: [sampleTenantA, sampleTenantB],
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.resolveTenants('sarah@vetcare.com')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [isSwitchingClinic: true, AuthAuthenticated(newSession)] on AuthSwitchClinicRequested success',
      build: () {
        when(
          () => mockRepository.login(
            email: 'sarah@vetcare.com',
            password: 'valid-password',
            tenantId: 'tenant-beta',
          ),
        ).thenAnswer((_) async => sessionBeta);
        return AuthBloc(authRepository: mockRepository);
      },
      seed: () => const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
      ),
      act: (bloc) => bloc.add(const AuthSwitchClinicRequested(
        targetTenant: sampleTenantB,
        password: 'valid-password',
      )),
      expect: () => [
        const AuthAuthenticated(
          sessionAlpha,
          availableClinics: [sampleTenantA, sampleTenantB],
          isSwitchingClinic: true,
        ),
        const AuthAuthenticated(
          sessionBeta,
          availableClinics: [sampleTenantA, sampleTenantB],
          isSwitchingClinic: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.login(
            email: 'sarah@vetcare.com',
            password: 'valid-password',
            tenantId: 'tenant-beta',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits switchingError with clinical error shielding when switch login fails',
      build: () {
        when(
          () => mockRepository.login(
            email: 'sarah@vetcare.com',
            password: 'wrong-password',
            tenantId: 'tenant-beta',
          ),
        ).thenThrow(const UnauthorizedException(
          message: 'Invalid credentials.',
          statusCode: 401,
        ));
        return AuthBloc(authRepository: mockRepository);
      },
      seed: () => const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
      ),
      act: (bloc) => bloc.add(const AuthSwitchClinicRequested(
        targetTenant: sampleTenantB,
        password: 'wrong-password',
      )),
      expect: () => [
        const AuthAuthenticated(
          sessionAlpha,
          availableClinics: [sampleTenantA, sampleTenantB],
          isSwitchingClinic: true,
        ),
        const AuthAuthenticated(
          sessionAlpha,
          availableClinics: [sampleTenantA, sampleTenantB],
          isSwitchingClinic: false,
          switchingError: 'Your session has expired. Please log in again to continue.',
        ),
      ],
    );
  });

  group('ClinicSwitcherBottomSheet Widget', () {
    Widget buildBottomSheet() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const ClinicSwitcherBottomSheet(),
          ),
        ),
      );
    }

    testWidgets('renders active clinic with active badge and other clinic with switch button', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
      ));

      await tester.pumpWidget(buildBottomSheet());
      await tester.pumpAndSettle();

      expect(find.text('Multi-Clinic Switcher'), findsOneWidget);
      expect(find.text('Alpha Vet Care'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Beta Pet Hospital'), findsOneWidget);
      expect(find.byKey(const Key('switch_button_tenant-beta')), findsOneWidget);
    });

    testWidgets('tapping switch on inactive clinic toggles password input field and confirm button', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
      ));

      await tester.pumpWidget(buildBottomSheet());
      await tester.pumpAndSettle();

      // Tap switch button on Beta Hospital
      await tester.tap(find.byKey(const Key('switch_button_tenant-beta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('clinic_switch_password_field_tenant-beta')), findsOneWidget);
      expect(find.byKey(const Key('confirm_switch_button_tenant-beta')), findsOneWidget);

      // Enter password and tap confirm
      await tester.enterText(
        find.byKey(const Key('clinic_switch_password_field_tenant-beta')),
        'clinic-secret-123',
      );
      await tester.tap(find.byKey(const Key('confirm_switch_button_tenant-beta')));
      await tester.pump();

      verify(() => mockAuthBloc.add(const AuthSwitchClinicRequested(
            targetTenant: sampleTenantB,
            password: 'clinic-secret-123',
          ))).called(1);
    });

    testWidgets('disables action button and displays progress indicator during in-flight switch', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
        isSwitchingClinic: true,
      ));

      await tester.pumpWidget(buildBottomSheet());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing); // not expanded yet
    });

    testWidgets('shows error snackbar when switchingError is present', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthAuthenticated(
            sessionAlpha,
            availableClinics: [sampleTenantA, sampleTenantB],
            switchingError: 'Your session has expired. Please log in again to continue.',
          ),
        ]),
        initialState: const AuthAuthenticated(
          sessionAlpha,
          availableClinics: [sampleTenantA, sampleTenantB],
        ),
      );

      await tester.pumpWidget(buildBottomSheet());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your session has expired. Please log in again to continue.'), findsOneWidget);
    });
  });

  group('ClinicSwitcherPill Widget', () {
    testWidgets('renders active tenant name and triggers switcher modal on tap', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(
        sessionAlpha,
        availableClinics: [sampleTenantA, sampleTenantB],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: const ClinicSwitcherPill(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Vet Care'), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('clinic_switcher_appbar_pill')));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicSwitcherBottomSheet), findsOneWidget);
    });
  });
}
