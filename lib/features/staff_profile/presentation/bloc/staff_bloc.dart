import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/clinical_error_formatter.dart';
import '../../domain/repositories/staff_repository.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final IStaffRepository _repository;

  StaffBloc({
    required IStaffRepository repository,
  })  : _repository = repository,
        super(const StaffInitial()) {
    on<LoadStaffList>(_onLoadStaffList);
    on<LoadDoctorProfile>(_onLoadDoctorProfile);
    on<CreateStaffMemberRequested>(_onCreateStaffMember);
    on<UpdateStaffMemberRequested>(_onUpdateStaffMember);
    on<ToggleStaffAvailabilityRequested>(_onToggleAvailability);
    on<ToggleStaffStatusRequested>(_onToggleStatus);
    on<DeleteStaffMemberRequested>(_onDeleteStaffMember);
  }

  Future<void> _onLoadStaffList(
    LoadStaffList event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Loading staff directory...',
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final staff = await _repository.getStaffMembers(
        role: event.roleFilter,
        isActive: event.activeFilter,
      );
      emit(StaffLoaded(
        staffMembers: staff,
        selectedDoctor: state.selectedDoctor,
        roleFilter: event.roleFilter,
        activeFilter: event.activeFilter,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to load staff list.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onLoadDoctorProfile(
    LoadDoctorProfile event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Loading doctor profile...',
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final doctor = await _repository.getStaffMember(event.doctorId);
      emit(StaffLoaded(
        staffMembers: state.staffMembers,
        selectedDoctor: doctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to load doctor profile.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onCreateStaffMember(
    CreateStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Registering new staff member...',
      isSubmitting: true,
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final created = await _repository.createStaffMember(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
        pin: event.pin,
        jobTitle: event.jobTitle,
        specialty: event.specialty,
        licenseNumber: event.licenseNumber,
        deaNumber: event.deaNumber,
        bio: event.bio,
        dateOfBirth: event.dateOfBirth,
        isAvailable: event.isAvailable,
      );

      final updatedList = [created, ...state.staffMembers];
      emit(StaffOperationSuccess(
        message: 'Staff member ${created.name} registered successfully.',
        updatedStaff: created,
        staffMembers: updatedList,
        selectedDoctor: state.selectedDoctor,
      ));
      emit(StaffLoaded(
        staffMembers: updatedList,
        selectedDoctor: state.selectedDoctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to create staff member.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onUpdateStaffMember(
    UpdateStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Updating staff member...',
      isSubmitting: true,
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final updated = await _repository.updateStaffMember(
        userId: event.userId,
        name: event.name,
        email: event.email,
        role: event.role,
        password: event.password,
        phone: event.phone,
        pin: event.pin,
        jobTitle: event.jobTitle,
        specialty: event.specialty,
        licenseNumber: event.licenseNumber,
        deaNumber: event.deaNumber,
        bio: event.bio,
        dateOfBirth: event.dateOfBirth,
        isAvailable: event.isAvailable,
      );

      final updatedList = state.staffMembers
          .map((s) => s.id == updated.id ? updated : s)
          .toList();
      final updatedDoctor =
          state.selectedDoctor?.id == updated.id ? updated : state.selectedDoctor;

      emit(StaffOperationSuccess(
        message: 'Staff member ${updated.name} updated successfully.',
        updatedStaff: updated,
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
      emit(StaffLoaded(
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update staff member.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onToggleAvailability(
    ToggleStaffAvailabilityRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Updating on-duty availability...',
      isSubmitting: true,
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final updated = await _repository.updateAvailability(
        userId: event.userId,
        isAvailable: event.isAvailable,
      );

      final updatedList = state.staffMembers
          .map((s) => s.id == updated.id ? updated : s)
          .toList();
      final updatedDoctor =
          state.selectedDoctor?.id == updated.id ? updated : state.selectedDoctor;

      final statusText = event.isAvailable ? 'On-Duty' : 'Off-Duty';
      emit(StaffOperationSuccess(
        message: 'Practitioner availability updated to $statusText.',
        updatedStaff: updated,
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
      emit(StaffLoaded(
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update availability.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onToggleStatus(
    ToggleStaffStatusRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Updating staff status...',
      isSubmitting: true,
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      final updated = await _repository.updateStatus(
        userId: event.userId,
        isActive: event.isActive,
      );

      final updatedList = state.staffMembers
          .map((s) => s.id == updated.id ? updated : s)
          .toList();
      final updatedDoctor =
          state.selectedDoctor?.id == updated.id ? updated : state.selectedDoctor;

      final statusAction = event.isActive ? 'activated' : 'suspended';
      emit(StaffOperationSuccess(
        message: 'Staff member ${updated.name} has been $statusAction.',
        updatedStaff: updated,
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
      emit(StaffLoaded(
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to update staff status.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }

  Future<void> _onDeleteStaffMember(
    DeleteStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading(
      message: 'Removing staff member...',
      isSubmitting: true,
      staffMembers: state.staffMembers,
      selectedDoctor: state.selectedDoctor,
    ));

    try {
      await _repository.deleteStaffMember(event.userId);

      final updatedList =
          state.staffMembers.where((s) => s.id != event.userId).toList();
      final updatedDoctor =
          state.selectedDoctor?.id == event.userId ? null : state.selectedDoctor;

      emit(StaffOperationSuccess(
        message: 'Staff member removed successfully.',
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
      emit(StaffLoaded(
        staffMembers: updatedList,
        selectedDoctor: updatedDoctor,
      ));
    } on AppException catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e),
        fieldErrors: e is ValidationException ? e.fieldErrors : const {},
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    } catch (e) {
      emit(StaffFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to delete staff member.'),
        staffMembers: state.staffMembers,
        selectedDoctor: state.selectedDoctor,
      ));
    }
  }
}

