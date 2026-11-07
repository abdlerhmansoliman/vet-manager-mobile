import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_session.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/auth_user.dart';
import 'package:vet_manager_mobile/features/auth/domain/models/clinic_tenant.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vet_manager_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/staff_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/vet_profile_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/repositories/staff_repository.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/screens/doctor_profile_screen.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/screens/staff_management_screen.dart';
import 'package:vet_manager_mobile/features/settings/presentation/screens/delete_account_screen.dart';
import 'package:vet_manager_mobile/features/settings/presentation/screens/medical_disclaimer_screen.dart';

class MockStaffRepository extends Mock implements IStaffRepository {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockStaffRepository mockRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockRepo = MockStaffRepository();
  });

  final sampleDoctor = StaffEntity(
    id: 'user-doc-1',
    name: 'Dr. Jane Doe',
    email: 'jane.doe@clinic.com',
    role: StaffRole.doctor,
    roleLabel: 'Doctor / Veterinarian',
    phone: '+1 555-0101',
    isActive: true,
    profile: const VetProfileEntity(
      id: 'prof-1',
      userId: 'user-doc-1',
      jobTitle: 'Senior Surgeon',
      specialty: 'Small Animal Surgery',
      licenseNumber: 'VET-88392',
      deaNumber: 'XD-9948271',
      bio: 'Over 12 years of clinical practice.',
      isAvailable: true,
      activeCasesCount: 5,
    ),
    activeCasesCount: 5,
    capabilities: StaffCapabilities.fromRole(StaffRole.doctor),
  );

  final sampleOwnerDoctor = StaffEntity(
    id: 'user-owner-1',
    name: 'Dr. Robert Director',
    email: 'owner@clinic.com',
    role: StaffRole.owner,
    roleLabel: 'Clinic Owner / Director',
    phone: '+1 555-0999',
    isActive: true,
    profile: const VetProfileEntity(
      id: 'prof-2',
      userId: 'user-owner-1',
      jobTitle: 'Medical Director',
      specialty: 'Equine Internal Medicine',
      licenseNumber: 'VET-11002',
      isAvailable: true,
      activeCasesCount: 2,
    ),
    activeCasesCount: 2,
    capabilities: StaffCapabilities.fromRole(StaffRole.owner),
  );

  Widget createTestWidget({
    StaffEntity? initialDoctor,
    String? doctorId,
  }) {
    return MaterialApp(
      home: DoctorProfileScreen(
        initialDoctor: initialDoctor,
        doctorId: doctorId,
        repository: mockRepo,
      ),
    );
  }

  group('DoctorProfileScreen UI & Credentials Display', () {
    testWidgets('renders doctor credentials, licensure, DEA, and workload cards', (tester) async {
      await tester.pumpWidget(createTestWidget(initialDoctor: sampleDoctor));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Senior Surgeon'), findsOneWidget);
      expect(find.text('Small Animal Surgery'), findsOneWidget);
      expect(find.text('Active Staff'), findsOneWidget);

      // Availability Switch
      expect(find.text('On-Duty Availability'), findsOneWidget);
      expect(find.text('Available for consultations & triage'), findsOneWidget);
      expect(find.byKey(const Key('doctor_availability_switch')), findsOneWidget);

      // Workload
      expect(find.text('Active Cases'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('DEA Witness'), findsOneWidget);
      expect(find.text('Authorized'), findsWidgets);

      // Licensure & Contact
      expect(find.text('VET-88392'), findsOneWidget);
      expect(find.text('XD-9948271'), findsOneWidget);
      expect(find.text('jane.doe@clinic.com'), findsOneWidget);
      expect(find.text('+1 555-0101'), findsOneWidget);
      expect(find.text('Over 12 years of clinical practice.'), findsOneWidget);

      // Authorizations
      expect(find.text('Prescribe Rx'), findsOneWidget);
      expect(find.text('Controlled Substances'), findsOneWidget);
      expect(find.text('Surgery Clearance'), findsOneWidget);
    });

    testWidgets('loads doctor profile dynamically via doctorId if initialDoctor is null', (tester) async {
      when(() => mockRepo.getStaffMember('user-doc-1')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return sampleDoctor;
      });

      await tester.pumpWidget(createTestWidget(doctorId: 'user-doc-1'));
      await tester.pump(); // In flight
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Resolved
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      verify(() => mockRepo.getStaffMember('user-doc-1')).called(1);
    });

    testWidgets('shows empty state instead of infinite loading if no doctor or auth exists', (tester) async {
      await tester.pumpWidget(createTestWidget(doctorId: null, initialDoctor: null));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Practitioner profile not found'), findsOneWidget);
    });

    testWidgets('resolves practitioner profile from AuthBloc when initialDoctor and doctorId are null', (tester) async {
      final mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(
        const AuthAuthenticated(
          AuthSession(
            token: 'test-tok',
            user: AuthUser(
              id: 'user-doc-1',
              name: 'Dr. Jane Doe',
              email: 'jane.doe@clinic.com',
              role: 'veterinarian',
              isActive: true,
            ),
            tenant: ClinicTenant(
              id: 'ten-1',
              name: 'Alpha Vet',
              slug: 'alphavet',
              status: 'active',
              plan: 'pro',
            ),
          ),
        ),
      );
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      when(() => mockRepo.getStaffMember('user-doc-1')).thenAnswer((_) async => sampleDoctor);

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: MaterialApp(
            home: DoctorProfileScreen(
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      verify(() => mockRepo.getStaffMember('user-doc-1')).called(1);
    });
  });

  group('DoctorProfileScreen Requests: PATCH /api/v1/staff/{user}/availability', () {
    testWidgets(
      'toggling switch triggers PATCH availability, shows in-flight spinner, updates UI and shows success banner',
      (tester) async {
        final offDutyDoctor = sampleDoctor.copyWith(
          profile: sampleDoctor.profile?.copyWith(isAvailable: false),
        );

        when(() => mockRepo.updateAvailability(
              userId: 'user-doc-1',
              isAvailable: false,
            )).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return offDutyDoctor;
        });

        await tester.pumpWidget(createTestWidget(initialDoctor: sampleDoctor));
        await tester.pumpAndSettle();

        final switchFinder = find.byKey(const Key('doctor_availability_switch'));
        expect(switchFinder, findsOneWidget);
        final switchWidget = tester.widget<Switch>(switchFinder);
        expect(switchWidget.value, isTrue);

        // Tap the switch to toggle to off-duty
        await tester.tap(switchFinder);
        await tester.pump(); // Start in-flight request

        // Verify in-flight spinner is visible and switch is temporarily replaced
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for request completion
        await tester.pumpAndSettle();

        // Verify repository called with exact contract
        verify(() => mockRepo.updateAvailability(
              userId: 'user-doc-1',
              isAvailable: false,
            )).called(1);

        // Verify success snackbar banner is displayed
        expect(find.text('Practitioner availability updated to Off-Duty.'), findsOneWidget);

        // Verify switch reflects new off-duty state
        expect(find.text('Off-duty / Not accepting new cases'), findsOneWidget);
        final updatedSwitch = tester.widget<Switch>(find.byKey(const Key('doctor_availability_switch')));
        expect(updatedSwitch.value, isFalse);
      },
    );

    testWidgets(
      'network failure during availability update shows clinical error banner and preserves state',
      (tester) async {
        when(() => mockRepo.updateAvailability(
              userId: 'user-doc-1',
              isAvailable: false,
            )).thenAnswer((_) async {
          throw const NetworkException(message: 'Connection timed out.');
        });

        await tester.pumpWidget(createTestWidget(initialDoctor: sampleDoctor));
        await tester.pumpAndSettle();

        final switchFinder = find.byKey(const Key('doctor_availability_switch'));
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Verify shielded error message appears
        expect(
          find.text('You are currently working offline. Data will sync automatically when connected.'),
          findsOneWidget,
        );

        // Verify switch remains enabled and did not permanently stick to invalid state
        expect(find.byKey(const Key('doctor_availability_switch')), findsOneWidget);
      },
    );
  });

  group('DoctorProfileScreen Owner Capabilities', () {
    testWidgets('shows Manage Clinic Staff action for Owner/HeadVet and navigates to StaffManagementScreen', (tester) async {
      when(() => mockRepo.getStaffMembers()).thenAnswer((_) async => [sampleOwnerDoctor]);

      await tester.pumpWidget(createTestWidget(initialDoctor: sampleOwnerDoctor));
      await tester.pumpAndSettle();

      // Owner should see staff management actions
      final appbarAction = find.byKey(const Key('manage_staff_appbar_action'));
      final bottomButton = find.byKey(const Key('manage_staff_bottom_button'));
      expect(appbarAction, findsOneWidget);
      expect(bottomButton, findsOneWidget);

      // Tap app bar action to navigate to staff management
      await tester.tap(appbarAction);
      await tester.pumpAndSettle();

      // Verifies StaffManagementScreen opened
      expect(find.byType(StaffManagementScreen), findsOneWidget);
      expect(find.text('Clinic Staff Directory'), findsOneWidget);
    });
  });

  group('DoctorProfileScreen Store Review & Legal Compliance', () {
    testWidgets('renders Legal & Account Privacy section and navigates to MedicalDisclaimerScreen', (tester) async {
      await tester.pumpWidget(createTestWidget(initialDoctor: sampleDoctor));
      await tester.pumpAndSettle();

      final disclaimerBtn = find.byKey(const Key('view_medical_disclaimer_button'));
      await tester.ensureVisible(disclaimerBtn);
      await tester.pumpAndSettle();

      expect(disclaimerBtn, findsOneWidget);
      expect(find.text('Medical & Legal Disclaimer'), findsOneWidget);

      await tester.tap(disclaimerBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MedicalDisclaimerScreen), findsOneWidget);
      expect(find.text('Clinical Decision Support'), findsOneWidget);
    });

    testWidgets('navigates to DeleteAccountScreen from Legal & Account Privacy section', (tester) async {
      await tester.pumpWidget(createTestWidget(initialDoctor: sampleDoctor));
      await tester.pumpAndSettle();

      final deleteBtn = find.byKey(const Key('delete_account_profile_button'));
      await tester.ensureVisible(deleteBtn);
      await tester.pumpAndSettle();

      expect(deleteBtn, findsOneWidget);
      expect(find.text('Delete Practitioner Account'), findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.byType(DeleteAccountScreen), findsOneWidget);
      expect(find.text('Permanent & Irreversible Action'), findsOneWidget);
    });
  });
}
