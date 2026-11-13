import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/create_patient_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/cases_board_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/clinic_home_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/visit_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/case_detail_screen.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/visit_detail_screen.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/staff_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/vet_profile_entity.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/repositories/staff_repository.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/screens/doctor_profile_screen.dart';
import 'package:vet_manager_mobile/features/staff_profile/presentation/screens/staff_management_screen.dart';
import 'package:vet_manager_mobile/l10n/app_localizations.dart';

class MockPatientRepository extends Mock implements IPatientRepository {}
class MockCaseRepository extends Mock implements ICaseRepository {}
class MockStaffRepository extends Mock implements IStaffRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockPatientRepository mockPatientRepo;
  late MockCaseRepository mockCaseRepo;

  setUp(() {
    mockPatientRepo = MockPatientRepository();
    mockCaseRepo = MockCaseRepository();

    when(() => mockCaseRepo.watchCases(query: any(named: 'query')))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockPatientRepo.watchPatients(
          query: any(named: 'query'),
          speciesFilter: any(named: 'speciesFilter'),
        )).thenAnswer((_) => Stream.value([]));
  });

  const sampleClient = ClientSummaryEntity(
    id: 'cl-1',
    tenantId: 'tenant-1',
    clientType: 'individual',
    name: 'Sarah Connor',
    phonePrimary: '+1-555-0199',
  );

  final samplePatient = PatientEntity(
    id: 'pat-1',
    tenantId: 'tenant-1',
    clientId: 'cl-1',
    nameOrTag: 'Max',
    species: 'Canine',
    breed: 'Labrador',
    gender: 'neutered_male',
    age: 4,
    currentWeightKg: 29.0,
    allergies: const ['Penicillin'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  Widget createTestWidget({
    required Widget child,
    required Locale locale,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
  }

  group('Arabic Localization Verification', () {
    testWidgets('CreatePatientScreen displays all Arabic labels and localized species in registration mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: CreatePatientScreen(repository: mockPatientRepo),
        ),
      );
      await tester.pumpAndSettle();

      // Title & section headers in Arabic
      expect(find.text('تسجيل مريض جديد'), findsOneWidget);
      expect(find.text('بيانات وهوية المريض'), findsOneWidget);
      expect(find.text('التعريف والبيانات الطبية'), findsOneWidget);
      expect(find.text('بيانات المربي / المالك'), findsOneWidget);

      // Localized species choice chips in Arabic
      expect(find.text('كلاب'), findsWidgets);
      expect(find.text('قطط'), findsOneWidget);
      expect(find.text('خيول'), findsOneWidget);
      expect(find.text('أبقار'), findsOneWidget);
      expect(find.text('أغنام'), findsOneWidget);
      expect(find.text('ماعز'), findsOneWidget);
      expect(find.text('طيور'), findsOneWidget);
      expect(find.text('أخرى'), findsOneWidget);

      // Submit button in Arabic
      expect(find.text('حفظ المريض ومزامنة البيانات'), findsOneWidget);
    });

    testWidgets('CreatePatientScreen displays Arabic title when editing patient', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: CreatePatientScreen(
            repository: mockPatientRepo,
            initialPatient: samplePatient,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Edit title in Arabic
      expect(find.text('تعديل ملف المريض'), findsOneWidget);
      expect(find.text('حفظ التغييرات'), findsOneWidget);
    });

    testWidgets('CasesBoardScreen renders Arabic triage title and priority tabs', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: CasesBoardScreen(repository: mockCaseRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لوحة فرز الحالات'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('حرجة'), findsOneWidget);
      expect(find.text('عاجلة'), findsOneWidget);
      expect(find.text('عادية'), findsOneWidget);
    });

    testWidgets('ClinicHomeScreen renders Arabic bottom navigation destinations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: ClinicHomeScreen(
            caseRepository: mockCaseRepo,
            patientRepository: mockPatientRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الحالات الطبية'), findsOneWidget);
      expect(find.text('سجل المرضى'), findsOneWidget);
    });

    testWidgets('DoctorProfileScreen renders Arabic headers and clinical workload', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      final mockStaffRepo = MockStaffRepository();

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: DoctorProfileScreen(
            repository: mockStaffRepo,
            initialDoctor: sampleDoctor,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الملف المهني للطبيب'), findsOneWidget);
      expect(find.text('العيادة الطبية'), findsOneWidget);
      expect(find.text('الاعتمادات والتراخيص المهنية'), findsOneWidget);
      expect(find.text('الصلاحيات السريرية'), findsOneWidget);
      expect(find.text('الشؤون القانونية والخصوصية'), findsOneWidget);
    });

    testWidgets('StaffManagementScreen renders Arabic app bar and filter chips', (tester) async {
      final mockStaffRepo = MockStaffRepository();
      when(() => mockStaffRepo.getStaffMembers()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: StaffManagementScreen(repository: mockStaffRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('دليل كادر العيادة'), findsOneWidget);
      expect(find.text('كافة الكادر'), findsOneWidget);
      expect(find.text('الأطباء البيطريون'), findsOneWidget);
    });

    testWidgets('CaseDetailScreen renders Arabic case details and visits section', (tester) async {
      final now = DateTime(2026, 10, 24, 15, 0);
      final sampleSummary = CaseSummaryEntity(
        id: 'case-test-1',
        tenantId: 'tenant-1',
        caseNumber: 'CAS-2026-0042',
        patientId: 'pat-101',
        patientName: 'Rusty',
        species: 'Canine',
        breed: 'Golden Retriever',
        ageFormatted: '5 yrs',
        currentWeightKg: 31.5,
        clientId: 'cl-101',
        clientName: 'John Smith',
        clientPhone: '555-9999',
        primaryVeterinarianId: 'vet-1',
        primaryVeterinarianName: 'Dr. Anna Stone',
        priority: 'urgent',
        status: 'open',
        chiefComplaint: 'Dyspnea and acute respiratory distress',
        provisionalDiagnosis: 'Congestive Heart Failure',
        finalDiagnosis: 'Dilated Cardiomyopathy',
        admittedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final sampleDetail = CaseDetailEntity(
        summary: sampleSummary,
        allergies: const ['Cephalexin'],
        diagnoses: const [],
        visits: const [],
      );

      when(() => mockCaseRepo.watchCaseDetail('case-test-1'))
          .thenAnswer((_) => Stream.value(sampleDetail));

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: CaseDetailScreen(
            caseId: 'case-test-1',
            repository: mockCaseRepo,
            initialDetail: sampleDetail,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CAS-2026-0042'), findsOneWidget);
      expect(find.text('الزيارات والكشوفات السريرية'), findsOneWidget);
      expect(find.text('الشكوى الرئيسية'), findsOneWidget);
      expect(find.text('التشخيص والفرضيات السريرية'), findsOneWidget);
    });

    testWidgets('VisitDetailScreen renders Arabic SOAP exam and immutable addenda sections', (tester) async {
      final now = DateTime(2026, 10, 24, 15, 0);
      final openVisit = VisitEntity(
        id: 'vis-open-1',
        caseId: 'case-101',
        patientId: 'pat-101',
        veterinarianId: 'vet-1',
        veterinarianName: 'Dr. Anna Stone',
        title: 'Consultation - Nov 11, 2026',
        visitType: 'consultation',
        status: 'open',
        isSigned: false,
        visitDate: now,
        createdAt: now,
        updatedAt: now,
        addenda: const [],
        doseAdministrations: const [],
      );

      when(() => mockCaseRepo.watchVisitDetail('vis-open-1'))
          .thenAnswer((_) => Stream.value(openVisit));

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          child: VisitDetailScreen(
            caseId: 'case-101',
            visitId: 'vis-open-1',
            caseRepository: mockCaseRepo,
            initialVisit: openVisit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الفحص السريري الشامل (SOAP)'), findsOneWidget);
      expect(find.text('الملاحق السريرية الثابتة'), findsOneWidget);
      expect(find.text('تسجيل الفحص السريري (SOAP)'), findsOneWidget);
      expect(find.text('إعطاء جرعة'), findsOneWidget);
    });
  });

  group('English Localization Verification', () {
    testWidgets('CreatePatientScreen displays English labels when locale is English', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('en'),
          child: CreatePatientScreen(repository: mockPatientRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Register Patient'), findsOneWidget);
      expect(find.text('Patient Identity'), findsOneWidget);
      expect(find.text('Canine'), findsWidgets);
      expect(find.text('Feline'), findsOneWidget);
      expect(find.text('Save Patient & Enqueue Sync'), findsOneWidget);
    });

    testWidgets('CasesBoardScreen renders English triage title and priority tabs', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('en'),
          child: CasesBoardScreen(repository: mockCaseRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Triage Board'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.text('Routine'), findsOneWidget);
    });
  });
}
