import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/clinical_case_dao.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/entities/progress_note_entity.dart';
import '../../domain/repositories/case_repository.dart';

/// Concrete implementation of [ICaseRepository] backed by Drift SQLite [ClinicalCaseDao].
class CaseRepositoryImpl implements ICaseRepository {
  final ClinicalCaseDao _dao;
  final ISecureStorageService _storageService;
  final Uuid _uuid;

  CaseRepositoryImpl({
    required ClinicalCaseDao dao,
    required ISecureStorageService storageService,
    Uuid? uuid,
  })  : _dao = dao,
        _storageService = storageService,
        _uuid = uuid ?? const Uuid();

  Future<String> _getTenantId() async {
    return await _storageService.getTenantId() ?? 'default';
  }

  @override
  Stream<List<CaseSummaryEntity>> watchCases({
    String? priority,
    String? query,
  }) async* {
    final tenantId = await _getTenantId();
    yield* _dao
        .watchCasesWithDetails(
          tenantId: tenantId,
          priority: priority,
          query: query,
        )
        .map((bundles) => bundles.map(_mapSummaryBundleToEntity).toList());
  }

  @override
  Stream<List<CaseSummaryEntity>> watchCasesForPatient(String patientId) {
    return _dao
        .watchCasesForPatientWithDetails(patientId)
        .map((bundles) => bundles.map(_mapSummaryBundleToEntity).toList());
  }

  @override
  Stream<CaseDetailEntity?> watchCaseDetail(String caseId) {
    return _dao.watchCaseDetailBundle(caseId).map((bundle) {
      if (bundle == null) return null;
      return _mapDetailBundleToEntity(bundle);
    });
  }

  @override
  Future<CaseDetailEntity?> getCaseDetail(String caseId) async {
    final bundle = await _dao.getCaseDetailBundle(caseId);
    if (bundle == null) return null;
    return _mapDetailBundleToEntity(bundle);
  }

  @override
  Future<CaseSummaryEntity> openCase({
    required String patientId,
    required String caseNumber,
    required String chiefComplaint,
    String priority = 'routine',
    String caseType = 'outpatient',
    String? primaryVeterinarianId,
    String? primaryVeterinarianName,
    String? provisionalDiagnosis,
  }) async {
    final tenantId = await _getTenantId();
    final now = DateTime.now();
    final caseId = _uuid.v7();

    final companion = ClinicalCasesTableCompanion.insert(
      id: caseId,
      tenantId: tenantId,
      caseNumber: caseNumber,
      patientId: patientId,
      primaryVeterinarianId: primaryVeterinarianId ?? 'vet-current',
      primaryVeterinarianName: Value(primaryVeterinarianName ?? 'Attending Clinician'),
      caseType: Value(caseType),
      status: const Value('open'),
      priority: Value(priority.toLowerCase()),
      chiefComplaint: chiefComplaint,
      provisionalDiagnosis: provisionalDiagnosis != null ? Value(provisionalDiagnosis) : const Value.absent(),
      admittedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _dao.recordCase(
      tenantId: tenantId,
      caseCompanion: companion,
    );

    // Fetch detail bundle to construct full summary
    final detail = await _dao.getCaseDetailBundle(saved.id);
    if (detail != null) {
      return _mapSummaryBundleToEntity(CaseSummaryBundle(
        clinicalCase: detail.clinicalCase,
        patient: detail.patient,
        client: detail.client,
      ));
    }

    // Fallback if joined patient record cannot be read immediately
    return CaseSummaryEntity(
      id: saved.id,
      tenantId: saved.tenantId,
      caseNumber: saved.caseNumber,
      patientId: saved.patientId,
      patientName: 'Patient',
      species: 'Canine',
      clientId: 'unknown',
      clientName: 'Owner',
      clientPhone: '',
      primaryVeterinarianId: saved.primaryVeterinarianId,
      primaryVeterinarianName: saved.primaryVeterinarianName,
      caseType: saved.caseType,
      status: saved.status,
      priority: saved.priority,
      chiefComplaint: saved.chiefComplaint,
      provisionalDiagnosis: saved.provisionalDiagnosis,
      admittedAt: saved.admittedAt,
      createdAt: saved.createdAt,
      updatedAt: saved.updatedAt,
      syncStatus: saved.syncStatus,
    );
  }

  @override
  Future<ProgressNoteEntity> addSoapNote({
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    double? temperatureCelsius,
    int? heartRateBpm,
    int? respiratoryRateBpm,
    int? bodyConditionScore,
    int? painScore,
    DateTime? recordedAt,
  }) async {
    final tenantId = await _getTenantId();
    final now = DateTime.now();
    final noteId = _uuid.v7();

    final companion = ClinicalProgressNotesTableCompanion.insert(
      id: noteId,
      caseId: caseId,
      patientId: patientId,
      veterinarianId: veterinarianId,
      veterinarianName: veterinarianName,
      noteType: const Value('soap'),
      subjective: subjective != null ? Value(subjective) : const Value.absent(),
      objective: objective != null ? Value(objective) : const Value.absent(),
      assessment: assessment != null ? Value(assessment) : const Value.absent(),
      plan: plan != null ? Value(plan) : const Value.absent(),
      temperatureCelsius: temperatureCelsius != null ? Value(temperatureCelsius) : const Value.absent(),
      heartRateBpm: heartRateBpm != null ? Value(heartRateBpm) : const Value.absent(),
      respiratoryRateBpm: respiratoryRateBpm != null ? Value(respiratoryRateBpm) : const Value.absent(),
      bodyConditionScore: bodyConditionScore != null ? Value(bodyConditionScore) : const Value.absent(),
      painScore: painScore != null ? Value(painScore) : const Value.absent(),
      recordedAt: recordedAt ?? now,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _dao.recordProgressNote(
      tenantId: tenantId,
      noteCompanion: companion,
    );

    return _mapProgressNoteDataToEntity(saved);
  }

  @override
  Future<ProgressNoteEntity> addAddendum({
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    required String addendumText,
    DateTime? recordedAt,
  }) async {
    final tenantId = await _getTenantId();
    final now = DateTime.now();
    final noteId = _uuid.v7();

    final companion = ClinicalProgressNotesTableCompanion.insert(
      id: noteId,
      caseId: caseId,
      patientId: patientId,
      veterinarianId: veterinarianId,
      veterinarianName: veterinarianName,
      noteType: const Value('addendum'),
      assessment: Value(addendumText),
      recordedAt: recordedAt ?? now,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _dao.recordProgressNote(
      tenantId: tenantId,
      noteCompanion: companion,
    );

    return _mapProgressNoteDataToEntity(saved);
  }

  @override
  Future<void> updatePriority({
    required String caseId,
    required String priority,
  }) async {
    final tenantId = await _getTenantId();
    await _dao.updateCasePriority(
      caseId,
      priority,
      tenantId: tenantId,
    );
  }

  @override
  Future<void> updateStatus({
    required String caseId,
    required String status,
  }) async {
    final tenantId = await _getTenantId();
    await _dao.updateCaseStatus(
      caseId,
      status,
      tenantId: tenantId,
    );
  }

  @override
  Future<void> updateDiagnoses({
    required String caseId,
    String? provisionalDiagnosis,
    String? finalDiagnosis,
  }) async {
    final tenantId = await _getTenantId();
    await _dao.updateCaseDiagnoses(
      caseId,
      provisionalDiagnosis: provisionalDiagnosis,
      finalDiagnosis: finalDiagnosis,
      tenantId: tenantId,
    );
  }

  // Helper mappers
  CaseSummaryEntity _mapSummaryBundleToEntity(CaseSummaryBundle bundle) {
    final c = bundle.clinicalCase;
    final p = bundle.patient;
    final cl = bundle.client;

    String? ageFormatted;
    if (p.age != null) {
      ageFormatted = '${p.age} yrs';
    } else if (p.dateOfBirth != null) {
      final days = DateTime.now().difference(p.dateOfBirth!).inDays;
      if (days < 365) {
        final months = (days / 30).floor();
        ageFormatted = '$months mos';
      } else {
        final years = (days / 365).floor();
        ageFormatted = '$years yrs';
      }
    }

    return CaseSummaryEntity(
      id: c.id,
      tenantId: c.tenantId,
      caseNumber: c.caseNumber,
      patientId: c.patientId,
      patientName: p.nameOrTag,
      species: p.species,
      breed: p.breed,
      ageFormatted: ageFormatted,
      currentWeightKg: p.currentWeightKg,
      clientId: cl.id,
      clientName: cl.name,
      clientPhone: cl.phonePrimary,
      primaryVeterinarianId: c.primaryVeterinarianId,
      primaryVeterinarianName: c.primaryVeterinarianName,
      caseType: c.caseType,
      status: c.status,
      priority: c.priority,
      chiefComplaint: c.chiefComplaint,
      provisionalDiagnosis: c.provisionalDiagnosis,
      finalDiagnosis: c.finalDiagnosis,
      admittedAt: c.admittedAt,
      dischargedAt: c.dischargedAt,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      syncStatus: c.syncStatus,
    );
  }

  CaseDetailEntity _mapDetailBundleToEntity(CaseDetailBundle bundle) {
    final summary = _mapSummaryBundleToEntity(CaseSummaryBundle(
      clinicalCase: bundle.clinicalCase,
      patient: bundle.patient,
      client: bundle.client,
    ));

    return CaseDetailEntity(
      summary: summary,
      clientAddress: bundle.client.physicalAddress,
      allergies: bundle.patient.allergies != null
          ? List<String>.from(_parseJsonList(bundle.patient.allergies))
          : const [],
      progressNotes: bundle.progressNotes.map(_mapProgressNoteDataToEntity).toList(),
      diagnoses: bundle.diagnoses.map(_mapDiagnosisDataToEntity).toList(),
    );
  }

  ProgressNoteEntity _mapProgressNoteDataToEntity(ClinicalProgressNoteData n) {
    return ProgressNoteEntity(
      id: n.id,
      caseId: n.caseId,
      patientId: n.patientId,
      veterinarianId: n.veterinarianId,
      veterinarianName: n.veterinarianName,
      noteType: n.noteType,
      subjective: n.subjective,
      objective: n.objective,
      assessment: n.assessment,
      plan: n.plan,
      temperatureCelsius: n.temperatureCelsius,
      heartRateBpm: n.heartRateBpm,
      respiratoryRateBpm: n.respiratoryRateBpm,
      bodyConditionScore: n.bodyConditionScore,
      painScore: n.painScore,
      recordedAt: n.recordedAt,
      createdAt: n.createdAt,
      syncStatus: n.syncStatus,
    );
  }

  DiagnosisEntity _mapDiagnosisDataToEntity(DiagnosisData d) {
    return DiagnosisEntity(
      id: d.id,
      patientId: d.patientId,
      caseId: d.caseId,
      userId: d.userId,
      diagnosis: d.diagnosis,
      description: d.description,
      status: d.status,
      notes: d.notes,
      diagnosedAt: d.diagnosedAt,
    );
  }

  List<dynamic> _parseJsonList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }
}
