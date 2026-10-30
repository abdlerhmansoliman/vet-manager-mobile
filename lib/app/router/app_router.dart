import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/biometric_unlock_screen.dart';
import '../../features/auth/presentation/screens/smart_login_screen.dart';
import '../../features/showcase/presentation/screens/ui_showcase_screen.dart';

import '../../features/clients_patients/domain/repositories/patient_repository.dart';

import '../../features/clinical_cases/domain/repositories/case_repository.dart';
import '../../features/clinical_cases/presentation/screens/clinic_home_screen.dart';
import '../../features/clinical_cases/presentation/screens/case_detail_screen.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String biometricUnlock = '/biometric-unlock';
  static const String showcase = '/showcase';
  static const String patients = '/patients';
  static const String cases = '/cases';
  static const String caseDetail = '/cases/:id';
  static const String home = '/';
}

class AppRouter {
  final AuthBloc _authBloc;
  final IPatientRepository? _patientRepository;
  final ICaseRepository? _caseRepository;

  AppRouter({
    required AuthBloc authBloc,
    IPatientRepository? patientRepository,
    ICaseRepository? caseRepository,
  })  : _authBloc = authBloc,
        _patientRepository = patientRepository,
        _caseRepository = caseRepository;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = _authBloc.state;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isBiometric = state.matchedLocation == AppRoutes.biometricUnlock;
      final isShowcase = state.matchedLocation == AppRoutes.showcase;

      // Allow developer/user to explore showcase screen freely
      if (isShowcase) return null;

      // Unauthenticated users are directed to password sign-in
      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        if (!isLoggingIn) {
          return AppRoutes.login;
        }
        return null;
      }

      // Biometric lock screen is bypassed per user request; route to login
      if (isBiometric) {
        return AppRoutes.login;
      }

      // Authenticated users go directly to the main Clinic workspace
      if (authState is AuthAuthenticated) {
        if (isLoggingIn || isBiometric || state.matchedLocation == AppRoutes.home) {
          return AppRoutes.cases;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const SmartLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometricUnlock,
        builder: (context, state) {
          final authState = _authBloc.state;
          String? doctorName;
          String? clinicName;
          if (authState is AuthBiometricUnlockRequired) {
            doctorName = authState.doctorName;
            clinicName = authState.clinicName;
          }
          return BiometricUnlockScreen(
            doctorName: doctorName,
            clinicName: clinicName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.showcase,
        builder: (context, state) => const UiShowcaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.patients,
        builder: (context, state) {
          return ClinicHomeScreen(
            initialIndex: 1,
            caseRepository: _caseRepository,
            patientRepository: _patientRepository,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cases,
        builder: (context, state) {
          return ClinicHomeScreen(
            initialIndex: 0,
            caseRepository: _caseRepository,
            patientRepository: _patientRepository,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.caseDetail,
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? '';
          return CaseDetailScreen(caseId: caseId, repository: _caseRepository);
        },
      ),
    ],
  );
}

/// Helper class to convert a stream into a [Listenable] for [GoRouter].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
