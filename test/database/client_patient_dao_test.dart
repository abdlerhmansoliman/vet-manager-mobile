import 'dart:ffi';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/database/daos/client_patient_dao.dart';

void main() {
  late AppDatabase db;
  late ClientPatientDao dao;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.clientPatientDao;
  });

  tearDown(() async {
    await db.close();
  });

  const tenantId = 'tenant-clinic-1';

  group('ClientPatientDao — Relational Queries & Stream Reactivity', () {
    test('watchPatientsWithClient joins patients and clients and reacts to new inserts', () async {
      final now = DateTime.now().toUtc();

      // 1. Insert owner
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-1',
              tenantId: tenantId,
              name: 'Dr. Ellie Sattler',
              phonePrimary: '+1-555-0199',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 2. Insert patient
      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-1',
              tenantId: tenantId,
              clientId: 'client-1',
              nameOrTag: 'Rex',
              species: 'Canine',
              breed: const Value('German Shepherd'),
              gender: const Value('male_neutered'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final streamResult = await dao.watchPatientsWithClient(tenantId: tenantId).first;

      expect(streamResult.length, equals(1));
      expect(streamResult.first.patient.id, equals('pat-1'));
      expect(streamResult.first.patient.nameOrTag, equals('Rex'));
      expect(streamResult.first.client.id, equals('client-1'));
      expect(streamResult.first.client.name, equals('Dr. Ellie Sattler'));
    });

    test('watchPatientsWithClient correctly filters by species', () async {
      final now = DateTime.now().toUtc();

      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-multi',
              tenantId: tenantId,
              name: 'John Hammond',
              phonePrimary: '+1-555-0100',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-dog',
              tenantId: tenantId,
              clientId: 'client-multi',
              nameOrTag: 'Buster',
              species: 'Canine',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-cat',
              tenantId: tenantId,
              clientId: 'client-multi',
              nameOrTag: 'Luna',
              species: 'Feline',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dogList = await dao
          .watchPatientsWithClient(tenantId: tenantId, speciesFilter: 'Canine')
          .first;
      expect(dogList.length, equals(1));
      expect(dogList.first.patient.nameOrTag, equals('Buster'));

      final catList = await dao
          .watchPatientsWithClient(tenantId: tenantId, speciesFilter: 'feline')
          .first;
      expect(catList.length, equals(1));
      expect(catList.first.patient.nameOrTag, equals('Luna'));

      final allList = await dao
          .watchPatientsWithClient(tenantId: tenantId, speciesFilter: 'All')
          .first;
      expect(allList.length, equals(2));
    });

    test('watchPatientsWithClient performs cross-entity search on name, microchip, ear tag, owner name, and phone', () async {
      final now = DateTime.now().toUtc();

      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-alex',
              tenantId: tenantId,
              name: 'Alex Murphy',
              phonePrimary: '+1-313-555-0142',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-robodog',
              tenantId: tenantId,
              clientId: 'client-alex',
              nameOrTag: 'K9-Titan',
              species: 'Canine',
              microchipNumber: const Value('981098123456789'),
              earTagId: const Value('TAG-DELTA-7'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 1. Search by pet name
      final res1 = await dao.watchPatientsWithClient(tenantId: tenantId, query: 'titan').first;
      expect(res1.length, equals(1));

      // 2. Search by RFID microchip
      final res2 = await dao.watchPatientsWithClient(tenantId: tenantId, query: '981098').first;
      expect(res2.length, equals(1));

      // 3. Search by livestock ear tag
      final res3 = await dao.watchPatientsWithClient(tenantId: tenantId, query: 'DELTA-7').first;
      expect(res3.length, equals(1));

      // 4. Search by owner name
      final res4 = await dao.watchPatientsWithClient(tenantId: tenantId, query: 'murphy').first;
      expect(res4.length, equals(1));

      // 5. Search by phone number
      final res5 = await dao.watchPatientsWithClient(tenantId: tenantId, query: '555-0142').first;
      expect(res5.length, equals(1));

      // 6. Search non-matching
      final res6 = await dao.watchPatientsWithClient(tenantId: tenantId, query: 'nonexistent').first;
      expect(res6.isEmpty, isTrue);
    });

    test('getPatientWithClient returns single profile bundle or null if not found', () async {
      final now = DateTime.now().toUtc();

      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-single',
              tenantId: tenantId,
              name: 'Dr. Ian Malcolm',
              phonePrimary: '+1-555-9999',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-chaos',
              tenantId: tenantId,
              clientId: 'client-single',
              nameOrTag: 'Chaos',
              species: 'Feline',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final found = await dao.getPatientWithClient(tenantId: tenantId, patientId: 'pat-chaos');
      expect(found, isNotNull);
      expect(found!.patient.nameOrTag, equals('Chaos'));
      expect(found.client.name, equals('Dr. Ian Malcolm'));

      final notFound = await dao.getPatientWithClient(tenantId: tenantId, patientId: 'invalid-id');
      expect(notFound, isNull);
    });
  });

  group('ClientPatientDao — Atomic Registration & Offline Sync Enqueueing', () {
    test('registerClientAndPatient inserts new client, new patient, and generates 2 sync outbox items', () async {
      final now = DateTime.now().toUtc();

      final clientCompanion = ClientsTableCompanion.insert(
        id: 'client-new-001',
        tenantId: tenantId,
        name: 'Sarah Connor',
        phonePrimary: '+1-555-2026',
        createdAt: now,
        updatedAt: now,
      );

      final patientCompanion = PatientsTableCompanion.insert(
        id: 'pat-new-001',
        tenantId: tenantId,
        clientId: 'client-new-001',
        nameOrTag: 'Wolfie',
        species: 'Canine',
        breed: const Value('German Shepherd'),
        currentWeightKg: const Value(32.5),
        allergies: const Value('["Penicillin", "Chicken"]'),
        createdAt: now,
        updatedAt: now,
      );

      final result = await dao.registerClientAndPatient(
        tenantId: tenantId,
        clientCompanion: clientCompanion,
        patientCompanion: patientCompanion,
      );

      expect(result.patient.id, equals('pat-new-001'));
      expect(result.client.id, equals('client-new-001'));

      // Verify sync queue outbox records
      final syncQueueItems = await db.select(db.syncQueueTable).get();
      expect(syncQueueItems.length, equals(2));

      final clientQueueItem = syncQueueItems.firstWhere((q) => q.entityType == 'client');
      expect(clientQueueItem.entityId, equals('client-new-001'));
      expect(clientQueueItem.action, equals('create'));
      expect(clientQueueItem.idempotencyKey.length, greaterThanOrEqualTo(36));

      final patientQueueItem = syncQueueItems.firstWhere((q) => q.entityType == 'patient');
      expect(patientQueueItem.entityId, equals('pat-new-001'));
      expect(patientQueueItem.action, equals('create'));
      expect(patientQueueItem.idempotencyKey.length, greaterThanOrEqualTo(36));
    });

    test('registerClientAndPatient with existing client attaches patient and only enqueues patient mutation', () async {
      final now = DateTime.now().toUtc();

      // Pre-insert existing client
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'client-existing',
              tenantId: tenantId,
              name: 'Alan Grant',
              phonePrimary: '+1-555-8888',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final clientCompanion = ClientsTableCompanion.insert(
        id: 'client-existing',
        tenantId: tenantId,
        name: 'Alan Grant',
        phonePrimary: '+1-555-8888',
        createdAt: now,
        updatedAt: now,
      );

      final patientCompanion = PatientsTableCompanion.insert(
        id: 'pat-raptor',
        tenantId: tenantId,
        clientId: 'client-existing',
        nameOrTag: 'Blue',
        species: 'Avian',
        createdAt: now,
        updatedAt: now,
      );

      final result = await dao.registerClientAndPatient(
        tenantId: tenantId,
        clientCompanion: clientCompanion,
        patientCompanion: patientCompanion,
      );

      expect(result.patient.id, equals('pat-raptor'));
      expect(result.client.id, equals('client-existing'));

      // Only patient should be queued in sync queue
      final syncQueueItems = await db.select(db.syncQueueTable).get();
      expect(syncQueueItems.length, equals(1));
      expect(syncQueueItems.first.entityType, equals('patient'));
      expect(syncQueueItems.first.entityId, equals('pat-raptor'));
    });
  });
}
