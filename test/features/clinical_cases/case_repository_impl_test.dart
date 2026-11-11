import 'dart:ffi';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/database/daos/clinical_case_dao.dart';
import 'package:vet_manager_mobile/features/clinical_cases/data/repositories/case_repository_impl.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late AppDatabase db;
  late ClinicalCaseDao dao;
  late MockSecureStorageService mockStorage;
  late CaseRepositoryImpl repository;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.clinicalCaseDao;
    mockStorage = MockSecureStorageService();
    when(() => mockStorage.getTenantId()).thenAnswer((_) async => 'tenant-test');

    repository = CaseRepositoryImpl(
      dao: dao,
      storageService: mockStorage,
    );

    // Seed master Client and Patient
    final now = DateTime.now();
    await db.into(db.clientsTable).insert(
          ClientsTableCompanion.insert(
            id: 'client-100',
            tenantId: 'tenant-test',
            name: 'Robert Davis',
            phonePrimary: '+1-555-8888',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.patientsTable).insert(
          PatientsTableCompanion.insert(
            id: 'patient-100',
            tenantId: 'tenant-test',
            clientId: 'client-100',
            nameOrTag: 'Oliver',
            species: 'Feline',
            breed: const Value('Maine Coon'),
            currentWeightKg: const Value(7.2),
            allergies: const Value('["Penicillin"]'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('CaseRepositoryImpl', () {
    test('openCase creates case, returns CaseSummaryEntity, and emits via watchCases', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-2026-99',
        chiefComplaint: 'Lethargy and decreased appetite',
        priority: 'urgent',
        primaryVeterinarianName: 'Dr. Anna Stone',
      );

      expect(summary.caseNumber, 'CAS-2026-99');
      expect(summary.patientName, 'Oliver');
      expect(summary.clientName, 'Robert Davis');
      expect(summary.priority, 'urgent');

      final activeCases = await repository.watchCases().first;
      expect(activeCases.length, 1);
      expect(activeCases.first.id, summary.id);
    });

    test('openCase automatically generates and attaches an Initial Consultation visit', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-AUTO-VISIT-01',
        chiefComplaint: 'Acute Limping',
        primaryVeterinarianName: 'Dr. Anna Stone',
      );

      final detail = await repository.getCaseDetail(summary.id);
      expect(detail, isNotNull);
      expect(detail!.visits.length, 1);
      expect(detail.visits.first.title, 'Initial Consultation');
      expect(detail.visits.first.status, 'open');
      expect(detail.visits.first.isLocked, isFalse);
    });

    test('addSoapNote appends note with vitals and can be queried via getCaseDetail', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-SOAP-01',
        chiefComplaint: 'Vomiting',
      );

      final note = await repository.addSoapNote(
        caseId: summary.id,
        patientId: 'patient-100',
        veterinarianId: 'vet-101',
        veterinarianName: 'Dr. Stone',
        subjective: 'Owner reports 2 vomiting episodes',
        objective: 'Abdomen soft non-painful',
        temperatureCelsius: 38.6,
        heartRateBpm: 120,
        respiratoryRateBpm: 24,
        bodyConditionScore: 5,
        painScore: 0,
      );

      expect(note.isSoap, isTrue);
      expect(note.temperatureCelsius, 38.6);
      expect(note.hasVitals, isTrue);

      final detail = await repository.getCaseDetail(summary.id);
      expect(detail, isNotNull);
      expect(detail!.progressNotes.length, 1);
      expect(detail.allergies, contains('Penicillin'));
      expect(detail.soapNotes.first.veterinarianName, 'Dr. Stone');
    });

    test('addAddendum creates immutable addendum entry', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-ADD-01',
        chiefComplaint: 'Trauma',
      );

      final addendum = await repository.addAddendum(
        caseId: summary.id,
        patientId: 'patient-100',
        veterinarianId: 'vet-101',
        veterinarianName: 'Dr. Stone',
        addendumText: 'Radiographs reviewed: no skeletal fractures noted.',
      );

      expect(addendum.isAddendum, isTrue);
      expect(addendum.assessment, contains('no skeletal fractures'));

      final detail = await repository.getCaseDetail(summary.id);
      expect(detail!.addenda.length, 1);
      expect(detail.addenda.first.assessment, contains('Radiographs'));
    });

    test('updatePriority, updateStatus and updateDiagnoses update encounter', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-UPD-01',
        chiefComplaint: 'Pyrexia',
        priority: 'routine',
      );

      await repository.updatePriority(caseId: summary.id, priority: 'critical');
      await repository.updateStatus(caseId: summary.id, status: 'in_progress');
      await repository.updateDiagnoses(
        caseId: summary.id,
        provisionalDiagnosis: 'Fever of Unknown Origin',
        finalDiagnosis: 'Feline Panleukopenia',
      );

      final detail = await repository.getCaseDetail(summary.id);
      expect(detail!.summary.priority, 'critical');
      expect(detail.summary.status, 'in_progress');
      expect(detail.summary.provisionalDiagnosis, 'Fever of Unknown Origin');
      expect(detail.summary.finalDiagnosis, 'Feline Panleukopenia');
    });

    test('watchCasesForPatient returns chronological cases for patient', () async {
      await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-PAT-01',
        chiefComplaint: 'Ear discharge',
        priority: 'routine',
      );

      final patientCases = await repository.watchCasesForPatient('patient-100').first;
      expect(patientCases.length, equals(1));
      expect(patientCases.first.caseNumber, equals('CAS-PAT-01'));
      expect(patientCases.first.patientName, equals('Oliver'));
    });

    test('startVisit, signVisit, and administerMedication manage hierarchical visit lifecycle', () async {
      final summary = await repository.openCase(
        patientId: 'patient-100',
        caseNumber: 'CAS-HIER-01',
        chiefComplaint: 'Dyspnea',
      );

      final visit = await repository.startVisit(
        caseId: summary.id,
        patientId: 'patient-100',
        veterinarianId: 'vet-100',
        veterinarianName: 'Dr. Anna Stone',
        title: 'Initial Consultation',
        visitType: 'consultation',
      );

      expect(visit.title, 'Initial Consultation');
      expect(visit.isOpen, isTrue);
      expect(visit.isLocked, isFalse);

      // Add SOAP note scoped to visit
      await repository.addSoapNote(
        caseId: summary.id,
        visitId: visit.id,
        patientId: 'patient-100',
        veterinarianId: 'vet-100',
        veterinarianName: 'Dr. Anna Stone',
        subjective: 'Tachypneic at rest',
        temperatureCelsius: 38.9,
      );

      // Administer medication in visit
      final dose = await repository.administerMedication(
        visitId: visit.id,
        caseId: summary.id,
        patientId: 'patient-100',
        medicineName: 'Furosemide',
        doseQuantity: '2.0',
        unit: 'mg/kg',
        route: 'IV',
        veterinarianId: 'vet-100',
        veterinarianName: 'Dr. Anna Stone',
      );

      expect(dose.medicineName, 'Furosemide');
      expect(dose.visitId, visit.id);

      // Sign visit
      await repository.signVisit(
        visitId: visit.id,
        signedBy: 'Dr. Anna Stone',
      );

      // Append addendum to signed visit
      await repository.addAddendum(
        caseId: summary.id,
        visitId: visit.id,
        patientId: 'patient-100',
        veterinarianId: 'vet-100',
        veterinarianName: 'Dr. Anna Stone',
        addendumText: 'Patient responded well to IV furosemide; RR decreased to 32 bpm.',
      );

      final visitDetail = await repository.getVisitDetail(visit.id);
      expect(visitDetail, isNotNull);
      expect(visitDetail!.isLocked, isTrue);
      expect(visitDetail.soapNote, isNotNull);
      expect(visitDetail.soapNote!.temperatureCelsius, 38.9);
      expect(visitDetail.doseAdministrations.length, 1);
      expect(visitDetail.addenda.length, 1);

      // CaseDetail bundle should include auto-created initial visit plus the started visit
      final caseDetail = await repository.getCaseDetail(summary.id);
      expect(caseDetail!.visits.length, 2);
      expect(caseDetail.visits.any((v) => v.id == visit.id), isTrue);
    });
  });
}
