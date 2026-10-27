import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/create_patient_screen.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/patient_list_screen.dart';

class MockPatientRepository extends Mock implements IPatientRepository {}

void main() {
  late MockPatientRepository mockRepository;
  late StreamController<List<PatientEntity>> streamController;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const sampleClient = ClientSummaryEntity(
    id: 'client-1',
    tenantId: 'tenant-1',
    clientType: 'individual',
    name: 'Emily Thorne',
    phonePrimary: '+1-555-0199',
  );

  final sampleDog = PatientEntity(
    id: 'pat-1',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Sammy',
    species: 'Canine',
    breed: 'Golden Retriever',
    gender: 'male_neutered',
    age: 4,
    currentWeightKg: 28.5,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  final sampleCat = PatientEntity(
    id: 'pat-2',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Mochi',
    species: 'Feline',
    breed: 'Siamese',
    gender: 'female_spayed',
    age: 2,
    currentWeightKg: 4.2,
    createdAt: DateTime(2026, 1, 2),
    updatedAt: DateTime(2026, 1, 2),
    client: sampleClient,
  );

  setUp(() {
    mockRepository = MockPatientRepository();
    streamController = StreamController<List<PatientEntity>>.broadcast();

    when(
      () => mockRepository.watchPatients(
        query: any(named: 'query'),
        speciesFilter: any(named: 'speciesFilter'),
      ),
    ).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  testWidgets('PatientListScreen renders empty state when stream yields no patients', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatientListScreen(repository: mockRepository),
      ),
    );

    streamController.add([]);
    await tester.pumpAndSettle();

    expect(find.text('Patients & Clients'), findsOneWidget);
    expect(find.text('No patients in this clinic yet'), findsOneWidget);
    expect(find.text('New Patient'), findsOneWidget);
  });

  testWidgets('PatientListScreen renders patient list and handles filter chip tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatientListScreen(repository: mockRepository),
      ),
    );

    streamController.add([sampleDog, sampleCat]);
    await tester.pumpAndSettle();

    expect(find.text('Sammy'), findsOneWidget);
    expect(find.text('Mochi'), findsOneWidget);

    // Tap 'Feline' choice chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Feline'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.watchPatients(
        query: any(named: 'query'),
        speciesFilter: 'Feline',
      ),
    ).called(1);
  });

  testWidgets('PatientListScreen FAB navigates to CreatePatientScreen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatientListScreen(repository: mockRepository),
      ),
    );

    streamController.add([sampleDog]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Patient'));
    await tester.pumpAndSettle();

    expect(find.byType(CreatePatientScreen), findsOneWidget);
    expect(find.text('Register Patient'), findsOneWidget);
    expect(find.text('Patient Name / Ear Tag *'), findsOneWidget);
    expect(find.text('Species *'), findsOneWidget);

    // Drag to scroll to the Owner section
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Owner / Contact Name *'), findsOneWidget);
  });
}
