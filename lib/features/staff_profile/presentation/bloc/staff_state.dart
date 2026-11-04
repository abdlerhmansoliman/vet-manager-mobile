import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

abstract class StaffState extends Equatable {
  final List<StaffEntity> staffMembers;
  final StaffEntity? selectedDoctor;

  const StaffState({
    this.staffMembers = const [],
    this.selectedDoctor,
  });

  @override
  List<Object?> get props => [staffMembers, selectedDoctor];
}

/// Initial uninitialized state.
class StaffInitial extends StaffState {
  const StaffInitial();
}

/// In-flight operation state (loading list, updating, or submitting mutation).
class StaffLoading extends StaffState {
  final String? message;
  final bool isSubmitting;

  const StaffLoading({
    this.message,
    this.isSubmitting = false,
    super.staffMembers,
    super.selectedDoctor,
  });

  @override
  List<Object?> get props => [message, isSubmitting, staffMembers, selectedDoctor];
}

/// Successfully loaded list of staff members or doctor profile.
class StaffLoaded extends StaffState {
  final String? roleFilter;
  final bool? activeFilter;

  const StaffLoaded({
    required super.staffMembers,
    super.selectedDoctor,
    this.roleFilter,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [
        staffMembers,
        selectedDoctor,
        roleFilter,
        activeFilter,
      ];
}

/// Mutation succeeded (staff created, updated, status toggled, or deleted).
class StaffOperationSuccess extends StaffState {
  final String message;
  final StaffEntity? updatedStaff;

  const StaffOperationSuccess({
    required this.message,
    this.updatedStaff,
    required super.staffMembers,
    super.selectedDoctor,
  });

  @override
  List<Object?> get props => [
        message,
        updatedStaff,
        staffMembers,
        selectedDoctor,
      ];
}

/// Operation failed with an error message and optional field-level validation errors.
class StaffFailure extends StaffState {
  final String message;
  final Map<String, dynamic> fieldErrors;

  const StaffFailure({
    required this.message,
    this.fieldErrors = const {},
    super.staffMembers,
    super.selectedDoctor,
  });

  @override
  List<Object?> get props => [
        message,
        fieldErrors,
        staffMembers,
        selectedDoctor,
      ];
}

