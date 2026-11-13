import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/species_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/case_entity.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/repositories/case_repository.dart';
import 'package:vet_manager_mobile/features/clinical_cases/presentation/screens/clinic_home_screen.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}
class MockPatientRepository extends Mock implements IPatientRepository {}

void main() {
  late MockCaseRepository mockCaseRepo;
  late MockPatientRepository mockPatientRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCaseRepo = MockCaseRepository();
    mockPatientRepo = MockPatientRepository();

    when(() => mockCaseRepo.watchCases(query: any(named: 'query')))
        .thenAnswer((_) => Stream.value(<CaseSummaryEntity>[]));
    when(() => mockPatientRepo.watchPatients(
          query: any(named: 'query'),
          speciesFilter: any(named: 'speciesFilter'),
        )).thenAnswer((_) => Stream.value(<PatientEntity>[]));
    when(() => mockPatientRepo.watchSpecies())
        .thenAnswer((_) => Stream.value(<SpeciesEntity>[]));
  });

  Widget buildTestableWidget({int initialIndex = 0}) {
    return MaterialApp(
      home: ClinicHomeScreen(
        caseRepository: mockCaseRepo,
        patientRepository: mockPatientRepo,
        initialIndex: initialIndex,
      ),
    );
  }

  group('ClinicHomeScreen', () {
    testWidgets('renders Triage Board by default at index 0', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Triage Board'), findsOneWidget);
      expect(find.text('Triage Cases'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
    });

    testWidgets('switches to Patients tab when bottom nav destination tapped', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap on Patients destination in navigation bar
      await tester.tap(find.text('Patients'));
      await tester.pumpAndSettle();

      // Should show Patient directory screen header
      expect(find.text('Patients & Clients'), findsOneWidget);
      expect(find.text('Offline-first animal registry'), findsOneWidget);
    });

    testWidgets('switches back to Triage Board from Patients tab', (tester) async {
      await tester.pumpWidget(buildTestableWidget(initialIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text('Patients & Clients'), findsOneWidget);

      // Tap on Triage Cases
      await tester.tap(find.text('Triage Cases'));
      await tester.pumpAndSettle();

      expect(find.text('Triage Board'), findsOneWidget);
    });
  });
}
