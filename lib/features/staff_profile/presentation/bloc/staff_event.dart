import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load the list of clinic staff members.
class LoadStaffList extends StaffEvent {
  final String? roleFilter;
  final bool? activeFilter;

  const LoadStaffList({
    this.roleFilter,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [roleFilter, activeFilter];
}

/// Request to load or refresh a specific doctor's profile.
class LoadDoctorProfile extends StaffEvent {
  final String doctorId;

  const LoadDoctorProfile({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

/// Request to register a new clinic staff member.
class CreateStaffMemberRequested extends StaffEvent {
  final String name;
  final String email;
  final String password;
  final StaffRole role;
  final String? phone;
  final String? pin;
  final String? jobTitle;
  final String? specialty;
  final String? licenseNumber;
  final String? deaNumber;
  final String? bio;
  final String? dateOfBirth;
  final bool isAvailable;

  const CreateStaffMemberRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    this.pin,
    this.jobTitle,
    this.specialty,
    this.licenseNumber,
    this.deaNumber,
    this.bio,
    this.dateOfBirth,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        role,
        phone,
        pin,
        jobTitle,
        specialty,
        licenseNumber,
        deaNumber,
        bio,
        dateOfBirth,
        isAvailable,
      ];
}

/// Request to update an existing clinic staff member.
class UpdateStaffMemberRequested extends StaffEvent {
  final String userId;
  final String name;
  final String email;
  final StaffRole role;
  final String? password;
  final String? phone;
  final String? pin;
  final String? jobTitle;
  final String? specialty;
  final String? licenseNumber;
  final String? deaNumber;
  final String? bio;
  final String? dateOfBirth;
  final bool? isAvailable;

  const UpdateStaffMemberRequested({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.password,
    this.phone,
    this.pin,
    this.jobTitle,
    this.specialty,
    this.licenseNumber,
    this.deaNumber,
    this.bio,
    this.dateOfBirth,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        role,
        password,
        phone,
        pin,
        jobTitle,
        specialty,
        licenseNumber,
        deaNumber,
        bio,
        dateOfBirth,
        isAvailable,
      ];
}

/// Request to update on-duty availability for a doctor/staff member.
class ToggleStaffAvailabilityRequested extends StaffEvent {
  final String userId;
  final bool isAvailable;

  const ToggleStaffAvailabilityRequested({
    required this.userId,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [userId, isAvailable];
}

/// Request to activate or suspend a staff member.
class ToggleStaffStatusRequested extends StaffEvent {
  final String userId;
  final bool isActive;

  const ToggleStaffStatusRequested({
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, isActive];
}

/// Request to delete a staff member.
class DeleteStaffMemberRequested extends StaffEvent {
  final String userId;

  const DeleteStaffMemberRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

