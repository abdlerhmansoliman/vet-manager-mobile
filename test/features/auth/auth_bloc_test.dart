import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/auth/data/auth_repository.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_session.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_user.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/clinic_tenant.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const sampleTenantA = ClinicTenant(
    id: 'tenant-1',
    name: 'Alpha Vet',
    slug: 'alphavet',
    status: 'active',
    plan: 'pro',
  );

  const sampleTenantB = ClinicTenant(
    id: 'tenant-2',
    name: 'Beta Hospital',
    slug: 'betavet',
    status: 'active',
    plan: 'enterprise',
  );

  const sampleUser = AuthUser(
    id: 'user-1',
    name: 'Dr. Jane Doe',
    email: 'jane@alphavet.com',
    role: 'veterinarian',
    isActive: true,
  );

  const sampleSession = AuthSession(
    token: 'valid-token',
    user: sampleUser,
    tenant: sampleTenantA,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on AuthCheckRequested when no session exists',
      build: () {
        when(() => mockRepository.hasActiveSession()).thenAnswer((_) async => false);
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(message: 'Checking session...'),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordRequired] on AuthEmailSubmitted when exactly 1 clinic is found',
      build: () {
        when(() => mockRepository.resolveTenants('jane@alphavet.com'))
            .thenAnswer((_) async => [sampleTenantA]);
        when(() => mockRepository.isBiometricsAvailable()).thenAnswer((_) async => true);
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthEmailSubmitted('jane@alphavet.com')),
      expect: () => [
        const AuthLoading(message: 'Discovering associated clinics...'),
        const AuthPasswordRequired(
          email: 'jane@alphavet.com',
          tenant: sampleTenantA,
          biometricsAvailable: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthTenantsDiscovered] on AuthEmailSubmitted when multiple clinics are found',
      build: () {
        when(() => mockRepository.resolveTenants('jane@multivet.com'))
            .thenAnswer((_) async => [sampleTenantA, sampleTenantB]);
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthEmailSubmitted('jane@multivet.com')),
      expect: () => [
        const AuthLoading(message: 'Discovering associated clinics...'),
        const AuthTenantsDiscovered(
          email: 'jane@multivet.com',
          tenants: [sampleTenantA, sampleTenantB],
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthPasswordRequired] on AuthClinicSelected',
      build: () {
        when(() => mockRepository.isBiometricsAvailable()).thenAnswer((_) async => false);
        return AuthBloc(authRepository: mockRepository);
      },
      seed: () => const AuthTenantsDiscovered(
        email: 'jane@multivet.com',
        tenants: [sampleTenantA, sampleTenantB],
      ),
      act: (bloc) => bloc.add(const AuthClinicSelected(sampleTenantB)),
      expect: () => [
        const AuthPasswordRequired(
          email: 'jane@multivet.com',
          tenant: sampleTenantB,
          biometricsAvailable: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on AuthLoginSubmitted success',
      build: () {
        when(
          () => mockRepository.login(
            email: 'jane@alphavet.com',
            password: 'secret',
            tenantId: 'tenant-1',
          ),
        ).thenAnswer((_) async => sampleSession);
        when(() => mockRepository.setBiometricUnlockEnabled(true))
            .thenAnswer((_) async {});
        return AuthBloc(authRepository: mockRepository);
      },
      seed: () => const AuthPasswordRequired(
        email: 'jane@alphavet.com',
        tenant: sampleTenantA,
      ),
      act: (bloc) => bloc.add(const AuthLoginSubmitted(
        email: 'jane@alphavet.com',
        password: 'secret',
        tenantId: 'tenant-1',
        enableBiometrics: true,
      )),
      expect: () => [
        const AuthLoading(message: 'Verifying credentials & tenant scope...'),
        const AuthAuthenticated(sampleSession),
      ],
    );
  });
}
