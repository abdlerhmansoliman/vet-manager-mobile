import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc({
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthEmailSubmitted>(_onEmailSubmitted);
    on<AuthClinicSelected>(_onClinicSelected);
    on<AuthResetToEmail>(_onResetToEmail);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthBiometricUnlockAttempted>(_onBiometricUnlockAttempted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Checking session...'));

    final hasSession = await _authRepository.hasActiveSession();
    if (!hasSession) {
      emit(const AuthUnauthenticated());
      return;
    }

    final isBiometricEnabled = await _authRepository.isBiometricUnlockEnabled();
    if (isBiometricEnabled) {
      final user = await _authRepository.getCurrentUser();
      emit(AuthBiometricUnlockRequired(
        doctorName: user?.name,
      ));
      return;
    }

    // Attempt to verify session against backend
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      // In production, session can be re-composed or user marked active
      emit(const AuthUnauthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onEmailSubmitted(
    AuthEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      emit(const AuthFailure(
        message: 'Please enter a valid clinic staff email address.',
        fallbackState: AuthUnauthenticated(),
      ));
      return;
    }

    emit(const AuthLoading(message: 'Discovering associated clinics...'));

    try {
      final tenants = await _authRepository.resolveTenants(email);

      if (tenants.isEmpty) {
        emit(AuthFailure(
          message: 'No clinic found associated with $email. Please contact your clinic manager.',
          fallbackState: AuthUnauthenticated(initialEmail: email),
        ));
        return;
      }

      // If exactly 1 tenant is found, automatically progress to password step!
      if (tenants.length == 1) {
        final biometricsAvailable = await _authRepository.isBiometricsAvailable();
        emit(AuthPasswordRequired(
          email: email,
          tenant: tenants.first,
          biometricsAvailable: biometricsAvailable,
        ));
      } else {
        // Multi-clinic practitioner: show staggered clinic cards
        emit(AuthTenantsDiscovered(
          email: email,
          tenants: tenants,
        ));
      }
    } on AppException catch (e) {
      emit(AuthFailure(
        message: e.message,
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        fallbackState: AuthUnauthenticated(initialEmail: email),
      ));
    } catch (e) {
      emit(AuthFailure(
        message: 'Unable to connect to clinic service. Please try again.',
        fallbackState: AuthUnauthenticated(initialEmail: email),
      ));
    }
  }

  Future<void> _onClinicSelected(
    AuthClinicSelected event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    String email = '';
    if (currentState is AuthTenantsDiscovered) {
      email = currentState.email;
    }

    final biometricsAvailable = await _authRepository.isBiometricsAvailable();
    emit(AuthPasswordRequired(
      email: email,
      tenant: event.tenant,
      biometricsAvailable: biometricsAvailable,
    ));
  }

  void _onResetToEmail(
    AuthResetToEmail event,
    Emitter<AuthState> emit,
  ) {
    String? email;
    if (state is AuthTenantsDiscovered) {
      email = (state as AuthTenantsDiscovered).email;
    } else if (state is AuthPasswordRequired) {
      email = (state as AuthPasswordRequired).email;
    }
    emit(AuthUnauthenticated(initialEmail: email));
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final previousState = state;
    emit(const AuthLoading(message: 'Verifying credentials & tenant scope...'));

    try {
      final session = await _authRepository.login(
        email: event.email,
        password: event.password,
        tenantId: event.tenantId,
      );

      if (event.enableBiometrics) {
        await _authRepository.setBiometricUnlockEnabled(true);
      }

      emit(AuthAuthenticated(session));
    } on AppException catch (e) {
      emit(AuthFailure(
        message: e.message,
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        fallbackState: previousState is AuthPasswordRequired
            ? previousState
            : const AuthUnauthenticated(),
      ));
    } catch (e) {
      emit(AuthFailure(
        message: 'Authentication failed. Please verify credentials.',
        fallbackState: previousState,
      ));
    }
  }

  Future<void> _onBiometricUnlockAttempted(
    AuthBiometricUnlockAttempted event,
    Emitter<AuthState> emit,
  ) async {
    final authenticated = await _authRepository.authenticateWithBiometrics(
      reason: 'Scan fingerprint or FaceID to unlock clinical shift',
    );

    if (authenticated) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        // Build session with verified user
        // If needed, emit AuthAuthenticated or reload session
      }
    } else {
      emit(const AuthFailure(
        message: 'Biometric verification cancelled or failed.',
        fallbackState: AuthBiometricUnlockRequired(),
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
