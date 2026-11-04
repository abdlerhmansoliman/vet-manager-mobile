import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/staff_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/vet_profile_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/repositories/staff_repository.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/bloc/staff_bloc.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/bloc/staff_event.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/bloc/staff_state.dart';

class MockStaffRepository extends Mock implements IStaffRepository {}

void main() {
  late MockStaffRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(StaffRole.doctor);
  });

  final sampleDoctor = StaffEntity(
    id: 'user-doc-1',
    name: 'Dr. Jane Doe',
    email: 'jane.doe@clinic.com',
    role: StaffRole.doctor,
    roleLabel: StaffRole.doctor.label,
    phone: '+1 555-0101',
    isActive: true,
    profile: const VetProfileEntity(
      id: 'prof-1',
      userId: 'user-doc-1',
      jobTitle: 'Senior Veterinarian',
      specialty: 'Surgery',
      licenseNumber: 'VET-88392',
      isAvailable: true,
      activeCasesCount: 3,
    ),
    activeCasesCount: 3,
    capabilities: StaffCapabilities.fromRole(StaffRole.doctor),
  );

  final sampleOwner = StaffEntity(
    id: 'user-owner-1',
    name: 'Dr. John Director',
    email: 'director@clinic.com',
    role: StaffRole.owner,
    roleLabel: StaffRole.owner.label,
    isActive: true,
    capabilities: StaffCapabilities.fromRole(StaffRole.owner),
  );

  setUp(() {
    mockRepository = MockStaffRepository();
  });

  group('StaffBloc', () {
    test('initial state is StaffInitial', () {
      final bloc = StaffBloc(repository: mockRepository);
      expect(bloc.state, equals(const StaffInitial()));
      bloc.close();
    });

    group('LoadStaffList', () {
      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffLoaded] with staff list on success',
        build: () {
          when(() => mockRepository.getStaffMembers(
                role: any(named: 'role'),
                isActive: any(named: 'isActive'),
              )).thenAnswer((_) async => [sampleDoctor, sampleOwner]);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadStaffList()),
        expect: () => [
          const StaffLoading(message: 'Loading staff directory...'),
          StaffLoaded(staffMembers: [sampleDoctor, sampleOwner]),
        ],
      );

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffFailure] shielded with clinical error message when repository throws NetworkException',
        build: () {
          when(() => mockRepository.getStaffMembers(
                role: any(named: 'role'),
                isActive: any(named: 'isActive'),
              )).thenThrow(const NetworkException(message: 'Network offline'));
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadStaffList()),
        expect: () => [
          const StaffLoading(message: 'Loading staff directory...'),
          const StaffFailure(
            message: 'You are currently working offline. Data will sync automatically when connected.',
          ),
        ],
      );
    });

    group('LoadDoctorProfile', () {
      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffLoaded] with doctor details on success',
        build: () {
          when(() => mockRepository.getStaffMember('user-doc-1'))
              .thenAnswer((_) async => sampleDoctor);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadDoctorProfile(doctorId: 'user-doc-1')),
        expect: () => [
          const StaffLoading(message: 'Loading doctor profile...'),
          StaffLoaded(
            staffMembers: const [],
            selectedDoctor: sampleDoctor,
          ),
        ],
      );

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffFailure] when doctor is not found',
        build: () {
          when(() => mockRepository.getStaffMember('user-doc-1'))
              .thenThrow(const NotFoundException(message: 'Doctor not found'));
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadDoctorProfile(doctorId: 'user-doc-1')),
        expect: () => [
          const StaffLoading(message: 'Loading doctor profile...'),
          const StaffFailure(
            message: 'The requested record could not be found or has been removed.',
          ),
        ],
      );
    });

    group('CreateStaffMemberRequested', () {
      final newDoctor = sampleDoctor.copyWith(id: 'user-doc-new', name: 'Dr. Newbie');

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffOperationSuccess, StaffLoaded] on successful creation',
        build: () {
          when(() => mockRepository.createStaffMember(
                name: any(named: 'name'),
                email: any(named: 'email'),
                password: any(named: 'password'),
                role: any(named: 'role'),
                phone: any(named: 'phone'),
                pin: any(named: 'pin'),
                jobTitle: any(named: 'jobTitle'),
                specialty: any(named: 'specialty'),
                licenseNumber: any(named: 'licenseNumber'),
                deaNumber: any(named: 'deaNumber'),
                bio: any(named: 'bio'),
                dateOfBirth: any(named: 'dateOfBirth'),
                isAvailable: any(named: 'isAvailable'),
              )).thenAnswer((_) async => newDoctor);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CreateStaffMemberRequested(
          name: 'Dr. Newbie',
          email: 'newbie@clinic.com',
          password: 'secretPassword123',
          role: StaffRole.doctor,
          pin: '1234',
          jobTitle: 'Associate Vet',
          specialty: 'Dentistry',
          licenseNumber: 'VET-9999',
          isAvailable: true,
        )),
        expect: () => [
          const StaffLoading(
            message: 'Registering new staff member...',
            isSubmitting: true,
          ),
          StaffOperationSuccess(
            message: 'Staff member Dr. Newbie registered successfully.',
            updatedStaff: newDoctor,
            staffMembers: [newDoctor],
          ),
          StaffLoaded(staffMembers: [newDoctor]),
        ],
      );

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffFailure] with fieldErrors when server returns 422 ValidationException',
        build: () {
          when(() => mockRepository.createStaffMember(
                name: any(named: 'name'),
                email: any(named: 'email'),
                password: any(named: 'password'),
                role: any(named: 'role'),
                phone: any(named: 'phone'),
                pin: any(named: 'pin'),
                jobTitle: any(named: 'jobTitle'),
                specialty: any(named: 'specialty'),
                licenseNumber: any(named: 'licenseNumber'),
                deaNumber: any(named: 'deaNumber'),
                bio: any(named: 'bio'),
                dateOfBirth: any(named: 'dateOfBirth'),
                isAvailable: any(named: 'isAvailable'),
              )).thenThrow(const ValidationException(
            message: 'The email has already been taken.',
            fieldErrors: {
              'email': ['The email has already been taken.']
            },
          ));
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CreateStaffMemberRequested(
          name: 'Dr. Jane Doe',
          email: 'jane.doe@clinic.com',
          password: 'secretPassword123',
          role: StaffRole.doctor,
        )),
        expect: () => [
          const StaffLoading(
            message: 'Registering new staff member...',
            isSubmitting: true,
          ),
          const StaffFailure(
            message: 'The email has already been taken.',
            fieldErrors: {
              'email': ['The email has already been taken.']
            },
          ),
        ],
      );
    });

    group('UpdateStaffMemberRequested', () {
      final updatedDoctor = sampleDoctor.copyWith(name: 'Dr. Jane Updated');

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffOperationSuccess, StaffLoaded] on successful update',
        seed: () => StaffLoaded(staffMembers: [sampleDoctor]),
        build: () {
          when(() => mockRepository.updateStaffMember(
                userId: any(named: 'userId'),
                name: any(named: 'name'),
                email: any(named: 'email'),
                role: any(named: 'role'),
                password: any(named: 'password'),
                phone: any(named: 'phone'),
                pin: any(named: 'pin'),
                jobTitle: any(named: 'jobTitle'),
                specialty: any(named: 'specialty'),
                licenseNumber: any(named: 'licenseNumber'),
                deaNumber: any(named: 'deaNumber'),
                bio: any(named: 'bio'),
                dateOfBirth: any(named: 'dateOfBirth'),
                isAvailable: any(named: 'isAvailable'),
              )).thenAnswer((_) async => updatedDoctor);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const UpdateStaffMemberRequested(
          userId: 'user-doc-1',
          name: 'Dr. Jane Updated',
          email: 'jane.doe@clinic.com',
          role: StaffRole.doctor,
        )),
        expect: () => [
          StaffLoading(
            message: 'Updating staff member...',
            isSubmitting: true,
            staffMembers: [sampleDoctor],
          ),
          StaffOperationSuccess(
            message: 'Staff member Dr. Jane Updated updated successfully.',
            updatedStaff: updatedDoctor,
            staffMembers: [updatedDoctor],
          ),
          StaffLoaded(staffMembers: [updatedDoctor]),
        ],
      );
    });

    group('ToggleStaffAvailabilityRequested', () {
      final offDutyDoctor = sampleDoctor.copyWith(
        profile: sampleDoctor.profile?.copyWith(isAvailable: false),
      );

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffOperationSuccess, StaffLoaded] when doctor availability is updated',
        seed: () => StaffLoaded(
          staffMembers: [sampleDoctor],
          selectedDoctor: sampleDoctor,
        ),
        build: () {
          when(() => mockRepository.updateAvailability(
                userId: 'user-doc-1',
                isAvailable: false,
              )).thenAnswer((_) async => offDutyDoctor);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const ToggleStaffAvailabilityRequested(
          userId: 'user-doc-1',
          isAvailable: false,
        )),
        expect: () => [
          StaffLoading(
            message: 'Updating on-duty availability...',
            isSubmitting: true,
            staffMembers: [sampleDoctor],
            selectedDoctor: sampleDoctor,
          ),
          StaffOperationSuccess(
            message: 'Practitioner availability updated to Off-Duty.',
            updatedStaff: offDutyDoctor,
            staffMembers: [offDutyDoctor],
            selectedDoctor: offDutyDoctor,
          ),
          StaffLoaded(
            staffMembers: [offDutyDoctor],
            selectedDoctor: offDutyDoctor,
          ),
        ],
      );
    });

    group('ToggleStaffStatusRequested', () {
      final suspendedDoctor = sampleDoctor.copyWith(isActive: false);

      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffOperationSuccess, StaffLoaded] when staff member is suspended',
        seed: () => StaffLoaded(staffMembers: [sampleDoctor]),
        build: () {
          when(() => mockRepository.updateStatus(
                userId: 'user-doc-1',
                isActive: false,
              )).thenAnswer((_) async => suspendedDoctor);
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const ToggleStaffStatusRequested(
          userId: 'user-doc-1',
          isActive: false,
        )),
        expect: () => [
          StaffLoading(
            message: 'Updating staff status...',
            isSubmitting: true,
            staffMembers: [sampleDoctor],
          ),
          StaffOperationSuccess(
            message: 'Staff member Dr. Jane Doe has been suspended.',
            updatedStaff: suspendedDoctor,
            staffMembers: [suspendedDoctor],
          ),
          StaffLoaded(staffMembers: [suspendedDoctor]),
        ],
      );
    });

    group('DeleteStaffMemberRequested', () {
      blocTest<StaffBloc, StaffState>(
        'emits [StaffLoading, StaffOperationSuccess, StaffLoaded] when staff member is removed',
        seed: () => StaffLoaded(staffMembers: [sampleDoctor, sampleOwner]),
        build: () {
          when(() => mockRepository.deleteStaffMember('user-doc-1'))
              .thenAnswer((_) async {});
          return StaffBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const DeleteStaffMemberRequested(userId: 'user-doc-1')),
        expect: () => [
          StaffLoading(
            message: 'Removing staff member...',
            isSubmitting: true,
            staffMembers: [sampleDoctor, sampleOwner],
          ),
          StaffOperationSuccess(
            message: 'Staff member removed successfully.',
            staffMembers: [sampleOwner],
          ),
          StaffLoaded(staffMembers: [sampleOwner]),
        ],
      );
    });
  });
}
