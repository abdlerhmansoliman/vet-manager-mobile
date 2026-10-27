import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/client_patient_dao.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';

/// Concrete implementation of [IPatientRepository] utilizing local SQLite via [ClientPatientDao].
class PatientRepositoryImpl implements IPatientRepository {
  final ClientPatientDao _dao;
  final ISecureStorageService _storageService;
  final Uuid _uuid;

  PatientRepositoryImpl({
    required ClientPatientDao dao,
    required ISecureStorageService storageService,
    Uuid? uuid,
  })  : _dao = dao,
        _storageService = storageService,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<PatientEntity>> watchPatients({
    String? query,
    String? speciesFilter,
  }) async* {
    final tenantId = await _storageService.getTenantId() ?? 'default';

    yield* _dao
        .watchPatientsWithClient(
          tenantId: tenantId,
          query: query,
          speciesFilter: speciesFilter,
        )
        .map((records) => records.map(_mapPatientWithClientToEntity).toList());
  }

  @override
  Future<PatientEntity?> getPatientById(String patientId) async {
    final tenantId = await _storageService.getTenantId() ?? 'default';
    final result = await _dao.getPatientWithClient(
      tenantId: tenantId,
      patientId: patientId,
    );
    if (result == null) return null;
    return _mapPatientWithClientToEntity(result);
  }

  @override
  Future<PatientEntity> registerPatient({
    required String nameOrTag,
    required String species,
    String? breed,
    required String gender,
    int? age,
    DateTime? dateOfBirth,
    bool isApproximateAge = false,
    String? microchipNumber,
    String? earTagId,
    String? coatColorMarkings,
    double? currentWeightKg,
    String? history,
    String? notes,
    List<String> allergies = const [],
    String? existingClientId,
    String? clientName,
    String? clientPhonePrimary,
    String? clientPhoneSecondary,
    String? clientAddress,
  }) async {
    final tenantId = await _storageService.getTenantId() ?? 'default';
    final now = DateTime.now().toUtc();

    final clientId = (existingClientId != null && existingClientId.isNotEmpty)
        ? existingClientId
        : _uuid.v7();

    final clientCompanion = ClientsTableCompanion(
      id: Value(clientId),
      tenantId: Value(tenantId),
      name: Value(clientName?.trim() ?? 'Unknown Owner'),
      phonePrimary: Value(clientPhonePrimary?.trim() ?? 'N/A'),
      phoneSecondary: Value(clientPhoneSecondary?.trim()),
      physicalAddress: Value(clientAddress?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pending_create'),
    );

    final patientId = _uuid.v7();
    final patientCompanion = PatientsTableCompanion(
      id: Value(patientId),
      tenantId: Value(tenantId),
      clientId: Value(clientId),
      nameOrTag: Value(nameOrTag.trim()),
      species: Value(species.trim()),
      breed: Value(breed?.trim()),
      gender: Value(gender),
      age: Value(age),
      dateOfBirth: Value(dateOfBirth),
      isApproximateAge: Value(isApproximateAge),
      microchipNumber: Value(microchipNumber?.trim()),
      earTagId: Value(earTagId?.trim()),
      coatColorMarkings: Value(coatColorMarkings?.trim()),
      currentWeightKg: Value(currentWeightKg),
      weightRecordedAt: Value(currentWeightKg != null ? now : null),
      history: Value(history?.trim()),
      notes: Value(notes?.trim()),
      allergies: Value(allergies.isNotEmpty ? jsonEncode(allergies) : null),
      status: const Value('active'),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pending_create'),
    );

    final result = await _dao.registerClientAndPatient(
      tenantId: tenantId,
      clientCompanion: clientCompanion,
      patientCompanion: patientCompanion,
      enqueueSync: true,
    );

    return _mapPatientWithClientToEntity(result);
  }

  @override
  Future<List<ClientSummaryEntity>> searchClients(String query) async {
    final tenantId = await _storageService.getTenantId() ?? 'default';
    final clients = await _dao.searchClients(tenantId: tenantId, query: query);
    return clients.map(_mapClientDataToSummary).toList();
  }

  PatientEntity _mapPatientWithClientToEntity(PatientWithClient bundle) {
    return PatientEntity(
      id: bundle.patient.id,
      tenantId: bundle.patient.tenantId,
      clientId: bundle.patient.clientId,
      nameOrTag: bundle.patient.nameOrTag,
      species: bundle.patient.species,
      breed: bundle.patient.breed,
      gender: bundle.patient.gender,
      age: bundle.patient.age,
      dateOfBirth: bundle.patient.dateOfBirth,
      isApproximateAge: bundle.patient.isApproximateAge,
      microchipNumber: bundle.patient.microchipNumber,
      earTagId: bundle.patient.earTagId,
      coatColorMarkings: bundle.patient.coatColorMarkings,
      currentWeightKg: bundle.patient.currentWeightKg,
      weightRecordedAt: bundle.patient.weightRecordedAt,
      history: bundle.patient.history,
      notes: bundle.patient.notes,
      status: bundle.patient.status,
      allergies: _parseAllergies(bundle.patient.allergies),
      createdAt: bundle.patient.createdAt,
      updatedAt: bundle.patient.updatedAt,
      syncStatus: bundle.patient.syncStatus,
      client: _mapClientDataToSummary(bundle.client),
    );
  }

  ClientSummaryEntity _mapClientDataToSummary(ClientData client) {
    return ClientSummaryEntity(
      id: client.id,
      tenantId: client.tenantId,
      clientType: client.clientType,
      name: client.name,
      contactPerson: client.contactPerson,
      phonePrimary: client.phonePrimary,
      phoneSecondary: client.phoneSecondary,
      physicalAddress: client.physicalAddress,
      notes: client.notes,
    );
  }

  List<String> _parseAllergies(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }
}
