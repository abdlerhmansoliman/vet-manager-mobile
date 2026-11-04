import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/staff_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/vet_profile_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/repositories/staff_repository.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/screens/staff_management_screen.dart';

class MockStaffRepository extends Mock implements IStaffRepository {}

void main() {
  late MockStaffRepository mockRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(StaffRole.doctor);
  });

  setUp(() {
    mockRepo = MockStaffRepository();
  });

  final sampleDoctor = StaffEntity(
    id: 'user-1',
    name: 'Dr. Jane Doe',
    email: 'jane.doe@clinic.com',
    role: StaffRole.doctor,
    roleLabel: 'Doctor / Veterinarian',
    phone: '+1 555-0101',
    isActive: true,
    profile: const VetProfileEntity(
      id: 'prof-1',
      userId: 'user-1',
      jobTitle: 'Senior Surgeon',
      specialty: 'Surgery',
      licenseNumber: 'VET-88392',
      isAvailable: true,
      activeCasesCount: 4,
    ),
    activeCasesCount: 4,
    capabilities: StaffCapabilities.fromRole(StaffRole.doctor),
  );

  final sampleTech = StaffEntity(
    id: 'user-2',
    name: 'Alex Technician',
    email: 'alex@clinic.com',
    role: StaffRole.vetTech,
    roleLabel: 'Veterinary Technician',
    isActive: true,
    capabilities: StaffCapabilities.fromRole(StaffRole.vetTech),
  );

  Widget createTestWidget() {
    return MaterialApp(
      home: StaffManagementScreen(
        repository: mockRepo,
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('StaffManagementScreen Requests: GET /api/v1/staff', () {
    testWidgets('shows loading skeleton while fetching and then renders staff cards', (tester) async {
      configureViewport(tester);
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return [sampleDoctor, sampleTech];
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // In flight

      // Verify circular indicators in loading skeleton
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle(); // Settled

      // Verify rendered staff members
      expect(find.text('Clinic Staff Directory'), findsOneWidget);
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Alex Technician'), findsOneWidget);
      expect(find.text('Surgery'), findsOneWidget);
      expect(find.text('Active'), findsNWidgets(2));
    });

    testWidgets('shows error retry banner upon network failure and allows retry', (tester) async {
      configureViewport(tester);
      var callCount = 0;
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw const NetworkException(message: 'Network offline.');
        }
        return [sampleDoctor];
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unable to load staff directory'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap Try Again
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(callCount, 2);
    });

    testWidgets('filters staff directory by search query and role filter chips', (tester) async {
      configureViewport(tester);
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor, sampleTech]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Alex Technician'), findsOneWidget);

      // Search for "Alex"
      await tester.enterText(find.byKey(const Key('staff_search_field')), 'Alex');
      await tester.pumpAndSettle();

      expect(find.text('Alex Technician'), findsOneWidget);
      expect(find.text('Dr. Jane Doe'), findsNothing);

      // Clear search
      await tester.enterText(find.byKey(const Key('staff_search_field')), '');
      await tester.pumpAndSettle();

      // Tap "Veterinarians" role chip
      await tester.tap(find.text('Veterinarians'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Alex Technician'), findsNothing);
    });
  });

  group('StaffManagementScreen Requests: POST /api/v1/staff', () {
    testWidgets('client-side validation verifies required fields, email format, and 4-digit PIN', (tester) async {
      configureViewport(tester);
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap FAB to open registration sheet
      await tester.tap(find.byKey(const Key('add_staff_fab')));
      await tester.pumpAndSettle();

      expect(find.text('Register New Staff Member'), findsOneWidget);

      // Tap submit with empty fields
      final submitButton = find.byKey(const Key('staff_form_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter staff member full name.'), findsOneWidget);
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Password must be at least 8 characters.'), findsOneWidget);

      // Enter invalid email and invalid PIN
      await tester.enterText(find.byKey(const Key('staff_form_name_field')), 'Dr. New Doc');
      await tester.enterText(find.byKey(const Key('staff_form_email_field')), 'invalid-email');
      await tester.enterText(find.byKey(const Key('staff_form_password_field')), 'short');
      await tester.enterText(find.byKey(const Key('staff_form_pin_field')), '12');

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address format.'), findsOneWidget);
      expect(find.text('Password must be at least 8 characters.'), findsOneWidget);
      expect(find.text('PIN must be exactly 4 numeric digits.'), findsOneWidget);

      verifyNever(() => mockRepo.createStaffMember(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
          ));
    });

    testWidgets('maps 422 Laravel validation error inline and displays error text', (tester) async {
      configureViewport(tester);
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor]);

      when(() => mockRepo.createStaffMember(
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
          'email': ['The email has already been taken.'],
        },
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_staff_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('staff_form_name_field')), 'Dr. Duplicate');
      await tester.enterText(find.byKey(const Key('staff_form_email_field')), 'jane.doe@clinic.com');
      await tester.enterText(find.byKey(const Key('staff_form_password_field')), 'password123');

      final submitButton = find.byKey(const Key('staff_form_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Inline Laravel 422 validation error
      expect(find.text('The email has already been taken.'), findsWidgets);
    });

    testWidgets('successful POST shows in-flight spinner, closes sheet, and shows success banner', (tester) async {
      configureViewport(tester);
      final createdStaff = StaffEntity(
        id: 'user-new',
        name: 'Dr. Sarah Smith',
        email: 'sarah.smith@clinic.com',
        role: StaffRole.doctor,
        roleLabel: 'Doctor / Veterinarian',
        isActive: true,
        capabilities: StaffCapabilities.fromRole(StaffRole.doctor),
      );

      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor]);

      when(() => mockRepo.createStaffMember(
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
          )).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return createdStaff;
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_staff_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('staff_form_name_field')), 'Dr. Sarah Smith');
      await tester.enterText(find.byKey(const Key('staff_form_email_field')), 'sarah.smith@clinic.com');
      await tester.enterText(find.byKey(const Key('staff_form_password_field')), 'securePassword123');
      await tester.enterText(find.byKey(const Key('staff_form_pin_field')), '9876');

      final submitButton = find.byKey(const Key('staff_form_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump(); // In flight

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.text('Staff member Dr. Sarah Smith registered successfully.'), findsOneWidget);
      expect(find.text('Dr. Sarah Smith'), findsOneWidget);
    });
  });

  group('StaffManagementScreen Requests: PATCH /api/v1/staff/{user}/status', () {
    testWidgets('status toggle shows confirmation dialog, executes PATCH status, and updates badge', (tester) async {
      configureViewport(tester);
      final suspendedDoctor = sampleDoctor.copyWith(isActive: false);

      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor]);

      when(() => mockRepo.updateStatus(
            userId: 'user-1',
            isActive: false,
          )).thenAnswer((_) async => suspendedDoctor);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);

      // Open popup menu for Dr. Jane Doe
      await tester.tap(find.byKey(const Key('staff_menu_user-1')));
      await tester.pumpAndSettle();

      // Tap Suspend Staff
      await tester.tap(find.text('Suspend Staff'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Suspend Staff Member?'), findsOneWidget);

      // Confirm suspension
      await tester.tap(find.byKey(const Key('confirm_status_toggle_button')));
      await tester.pumpAndSettle();

      verify(() => mockRepo.updateStatus(
            userId: 'user-1',
            isActive: false,
          )).called(1);

      expect(find.text('Staff member Dr. Jane Doe has been suspended.'), findsOneWidget);
      expect(find.text('Suspended'), findsOneWidget);
    });
  });

  group('StaffManagementScreen Requests: DELETE /api/v1/staff/{user}', () {
    testWidgets('soft-delete shows confirmation modal, executes DELETE request, and removes staff from list', (tester) async {
      configureViewport(tester);
      when(() => mockRepo.getStaffMembers(
            role: any(named: 'role'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => [sampleDoctor, sampleTech]);

      when(() => mockRepo.deleteStaffMember('user-1')).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dr. Jane Doe'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byKey(const Key('staff_menu_user-1')));
      await tester.pumpAndSettle();

      // Tap Remove Staff
      await tester.tap(find.text('Remove Staff'));
      await tester.pumpAndSettle();

      // Verify soft delete confirmation dialog
      expect(find.text('Remove Staff Member?'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.byKey(const Key('confirm_delete_staff_button')));
      await tester.pumpAndSettle();

      verify(() => mockRepo.deleteStaffMember('user-1')).called(1);

      expect(find.text('Staff member removed successfully.'), findsOneWidget);
      expect(find.text('Dr. Jane Doe'), findsNothing);
      expect(find.text('Alex Technician'), findsOneWidget);
    });
  });
}
