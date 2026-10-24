import 'package:equatable/equatable.dart';
import '../../domain/models/clinic_tenant.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched upon app startup to check existing credentials & biometric status.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Dispatched in Step 1 when clinician inputs their email.
class AuthEmailSubmitted extends AuthEvent {
  final String email;

  const AuthEmailSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when clinician selects a clinic tenant from the staggered cards.
class AuthClinicSelected extends AuthEvent {
  final ClinicTenant tenant;

  const AuthClinicSelected(this.tenant);

  @override
  List<Object?> get props => [tenant];
}

/// Dispatched when clinician wants to re-enter email or choose a different clinic.
class AuthResetToEmail extends AuthEvent {
  const AuthResetToEmail();
}

/// Dispatched in Step 2 when password is submitted for the chosen tenant.
class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String tenantId;
  final bool enableBiometrics;

  const AuthLoginSubmitted({
    required this.email,
    required this.password,
    required this.tenantId,
    this.enableBiometrics = true,
  });

  @override
  List<Object?> get props => [email, password, tenantId, enableBiometrics];
}

/// Dispatched to unlock using biometrics (FaceID/Fingerprint).
class AuthBiometricUnlockAttempted extends AuthEvent {
  const AuthBiometricUnlockAttempted();
}

/// Dispatched to log out and clear the session.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
