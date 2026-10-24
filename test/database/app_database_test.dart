import 'dart:ffi';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() {
    // Spin up an isolated SQLite in-memory instance for testing
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift AppDatabase Relational & Multi-Tenant Schema', () {
    test('enforces foreign key constraints when inserting patient with invalid clientId', () async {
      expect(
        () async {
          await db.into(db.patientsTable).insert(
                PatientsTableCompanion.insert(
                  id: 'pat-001',
                  tenantId: 'tenant-alpha',
                  clientId: 'nonexistent-client-id',
                  nameOrTag: 'Max',
                  species: 'Canine',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('successfully inserts relational hierarchy: Client -> Patient -> Case -> SOAP Note', () async {
      final now = DateTime.now();

      // 1. Insert Client
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-101',
              tenantId: 'tenant-alpha',
              name: 'Sarah Connor',
              phonePrimary: '+1555019283',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 2. Insert Patient
      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'patient-201',
              tenantId: 'tenant-alpha',
              clientId: 'client-101',
              nameOrTag: 'Buster',
              species: 'Canine',
              breed: const Value('Golden Retriever'),
              currentWeightKg: const Value(31.450),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 3. Insert Case
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-301',
              tenantId: 'tenant-alpha',
              caseNumber: 'CAS-2026-0001',
              patientId: 'patient-201',
              primaryVeterinarianId: 'user-vet-42',
              chiefComplaint: 'Acute vomiting and lethargy',
              priority: const Value('urgent'),
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 4. Insert Progress Note
      await db.into(db.clinicalProgressNotesTable).insert(
            ClinicalProgressNotesTableCompanion.insert(
              id: 'note-401',
              caseId: 'case-301',
              patientId: 'patient-201',
              veterinarianId: 'user-vet-42',
              veterinarianName: 'Dr. Jane Smith, DVM',
              subjective: const Value('Owner reports 3 episodes of bilious emesis'),
              objective: const Value('Abdomen tense on cranial palpation'),
              temperatureCelsius: const Value(38.8),
              heartRateBpm: const Value(110),
              respiratoryRateBpm: const Value(24),
              recordedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 5. Query and verify relational cascade integrity
      final caseRecord = await (db.select(db.clinicalCasesTable)
            ..where((c) => c.id.equals('case-301')))
          .getSingle();

      expect(caseRecord.caseNumber, 'CAS-2026-0001');
      expect(caseRecord.priority, 'urgent');

      final notes = await (db.select(db.clinicalProgressNotesTable)
            ..where((n) => n.caseId.equals('case-301')))
          .get();

      expect(notes.length, 1);
      expect(notes.first.temperatureCelsius, 38.8);
      expect(notes.first.veterinarianName, 'Dr. Jane Smith, DVM');
    });

    test('isolates tenant data between different practice locations', () async {
      final now = DateTime.now();

      // Tenant 1: Downtown Animal Clinic
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-downtown',
              tenantId: 'clinic-downtown',
              name: 'Alice',
              phonePrimary: '555-1111',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Tenant 2: Uptown Veterinary Hospital
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-uptown',
              tenantId: 'clinic-uptown',
              name: 'Bob',
              phonePrimary: '555-2222',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final downtownClients = await (db.select(db.clientsTable)
            ..where((c) => c.tenantId.equals('clinic-downtown')))
          .get();

      final uptownClients = await (db.select(db.clientsTable)
            ..where((c) => c.tenantId.equals('clinic-uptown')))
          .get();

      expect(downtownClients.length, 1);
      expect(downtownClients.first.name, 'Alice');

      expect(uptownClients.length, 1);
      expect(uptownClients.first.name, 'Bob');
    });
  });
}
