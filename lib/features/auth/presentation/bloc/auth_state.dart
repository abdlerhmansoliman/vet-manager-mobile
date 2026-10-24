import 'package:equatable/equatable.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/clinic_tenant.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Step 1: Clinician inputs email.
class AuthUnauthenticated extends AuthState {
  final String? initialEmail;
  const AuthUnauthenticated({this.initialEmail});

  @override
  List<Object?> get props => [initialEmail];
}

/// Step 1.5: Clinician discovered one or more clinics and selects one.
class AuthTenantsDiscovered extends AuthState {
  final String email;
  final List<ClinicTenant> tenants;

  const AuthTenantsDiscovered({
    required this.email,
    required this.tenants,
  });

  @override
  List<Object?> get props => [email, tenants];
}

/// Step 2: Clinic selected, clinician enters password.
class AuthPasswordRequired extends AuthState {
  final String email;
  final ClinicTenant tenant;
  final bool biometricsAvailable;

  const AuthPasswordRequired({
    required this.email,
    required this.tenant,
    this.biometricsAvailable = false,
  });

  @override
  List<Object?> get props => [email, tenant, biometricsAvailable];
}

/// App has active session, clinician needs to biometric-unlock shift.
class AuthBiometricUnlockRequired extends AuthState {
  final String? doctorName;
  final String? clinicName;

  const AuthBiometricUnlockRequired({
    this.doctorName,
    this.clinicName,
  });

  @override
  List<Object?> get props => [doctorName, clinicName];
}

/// Fully authenticated session.
class AuthAuthenticated extends AuthState {
  final AuthSession session;

  const AuthAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

/// Error state.
class AuthFailure extends AuthState {
  final String message;
  final Map<String, List<String>> fieldErrors;
  final AuthState fallbackState;

  const AuthFailure({
    required this.message,
    this.fieldErrors = const {},
    required this.fallbackState,
  });

  @override
  List<Object?> get props => [message, fieldErrors, fallbackState];
}
