import 'package:equatable/equatable.dart';

/// Entity representing a veterinarian or clinical staff member's clinical credentials,
/// licensure, DEA registration, and real-time on-duty availability.
class VetProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? jobTitle;
  final String? specialty;
  final String? licenseNumber;
  final String? deaNumber;
  final String? dateOfBirth;
  final String? bio;
  final bool isAvailable;
  final int activeCasesCount;

  const VetProfileEntity({
    this.id,
    this.userId,
    this.jobTitle,
    this.specialty,
    this.licenseNumber,
    this.deaNumber,
    this.dateOfBirth,
    this.bio,
    this.isAvailable = true,
    this.activeCasesCount = 0,
  });

  VetProfileEntity copyWith({
    String? id,
    String? userId,
    String? jobTitle,
    String? specialty,
    String? licenseNumber,
    String? deaNumber,
    String? dateOfBirth,
    String? bio,
    bool? isAvailable,
    int? activeCasesCount,
  }) {
    return VetProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      deaNumber: deaNumber ?? this.deaNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      activeCasesCount: activeCasesCount ?? this.activeCasesCount,
    );
  }

  factory VetProfileEntity.fromJson(Map<String, dynamic> json) {
    return VetProfileEntity(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      jobTitle: json['job_title'] as String?,
      specialty: json['specialty'] as String?,
      licenseNumber: json['license_number'] as String?,
      deaNumber: json['dea_number'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      bio: json['bio'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      activeCasesCount: (json['active_cases_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (jobTitle != null) 'job_title': jobTitle,
      if (specialty != null) 'specialty': specialty,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (deaNumber != null) 'dea_number': deaNumber,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (bio != null) 'bio': bio,
      'is_available': isAvailable,
      'active_cases_count': activeCasesCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        jobTitle,
        specialty,
        licenseNumber,
        deaNumber,
        dateOfBirth,
        bio,
        isAvailable,
        activeCasesCount,
      ];
}

