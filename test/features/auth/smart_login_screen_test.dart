import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/clinic_tenant.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:vet_manager_mobile/features/auth/presentation/screens/smart_login_screen.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestableWidget(AuthState state) {
    when(() => mockAuthBloc.state).thenReturn(state);
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(state));

    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const SmartLoginScreen(),
      ),
    );
  }

  group('SmartLoginScreen', () {
    testWidgets('renders Step 1 email input by default', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const AuthUnauthenticated()));
      await tester.pumpAndSettle();

      expect(find.text('VetManager'), findsOneWidget);
      expect(find.text('Step 1 of 2: Discover Clinics'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Discover My Clinics'), findsOneWidget);
    });

    testWidgets('renders multiple clinic cards in Step 1.5', (tester) async {
      const tenants = [
        ClinicTenant(
          id: '1',
          name: 'Alpha Vet',
          slug: 'alpha',
          status: 'active',
          plan: 'pro',
        ),
        ClinicTenant(
          id: '2',
          name: 'Beta Animal Hospital',
          slug: 'beta',
          status: 'active',
          plan: 'enterprise',
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          const AuthTenantsDiscovered(
            email: 'doctor@hospital.com',
            tenants: tenants,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Practice Location'), findsOneWidget);
      expect(find.text('Alpha Vet'), findsOneWidget);
      expect(find.text('Beta Animal Hospital'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('renders Step 2 password entry with chosen clinic banner', (tester) async {
      const tenant = ClinicTenant(
        id: '1',
        name: 'Alpha Vet',
        slug: 'alpha',
        status: 'active',
        plan: 'pro',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const AuthPasswordRequired(
            email: 'doctor@alphavet.com',
            tenant: tenant,
            biometricsAvailable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Vet'), findsOneWidget);
      expect(find.text('Account Password'), findsOneWidget);
      expect(find.text('Sign In & Start Shift'), findsOneWidget);
      expect(find.text('Enable biometric shift unlock on this device'), findsOneWidget);
    });
  });
}
