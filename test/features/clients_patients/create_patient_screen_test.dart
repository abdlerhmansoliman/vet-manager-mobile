import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/repositories/patient_repository.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/create_patient_screen.dart';

class MockPatientRepository extends Mock implements IPatientRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockPatientRepository mockRepository;

  setUp(() {
    mockRepository = MockPatientRepository();
  });

  const sampleClient = ClientSummaryEntity(
    id: 'client-1',
    tenantId: 'tenant-1',
    clientType: 'individual',
    name: 'Sarah Connor',
    phonePrimary: '+1-555-2026',
    phoneSecondary: '+1-555-2027',
    physicalAddress: '123 Cyberdyne Blvd',
  );

  final samplePatient = PatientEntity(
    id: 'pat-1',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Wolfie',
    species: 'Canine',
    breed: 'German Shepherd',
    gender: 'male_neutered',
    age: 5,
    earTagId: 'TAG-001',
    microchipNumber: '981098123456789',
    currentWeightKg: 32.5,
    allergies: const ['Penicillin', 'Chicken'],
    notes: 'Friendly dog',
    history: 'Prior dental cleaning in 2024.',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  testWidgets('CreatePatientScreen in create mode starts with empty fields and default title', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: CreatePatientScreen(repository: mockRepository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Register Patient'), findsOneWidget);
    expect(find.text('Save Patient & Enqueue Sync'), findsOneWidget);
    expect(find.text('Canine'), findsWidgets);
  });

  testWidgets('CreatePatientScreen in edit mode pre-populates existing patient data and shows Edit title', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(
      MaterialApp(
        home: CreatePatientScreen(
          repository: mockRepository,
          initialPatient: samplePatient,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Patient Profile'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Wolfie'), findsOneWidget);
    expect(find.text('German Shepherd'), findsOneWidget);
    expect(find.text('32.5'), findsOneWidget);
    expect(find.text('981098123456789'), findsOneWidget);
    expect(find.text('Sarah Connor'), findsOneWidget);
    expect(find.text('+1-555-2026'), findsOneWidget);
  });

  testWidgets('CreatePatientScreen in edit mode calls updatePatient on submit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepository.updatePatient(
          patientId: any(named: 'patientId'),
          nameOrTag: any(named: 'nameOrTag'),
          species: any(named: 'species'),
          breed: any(named: 'breed'),
          gender: any(named: 'gender'),
          age: any(named: 'age'),
          isApproximateAge: any(named: 'isApproximateAge'),
          microchipNumber: any(named: 'microchipNumber'),
          earTagId: any(named: 'earTagId'),
          currentWeightKg: any(named: 'currentWeightKg'),
          allergies: any(named: 'allergies'),
          history: any(named: 'history'),
          notes: any(named: 'notes'),
          clientName: any(named: 'clientName'),
          clientPhonePrimary: any(named: 'clientPhonePrimary'),
          clientAddress: any(named: 'clientAddress'),
        )).thenAnswer((_) async => samplePatient);

    await tester.pumpWidget(
      MaterialApp(
        home: CreatePatientScreen(
          repository: mockRepository,
          initialPatient: samplePatient,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll down to submit button and tap
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.updatePatient(
          patientId: 'pat-1',
          nameOrTag: 'Wolfie',
          species: 'Canine',
          breed: 'German Shepherd',
          gender: 'male_neutered',
          age: 5,
          isApproximateAge: false,
          microchipNumber: '981098123456789',
          earTagId: 'TAG-001',
          currentWeightKg: 32.5,
          allergies: ['Penicillin', 'Chicken'],
          history: 'Prior dental cleaning in 2024.',
          notes: 'Friendly dog',
          clientName: 'Sarah Connor',
          clientPhonePrimary: '+1-555-2026',
          clientAddress: '123 Cyberdyne Blvd',
        )).called(1);
  });
}
