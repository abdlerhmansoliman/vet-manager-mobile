import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/patient_detail_screen.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/widgets/patient_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const sampleClient = ClientSummaryEntity(
    id: 'client-1',
    tenantId: 'tenant-1',
    clientType: 'individual',
    name: 'Sarah Connor',
    phonePrimary: '+1-555-0199',
    physicalAddress: '123 Cyber Way, Los Angeles',
  );

  final samplePatient = PatientEntity(
    id: 'pat-1',
    tenantId: 'tenant-1',
    clientId: 'client-1',
    nameOrTag: 'Wolfie',
    species: 'Canine',
    breed: 'German Shepherd',
    gender: 'male_neutered',
    age: 3,
    currentWeightKg: 34.2,
    allergies: const ['Penicillin'],
    syncStatus: 'pending_create',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  testWidgets('PatientCard renders patient name, breed, species, age, and owner info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatientCard(patient: samplePatient),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wolfie'), findsOneWidget);
    expect(find.text('• German Shepherd'), findsOneWidget);
    expect(find.text('Canine'), findsOneWidget);
    expect(find.text(' • 3 yrs'), findsOneWidget);
    expect(find.text(' • 34.2 kg'), findsOneWidget);
    expect(find.text('Sarah Connor (+1-555-0199)'), findsOneWidget);
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('PatientCard tapping morphs into PatientDetailScreen via OpenContainer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatientCard(patient: samplePatient),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on card
    await tester.tap(find.text('Wolfie'));
    await tester.pumpAndSettle();

    // Destination PatientDetailScreen is now displayed
    expect(find.byType(PatientDetailScreen), findsOneWidget);
    expect(find.text('Patient Demographics'), findsOneWidget);
    expect(find.text('HIGH-RISK ALLERGY ALERT'), findsOneWidget);
    expect(find.text('Penicillin'), findsOneWidget);
    expect(find.text('Start Case'), findsOneWidget);
  });
}
