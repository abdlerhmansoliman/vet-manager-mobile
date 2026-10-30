import 'dart:ffi';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/database/daos/clinical_case_dao.dart';

void main() {
  late AppDatabase db;
  late ClinicalCaseDao dao;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.clinicalCaseDao;

    // Seed master records
    final now = DateTime.now();
    await db.into(db.clientsTable).insert(
          ClientsTableCompanion.insert(
            id: 'c-1',
            tenantId: 'tenant-1',
            name: 'John Doe',
            phonePrimary: '555-0100',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.patientsTable).insert(
          PatientsTableCompanion.insert(
            id: 'p-1',
            tenantId: 'tenant-1',
            clientId: 'c-1',
            nameOrTag: 'Luna',
            species: 'Feline',
            breed: const Value('Siamese'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('ClinicalCaseDao Operations', () {
    test('watchActiveCases orders emergency cases by priority: critical -> urgent -> routine', () async {
      final baseTime = DateTime(2026, 10, 24, 10, 0);

      // 1. Routine case created earliest
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-routine',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-ROUTINE',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Annual vaccination & wellness check',
              priority: const Value('routine'),
              admittedAt: baseTime,
              createdAt: baseTime,
              updatedAt: baseTime,
            ),
          );

      // 2. Urgent case created middle
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-urgent',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-URGENT',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Deep laceration on right paw',
              priority: const Value('urgent'),
              admittedAt: baseTime.add(const Duration(minutes: 15)),
              createdAt: baseTime.add(const Duration(minutes: 15)),
              updatedAt: baseTime.add(const Duration(minutes: 15)),
            ),
          );

      // 3. Critical case created latest
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-critical',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-CRITICAL',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Status epilepticus / cluster seizures',
              priority: const Value('critical'),
              admittedAt: baseTime.add(const Duration(minutes: 30)),
              createdAt: baseTime.add(const Duration(minutes: 30)),
              updatedAt: baseTime.add(const Duration(minutes: 30)),
            ),
          );

      final activeCases = await dao.watchActiveCases(tenantId: 'tenant-1').first;

      expect(activeCases.length, 3);
      // Critical must be first regardless of timestamp
      expect(activeCases[0].priority, 'critical');
      expect(activeCases[0].caseNumber, 'CAS-CRITICAL');

      // Urgent must be second
      expect(activeCases[1].priority, 'urgent');
      expect(activeCases[1].caseNumber, 'CAS-URGENT');

      // Routine must be third
      expect(activeCases[2].priority, 'routine');
      expect(activeCases[2].caseNumber, 'CAS-ROUTINE');
    });

    test('getCaseDetailBundle aggregates complete relational encounter', () async {
      final now = DateTime.now();

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-bundle-1',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-B-001',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Suspected foreign body ingestion',
              priority: const Value('urgent'),
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.clinicalProgressNotesTable).insert(
            ClinicalProgressNotesTableCompanion.insert(
              id: 'note-b-1',
              caseId: 'case-bundle-1',
              patientId: 'p-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. Evans, DVM',
              objective: const Value('Palpable firm mass in mid-abdomen'),
              recordedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.diagnosesTable).insert(
            DiagnosesTableCompanion.insert(
              id: 'diag-b-1',
              patientId: 'p-1',
              caseId: const Value('case-bundle-1'),
              userId: 'vet-1',
              diagnosis: 'Gastric Foreign Body Obstruction',
              diagnosedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final bundle = await dao.getCaseDetailBundle('case-bundle-1');

      expect(bundle, isNotNull);
      expect(bundle!.clinicalCase.caseNumber, 'CAS-B-001');
      expect(bundle.patient.nameOrTag, 'Luna');
      expect(bundle.client.name, 'John Doe');
      expect(bundle.progressNotes.length, 1);
      expect(bundle.progressNotes.first.veterinarianName, 'Dr. Evans, DVM');
      expect(bundle.diagnoses.length, 1);
      expect(bundle.diagnoses.first.diagnosis, 'Gastric Foreign Body Obstruction');
    });

    test('searchCases filters correctly by case number and chief complaint', () async {
      final now = DateTime.now();

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-search-1',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-DOG-88',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Fractured canine tooth',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final searchByCode = await dao.searchCases(tenantId: 'tenant-1', query: 'DOG-88');
      expect(searchByCode.length, 1);
      expect(searchByCode.first.id, 'case-search-1');

      final searchByComplaint = await dao.searchCases(tenantId: 'tenant-1', query: 'tooth');
      expect(searchByComplaint.length, 1);
      expect(searchByComplaint.first.id, 'case-search-1');

      final searchNone = await dao.searchCases(tenantId: 'tenant-1', query: 'orthopedic');
      expect(searchNone, isEmpty);
    });

    test('updateCaseStatus and softDeleteCase correctly transition lifecycle', () async {
      final now = DateTime.now();

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-life-1',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-LIFE-1',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Routine checkup',
              status: const Value('open'),
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await dao.updateCaseStatus('case-life-1', 'in_progress');
      var updatedCase = await dao.getCaseById('case-life-1');
      expect(updatedCase?.status, 'in_progress');

      await dao.softDeleteCase('case-life-1');
      updatedCase = await dao.getCaseById('case-life-1');
      expect(updatedCase?.deletedAt, isNotNull);
      expect(updatedCase?.syncStatus, 'pending_delete');

      // watchActiveCases must filter out deleted cases
      final activeCases = await dao.watchActiveCases(tenantId: 'tenant-1').first;
      expect(activeCases.where((c) => c.id == 'case-life-1'), isEmpty);
    });

    test('watchCasesWithDetails joins patient & client and filters by priority & query', () async {
      final baseTime = DateTime(2026, 10, 24, 12, 0);

      // Insert another patient
      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'p-2',
              tenantId: 'tenant-1',
              clientId: 'c-1',
              nameOrTag: 'Barnaby',
              species: 'Canine',
              breed: const Value('Beagle'),
              createdAt: baseTime,
              updatedAt: baseTime,
            ),
          );

      // Case 1: Routine for Luna
      await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-join-1',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-JOIN-01',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          chiefComplaint: 'Healthy booster injection',
          priority: const Value('routine'),
          admittedAt: baseTime,
          createdAt: baseTime,
          updatedAt: baseTime,
        ),
      );

      // Case 2: Urgent for Barnaby
      await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-join-2',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-JOIN-02',
          patientId: 'p-2',
          primaryVeterinarianId: 'vet-1',
          chiefComplaint: 'Sudden lameness in hind leg',
          priority: const Value('urgent'),
          admittedAt: baseTime.add(const Duration(minutes: 10)),
          createdAt: baseTime.add(const Duration(minutes: 10)),
          updatedAt: baseTime.add(const Duration(minutes: 10)),
        ),
      );

      // Query all active cases with details
      final allDetailed = await dao.watchCasesWithDetails(tenantId: 'tenant-1').first;
      expect(allDetailed.length, 2);
      expect(allDetailed[0].clinicalCase.priority, 'urgent');
      expect(allDetailed[0].patient.nameOrTag, 'Barnaby');
      expect(allDetailed[0].client.name, 'John Doe');
      expect(allDetailed[1].clinicalCase.priority, 'routine');
      expect(allDetailed[1].patient.nameOrTag, 'Luna');

      // Filter by priority: routine
      final routineCases = await dao.watchCasesWithDetails(tenantId: 'tenant-1', priority: 'routine').first;
      expect(routineCases.length, 1);
      expect(routineCases.first.patient.nameOrTag, 'Luna');

      // Filter by query: 'lameness'
      final queriedCases = await dao.watchCasesWithDetails(tenantId: 'tenant-1', query: 'lameness').first;
      expect(queriedCases.length, 1);
      expect(queriedCases.first.patient.nameOrTag, 'Barnaby');
    });

    test('recordProgressNote inserts SOAP note and enqueues sync queue record', () async {
      final now = DateTime.now();

      final savedCase = await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-rec-1',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-REC-01',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          chiefComplaint: 'Dehydration',
          priority: const Value('routine'),
          admittedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(savedCase.id, 'case-rec-1');

      // Verify sync queue for case creation
      final queueItems = await db.select(db.syncQueueTable).get();
      expect(queueItems.any((q) => q.entityId == 'case-rec-1' && q.action == 'create'), isTrue);

      // Record a SOAP Progress Note
      final savedNote = await dao.recordProgressNote(
        tenantId: 'tenant-1',
        noteCompanion: ClinicalProgressNotesTableCompanion.insert(
          id: 'note-rec-1',
          caseId: 'case-rec-1',
          patientId: 'p-1',
          veterinarianId: 'vet-1',
          veterinarianName: 'Dr. Jane Smith',
          subjective: const Value('Mild lethargy'),
          objective: const Value('CRT 2s, skin tenting slightly delayed'),
          temperatureCelsius: const Value(38.6),
          heartRateBpm: const Value(120),
          respiratoryRateBpm: const Value(28),
          recordedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(savedNote.id, 'note-rec-1');
      expect(savedNote.temperatureCelsius, 38.6);

      // Verify sync queue for note creation
      final updatedQueue = await db.select(db.syncQueueTable).get();
      expect(updatedQueue.any((q) => q.entityId == 'note-rec-1' && q.entityType == 'clinical_progress_note'), isTrue);
    });

    test('updateCasePriority transitions severity and logs sync mutation', () async {
      final now = DateTime.now();

      await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-prio-1',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-PRIO-01',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          chiefComplaint: 'Coughing',
          priority: const Value('routine'),
          admittedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await dao.updateCasePriority('case-prio-1', 'critical', tenantId: 'tenant-1');
      final updated = await dao.getCaseById('case-prio-1');
      expect(updated?.priority, 'critical');

      final queue = await db.select(db.syncQueueTable).get();
      expect(queue.any((q) => q.entityId == 'case-prio-1' && q.action == 'update'), isTrue);
    });
  });
}
