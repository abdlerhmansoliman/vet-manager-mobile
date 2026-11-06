import 'package:equatable/equatable.dart';
import '../../../auth/domain/models/auth_user.dart';
import 'vet_profile_entity.dart';

/// All 9 supported backend roles in the VetManager Laravel architecture.
enum StaffRole {
  owner('owner', 'Clinic Owner / Director'),
  doctor('doctor', 'Doctor / Veterinarian'),
  headVet('head_vet', 'Head Veterinarian'),
  fieldDoctor('field_doctor', 'Field / Ambulatory Doctor'),
  assistant('assistant', 'Veterinary Assistant'),
  vetTech('vet_tech', 'Veterinary Technician'),
  counter('counter', 'Counter / Receptionist / Cashier'),
  receptionist('receptionist', 'Receptionist'),
  employee('employee', 'Clinic Employee');

  final String value;
  final String label;

  const StaffRole(this.value, this.label);

  static StaffRole fromString(String? val) {
    if (val == null) return StaffRole.employee;
    final normalized = val.toLowerCase().trim();
    for (final role in StaffRole.values) {
      if (role.value == normalized || role.name == normalized) {
        return role;
      }
    }
    // Backward compatibility aliases
    if (normalized == 'veterinarian') return StaffRole.doctor;
    return StaffRole.employee;
  }

  bool get isDoctor =>
      this == StaffRole.owner ||
      this == StaffRole.headVet ||
      this == StaffRole.fieldDoctor ||
      this == StaffRole.doctor;

  bool get isAssistant =>
      this == StaffRole.assistant || this == StaffRole.vetTech;

  bool get isCounter =>
      this == StaffRole.counter || this == StaffRole.receptionist;

  bool get canManageStaff =>
      this == StaffRole.owner || this == StaffRole.headVet;

  bool get canWitnessControlledSubstances =>
      this == StaffRole.owner ||
      this == StaffRole.headVet ||
      this == StaffRole.fieldDoctor ||
      this == StaffRole.doctor ||
      this == StaffRole.vetTech ||
      this == StaffRole.assistant;

  bool get canAccessOwnerDashboard => this == StaffRole.owner;

  bool get canPrescribeMedication =>
      this == StaffRole.owner ||
      this == StaffRole.headVet ||
      this == StaffRole.fieldDoctor ||
      this == StaffRole.doctor;

  bool get canPerformSurgery =>
      this == StaffRole.owner ||
      this == StaffRole.headVet ||
      this == StaffRole.doctor;

  bool get canManageBilling =>
      this == StaffRole.owner ||
      this == StaffRole.counter ||
      this == StaffRole.receptionist;

  StaffCapabilities get defaultCapabilities =>
      StaffCapabilities.fromRole(this);
}

/// Adaptive UI capabilities matrix matching backend permissions.
class StaffCapabilities extends Equatable {
  final bool canManageStaff;
  final bool canWitnessControlledSubstances;
  final bool canAccessOwnerDashboard;
  final bool canPrescribeMedication;
  final bool canPerformSurgery;
  final bool canManageBilling;
  final bool isDoctor;
  final bool isAssistant;
  final bool isCounter;

  const StaffCapabilities({
    this.canManageStaff = false,
    this.canWitnessControlledSubstances = false,
    this.canAccessOwnerDashboard = false,
    this.canPrescribeMedication = false,
    this.canPerformSurgery = false,
    this.canManageBilling = false,
    this.isDoctor = false,
    this.isAssistant = false,
    this.isCounter = false,
  });

  factory StaffCapabilities.fromRole(StaffRole role) {
    return StaffCapabilities(
      canManageStaff: role.canManageStaff,
      canWitnessControlledSubstances: role.canWitnessControlledSubstances,
      canAccessOwnerDashboard: role.canAccessOwnerDashboard,
      canPrescribeMedication: role.canPrescribeMedication,
      canPerformSurgery: role.canPerformSurgery,
      canManageBilling: role.canManageBilling,
      isDoctor: role.isDoctor,
      isAssistant: role.isAssistant,
      isCounter: role.isCounter,
    );
  }

  factory StaffCapabilities.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StaffCapabilities();
    return StaffCapabilities(
      canManageStaff: json['can_manage_staff'] as bool? ?? false,
      canWitnessControlledSubstances:
          json['can_witness_controlled_substances'] as bool? ?? false,
      canAccessOwnerDashboard:
          json['can_access_owner_dashboard'] as bool? ?? false,
      canPrescribeMedication:
          json['can_prescribe_medication'] as bool? ?? false,
      canPerformSurgery: json['can_perform_surgery'] as bool? ?? false,
      canManageBilling: json['can_manage_billing'] as bool? ?? false,
      isDoctor: json['is_doctor'] as bool? ?? false,
      isAssistant: json['is_assistant'] as bool? ?? false,
      isCounter: json['is_counter'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_manage_staff': canManageStaff,
      'can_witness_controlled_substances': canWitnessControlledSubstances,
      'can_access_owner_dashboard': canAccessOwnerDashboard,
      'can_prescribe_medication': canPrescribeMedication,
      'can_perform_surgery': canPerformSurgery,
      'can_manage_billing': canManageBilling,
      'is_doctor': isDoctor,
      'is_assistant': isAssistant,
      'is_counter': isCounter,
    };
  }

  @override
  List<Object?> get props => [
        canManageStaff,
        canWitnessControlledSubstances,
        canAccessOwnerDashboard,
        canPrescribeMedication,
        canPerformSurgery,
        canManageBilling,
        isDoctor,
        isAssistant,
        isCounter,
      ];
}

/// Domain entity representing a clinic staff member.
class StaffEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final String roleLabel;
  final String? phone;
  final bool isActive;
  final VetProfileEntity? profile;
  final int activeCasesCount;
  final StaffCapabilities capabilities;
  final DateTime? createdAt;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleLabel,
    this.phone,
    required this.isActive,
    this.profile,
    this.activeCasesCount = 0,
    required this.capabilities,
    this.createdAt,
  });

  bool get isAvailable => profile?.isAvailable ?? true;

  StaffEntity copyWith({
    String? id,
    String? name,
    String? email,
    StaffRole? role,
    String? roleLabel,
    String? phone,
    bool? isActive,
    VetProfileEntity? profile,
    int? activeCasesCount,
    StaffCapabilities? capabilities,
    DateTime? createdAt,
  }) {
    return StaffEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      roleLabel: roleLabel ?? this.roleLabel,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      profile: profile ?? this.profile,
      activeCasesCount: activeCasesCount ?? this.activeCasesCount,
      capabilities: capabilities ?? this.capabilities,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StaffEntity.fromAuthUser(AuthUser user) {
    final role = StaffRole.fromString(user.role);
    final profile = user.profile != null
        ? VetProfileEntity.fromJson(user.profile!)
        : null;
    return StaffEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      role: role,
      roleLabel: role.label,
      phone: user.phone,
      isActive: user.isActive,
      profile: profile,
      activeCasesCount: profile?.activeCasesCount ?? 0,
      capabilities: StaffCapabilities.fromRole(role),
    );
  }

  factory StaffEntity.fromJson(Map<String, dynamic> json) {
    final role = StaffRole.fromString(json['role'] as String?);
    final profileData = json['profile'] as Map<String, dynamic>?;
    final profile = profileData != null ? VetProfileEntity.fromJson(profileData) : null;
    final capabilitiesData = json['capabilities'] as Map<String, dynamic>?;
    final capabilities = capabilitiesData != null
        ? StaffCapabilities.fromJson(capabilitiesData)
        : StaffCapabilities.fromRole(role);

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'] as String);
    }

    return StaffEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: role,
      roleLabel: json['role_label'] as String? ?? role.label,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      profile: profile,
      activeCasesCount: (json['active_cases_count'] as num?)?.toInt() ?? 0,
      capabilities: capabilities,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'role_label': roleLabel,
      'phone': phone,
      'is_active': isActive,
      'profile': profile?.toJson(),
      'active_cases_count': activeCasesCount,
      'capabilities': capabilities.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        roleLabel,
        phone,
        isActive,
        profile,
        activeCasesCount,
        capabilities,
        createdAt,
      ];
}

