import '../entities/staff_entity.dart';

/// Repository interface for staff and doctor profile operations.
abstract class IStaffRepository {
  /// Fetches the list of clinic staff members, optionally filtered by role or active status.
  Future<List<StaffEntity>> getStaffMembers({String? role, bool? isActive});

  /// Fetches a specific staff member by user UUID.
  Future<StaffEntity> getStaffMember(String userId);

  /// Creates a new staff member with clinical profile and optional 4-digit PIN.
  Future<StaffEntity> createStaffMember({
    required String name,
    required String email,
    required String password,
    required StaffRole role,
    String? phone,
    String? pin,
    String? jobTitle,
    String? specialty,
    String? licenseNumber,
    String? deaNumber,
    String? bio,
    String? dateOfBirth,
    bool isAvailable = true,
  });

  /// Updates an existing staff member's credentials and clinical profile.
  Future<StaffEntity> updateStaffMember({
    required String userId,
    required String name,
    required String email,
    required StaffRole role,
    String? password,
    String? phone,
    String? pin,
    String? jobTitle,
    String? specialty,
    String? licenseNumber,
    String? deaNumber,
    String? bio,
    String? dateOfBirth,
    bool? isAvailable,
  });

  /// Updates on-duty availability for a practitioner (`PATCH /staff/{user}/availability`).
  Future<StaffEntity> updateAvailability({
    required String userId,
    required bool isAvailable,
  });

  /// Activates or suspends a clinic staff member (`PATCH /staff/{user}/status`).
  Future<StaffEntity> updateStatus({
    required String userId,
    required bool isActive,
  });

  /// Soft-deletes a staff member from the clinic (`DELETE /staff/{user}`).
  Future<void> deleteStaffMember(String userId);
}

