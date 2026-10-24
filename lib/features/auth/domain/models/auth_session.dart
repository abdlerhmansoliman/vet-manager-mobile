import 'package:equatable/equatable.dart';
import 'auth_user.dart';
import 'clinic_tenant.dart';

/// Active authenticated session containing scoped token, user details, and tenant context.
class AuthSession extends Equatable {
  final String token;
  final AuthUser user;
  final ClinicTenant tenant;
  final List<String> capabilities;

  const AuthSession({
    required this.token,
    required this.user,
    required this.tenant,
    this.capabilities = const [],
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      tenant: ClinicTenant.fromJson(json['tenant'] as Map<String, dynamic>),
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'tenant': tenant.toJson(),
      'capabilities': capabilities,
    };
  }

  @override
  List<Object?> get props => [token, user, tenant, capabilities];
}
