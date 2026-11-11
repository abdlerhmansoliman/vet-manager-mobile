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
      expect(bundle.visits.length, 1);
      expect(bundle.visits.first.title, 'Initial Consultation');
    });

    test('getCaseDetailBundle auto-creates Initial Consultation visit if case had zero visits', () async {
      final now = DateTime.now();

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-legacy-no-visits',
              tenantId: 'tenant-1',
              caseNumber: 'CAS-LEGACY-01',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Old legacy case without visit',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Verify visits are empty before
      final beforeVisits = await dao.getVisitsForCase('case-legacy-no-visits');
      expect(beforeVisits.isEmpty, isTrue);

      // Fetch bundle -> automatically creates initial consultation visit
      final bundle = await dao.getCaseDetailBundle('case-legacy-no-visits');
      expect(bundle, isNotNull);
      expect(bundle!.visits.length, 1);
      expect(bundle.visits.first.title, 'Initial Consultation');
      expect(bundle.visits.first.status, 'open');

      // Verify it was persisted to SQLite visits table
      final afterVisits = await dao.getVisitsForCase('case-legacy-no-visits');
      expect(afterVisits.length, 1);
      expect(afterVisits.first.title, 'Initial Consultation');
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

    test('recordVisit creates visit encounter linked to case and signs/locks it', () async {
      final now = DateTime.now();

      final savedCase = await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-visit-test-1',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-VISIT-01',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          chiefComplaint: 'Vomiting and diarrhea',
          admittedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final savedVisit = await dao.recordVisit(
        tenantId: 'tenant-1',
        visitCompanion: VisitsTableCompanion.insert(
          id: 'visit-101',
          tenantId: 'tenant-1',
          caseId: savedCase.id,
          patientId: 'p-1',
          veterinarianId: 'vet-1',
          veterinarianName: 'Dr. Jane Smith',
          title: 'Initial Consultation',
          visitType: const Value('consultation'),
          visitDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(savedVisit.id, 'visit-101');
      expect(savedVisit.title, 'Initial Consultation');
      expect(savedVisit.isSigned, isFalse);

      final visits = await dao.getVisitsForCase(savedCase.id);
      expect(visits.length, 2);
      expect(visits.any((v) => v.id == 'visit-101'), isTrue);

      // Sign visit
      await dao.signVisit(
        visitId: 'visit-101',
        signedBy: 'Dr. Jane Smith',
        tenantId: 'tenant-1',
      );

      final signedVisit = await dao.getVisitById('visit-101');
      expect(signedVisit?.isSigned, isTrue);
      expect(signedVisit?.status, 'signed');
      expect(signedVisit?.signedBy, 'Dr. Jane Smith');

      // Record dose administration
      final dose = await dao.recordDoseAdministration(
        tenantId: 'tenant-1',
        doseCompanion: DoseAdministrationsTableCompanion.insert(
          id: 'dose-101',
          tenantId: 'tenant-1',
          visitId: 'visit-101',
          caseId: savedCase.id,
          patientId: 'p-1',
          medicineName: 'Maropitant (Cerenia)',
          doseQuantity: '1.0',
          unit: 'ml',
          route: 'SQ',
          veterinarianId: 'vet-1',
          veterinarianName: 'Dr. Jane Smith',
          administeredAt: now,
          createdAt: now,
        ),
      );

      expect(dose.id, 'dose-101');
      expect(dose.medicineName, 'Maropitant (Cerenia)');

      final doses = await dao.getDosesForVisit('visit-101');
      expect(doses.length, 1);
      expect(doses.first.id, 'dose-101');

      final bundle = await dao.getVisitDetailBundle('visit-101');
      expect(bundle, isNotNull);
      expect(bundle!.visit.id, 'visit-101');
      expect(bundle.doseAdministrations.length, 1);
    });

    test('updateCaseChiefComplaint updates complaint and logs sync queue mutation', () async {
      final now = DateTime.now();
      final caseToEdit = await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-complaint-1',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-CC-001',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          admittedAt: now,
          chiefComplaint: 'Old Complaint',
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(caseToEdit.chiefComplaint, 'Old Complaint');

      final rows = await dao.updateCaseChiefComplaint(
        'case-complaint-1',
        'Updated Acute Gastroenteritis',
        tenantId: 'tenant-1',
      );

      expect(rows, 1);

      final updated = await dao.getCaseById('case-complaint-1');
      expect(updated?.chiefComplaint, 'Updated Acute Gastroenteritis');

      final syncItems = await db.select(db.syncQueueTable).get();
      final caseSync = syncItems.where((s) => s.entityType == 'case' && s.action == 'update' && s.entityId == 'case-complaint-1');
      expect(caseSync.isNotEmpty, isTrue);
    });

    test('updateVisitDetails updates visit title, type and logs sync queue mutation', () async {
      final now = DateTime.now();
      await dao.recordCase(
        tenantId: 'tenant-1',
        caseCompanion: ClinicalCasesTableCompanion.insert(
          id: 'case-visit-edit',
          tenantId: 'tenant-1',
          caseNumber: 'CAS-VE-001',
          patientId: 'p-1',
          primaryVeterinarianId: 'vet-1',
          admittedAt: now,
          chiefComplaint: 'Observation',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await dao.recordVisit(
        tenantId: 'tenant-1',
        visitCompanion: VisitsTableCompanion.insert(
          id: 'visit-to-edit',
          tenantId: 'tenant-1',
          caseId: 'case-visit-edit',
          patientId: 'p-1',
          veterinarianId: 'vet-1',
          veterinarianName: 'Dr. Jane Smith',
          title: 'Initial Encounter',
          visitType: const Value('consultation'),
          visitDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final rows = await dao.updateVisitDetails(
        'visit-to-edit',
        title: 'Follow-up Day 2 - Ultrasound Examination',
        visitType: 'follow_up',
        tenantId: 'tenant-1',
      );

      expect(rows, 1);

      final updatedVisit = await dao.getVisitById('visit-to-edit');
      expect(updatedVisit?.title, 'Follow-up Day 2 - Ultrasound Examination');
      expect(updatedVisit?.visitType, 'follow_up');

      final syncItems = await db.select(db.syncQueueTable).get();
      final visitSync = syncItems.where((s) => s.entityType == 'visit' && s.action == 'update' && s.entityId == 'visit-to-edit');
      expect(visitSync.isNotEmpty, isTrue);
    });
  });
}
