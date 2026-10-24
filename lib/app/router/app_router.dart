import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/biometric_unlock_screen.dart';
import '../../features/auth/presentation/screens/smart_login_screen.dart';
import '../../features/showcase/presentation/screens/ui_showcase_screen.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String biometricUnlock = '/biometric-unlock';
  static const String showcase = '/showcase';
  static const String home = '/';
}

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter({required AuthBloc authBloc}) : _authBloc = authBloc;

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

      if (authState is AuthBiometricUnlockRequired && !isBiometric) {
        return AppRoutes.biometricUnlock;
      }

      if (authState is AuthAuthenticated) {
        if (isLoggingIn || isBiometric) {
          return AppRoutes.showcase;
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
    ],
  );
}

/// Helper class to convert a stream into a [Listenable] for [GoRouter].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
