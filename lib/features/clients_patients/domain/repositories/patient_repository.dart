import '../entities/patient_entity.dart';
import '../entities/species_entity.dart';

/// Repository contract for Patients and Clients operations.
abstract class IPatientRepository {
  /// Watches the reactive list of active biological species for the current tenant.
  Stream<List<SpeciesEntity>> watchSpecies();

  /// Gets a snapshot list of active biological species for the current tenant.
  Future<List<SpeciesEntity>> getSpecies();

  /// Creates a new custom biological species offline and queues for sync.
  Future<SpeciesEntity> createCustomSpecies(String name, {String? icon});

  /// Watches the reactive list of patients joined with client information.
  Stream<List<PatientEntity>> watchPatients({
    String? query,
    String? speciesFilter,
  });

  /// Fetches a single patient profile by its UUID.
  Future<PatientEntity?> getPatientById(String patientId);

  /// Registers a new patient along with their owner (or attaches to existing owner).
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
    // Client details
    String? existingClientId,
    String? clientName,
    String? clientPhonePrimary,
    String? clientPhoneSecondary,
    String? clientAddress,
  });

  /// Searches existing active clients by name or phone.
  Future<List<ClientSummaryEntity>> searchClients(String query);

  /// Updates an existing patient's clinical and demographic details.
  Future<PatientEntity> updatePatient({
    required String patientId,
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
    String? status,
    // Optional client updates
    String? clientName,
    String? clientPhonePrimary,
    String? clientPhoneSecondary,
    String? clientAddress,
  });

  /// Soft-deletes a patient and records an offline sync deletion.
  Future<bool> deletePatient(String patientId);
}
