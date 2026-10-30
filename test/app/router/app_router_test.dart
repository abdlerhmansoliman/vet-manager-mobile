import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/app/router/app_router.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_session.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_user.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/clinic_tenant.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockCaseRepository extends Mock implements ICaseRepository {}
class MockPatientRepository extends Mock implements IPatientRepository {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockCaseRepository mockCaseRepo;
  late MockPatientRepository mockPatientRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const sampleSession = AuthSession(
    token: 'token-123',
    user: AuthUser(
      id: 'usr-1',
      name: 'Dr. John Miller',
      email: 'john.miller@alphavet.com',
      role: 'veterinarian',
      isActive: true,
    ),
    tenant: ClinicTenant(
      id: 'ten-1',
      name: 'Alpha Pet Hospital',
      slug: 'alphavet',
      status: 'active',
      plan: 'pro',
    ),
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockCaseRepo = MockCaseRepository();
    mockPatientRepo = MockPatientRepository();

    when(() => mockCaseRepo.watchCases(query: any(named: 'query')))
        .thenAnswer((_) => Stream.value(<CaseSummaryEntity>[]));
    when(() => mockPatientRepo.watchPatients(
          query: any(named: 'query'),
          speciesFilter: any(named: 'speciesFilter'),
        )).thenAnswer((_) => Stream.value(<PatientEntity>[]));
  });

  Widget buildRouterApp({
    required AuthState initialAuthState,
  }) {
    when(() => mockAuthBloc.state).thenReturn(initialAuthState);
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(initialAuthState));

    final appRouter = AppRouter(
      authBloc: mockAuthBloc,
      caseRepository: mockCaseRepo,
      patientRepository: mockPatientRepo,
    );

    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp.router(
        routerConfig: appRouter.router,
      ),
    );
  }

  group('AppRouter Navigation Guards', () {
    testWidgets('redirects to SmartLoginScreen when AuthUnauthenticated', (tester) async {
      await tester.pumpWidget(buildRouterApp(initialAuthState: const AuthUnauthenticated()));
      await tester.pumpAndSettle();

      expect(find.text('VetManager'), findsOneWidget);
      expect(find.text('Step 1 of 2: Discover Clinics'), findsOneWidget);
      expect(find.text('Discover My Clinics'), findsOneWidget);
    });

    testWidgets('redirects to ClinicHomeScreen (Triage Board) when AuthAuthenticated', (tester) async {
      await tester.pumpWidget(buildRouterApp(initialAuthState: const AuthAuthenticated(sampleSession)));
      await tester.pumpAndSettle();

      // Verify we landed on Clinic page (Triage Board), NOT Design System Showcase
      expect(find.text('Triage Board'), findsOneWidget);
      expect(find.text('Design System Showcase'), findsNothing);
      expect(find.text('Triage Cases'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
    });
  });
}
