import 'package:equatable/equatable.dart';

/// Represents the authenticated staff member or veterinarian.
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;
  final Map<String, dynamic>? profile;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
    this.profile,
  });

  bool get isDoctor =>
      role.toLowerCase() == 'veterinarian' || role.toLowerCase() == 'doctor';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      profile: json['profile'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'is_active': isActive,
      'profile': profile,
    };
  }

  @override
  List<Object?> get props => [id, name, email, role, phone, isActive, profile];
}
