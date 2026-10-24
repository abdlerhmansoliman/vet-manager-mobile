import 'package:equatable/equatable.dart';

/// Represents an isolated clinic workspace discovered for a veterinarian or staff member.
class ClinicTenant extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String status;
  final String plan;

  const ClinicTenant({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    required this.status,
    required this.plan,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory ClinicTenant.fromJson(Map<String, dynamic> json) {
    return ClinicTenant(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logoUrl: json['logo_url'] as String?,
      status: (json['status'] as String?) ?? 'active',
      plan: (json['plan'] as String?) ?? 'standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo_url': logoUrl,
      'status': status,
      'plan': plan,
    };
  }

  @override
  List<Object?> get props => [id, name, slug, logoUrl, status, plan];
}
