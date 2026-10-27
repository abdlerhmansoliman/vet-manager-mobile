import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/features/clients_patients/domain/entities/patient_entity.dart';
import 'package:vet_manager_mobile/features/clients_patients/presentation/screens/patient_detail_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const sampleClient = ClientSummaryEntity(
    id: 'client-9',
    tenantId: 'tenant-1',
    clientType: 'commercial_farm',
    name: 'Green Meadows Ranch',
    phonePrimary: '+1-555-4422',
    phoneSecondary: '+1-555-4423',
    physicalAddress: 'County Road 44, Section 12',
  );

  final samplePatient = PatientEntity(
    id: 'pat-9',
    tenantId: 'tenant-1',
    clientId: 'client-9',
    nameOrTag: 'Bessie',
    species: 'Bovine',
    breed: 'Holstein',
    gender: 'female_intact',
    age: 4,
    earTagId: 'TAG-COW-909',
    microchipNumber: '981000999888777',
    currentWeightKg: 620.0,
    coatColorMarkings: 'Black and White Spotted',
    allergies: const ['Penicillin G', 'Oxytetracycline'],
    notes: 'Caution: kicks when palpated',
    history: 'Vaccinated for BVD in 2025.',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: sampleClient,
  );

  testWidgets('PatientDetailScreen renders hero, allergy warnings, demographics, owner and actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatientDetailScreen(patient: samplePatient),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Hero header
    expect(find.text('Bessie'), findsWidgets);
    expect(find.text('Bovine'), findsOneWidget);
    expect(find.text('Holstein'), findsOneWidget);
    expect(find.text('4 yrs • Female (Intact)'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    // 2. High-risk allergies
    expect(find.text('HIGH-RISK ALLERGY ALERT'), findsOneWidget);
    expect(find.text('Penicillin G'), findsOneWidget);
    expect(find.text('Oxytetracycline'), findsOneWidget);

    // 3. Demographics
    expect(find.text('Patient Demographics'), findsOneWidget);
    expect(find.text('620.0 kg'), findsOneWidget);
    expect(find.text('981000999888777'), findsOneWidget);
    expect(find.text('TAG-COW-909'), findsOneWidget);
    expect(find.text('Black and White Spotted'), findsOneWidget);

    // 4. Owner card
    expect(find.text('Registered Owner'), findsOneWidget);
    expect(find.text('COMMERCIAL_FARM'), findsOneWidget);
    expect(find.text('Green Meadows Ranch'), findsOneWidget);
    expect(find.text('+1-555-4422'), findsOneWidget);
    expect(find.text('County Road 44, Section 12'), findsOneWidget);

    // 5. Medical notes
    expect(find.text('Caution: kicks when palpated'), findsOneWidget);
    expect(find.text('Vaccinated for BVD in 2025.'), findsOneWidget);

    // 6. Action button
    expect(find.text('Start Case'), findsOneWidget);
  });
}
