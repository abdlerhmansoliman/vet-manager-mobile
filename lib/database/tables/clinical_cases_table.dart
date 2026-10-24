import 'package:drift/drift.dart';
import 'patients_table.dart';

/// Drift SQLite Table for Clinical Veterinary Cases & Encounters.
@DataClassName('ClinicalCaseData')
class ClinicalCasesTable extends Table {
  @override
  String get tableName => 'cases';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Human-readable encounter code (e.g., CAS-2026-0042)
  TextColumn get caseNumber => text().withLength(min: 3, max: 32)();

  /// Foreign key linking encounter to animal patient
  TextColumn get patientId => text().references(PatientsTable, #id)();

  /// Assigned veterinarian identifier
  TextColumn get primaryVeterinarianId => text()();

  /// Cached veterinarian display name for immediate offline rendering
  TextColumn get primaryVeterinarianName => text().nullable()();

  /// Encounter workflow type: outpatient, inpatient, emergency, surgery, herd_check, telemedicine
  TextColumn get caseType => text().withDefault(const Constant('outpatient'))();

  /// Clinical lifecycle status: open, in_progress, under_observation, awaiting_lab, pending_discharge, closed
  TextColumn get status => text().withDefault(const Constant('open'))();

  /// Triage severity level: routine, urgent, critical
  TextColumn get priority => text().withDefault(const Constant('routine'))();

  /// Chief complaint presented by owner upon arrival
  TextColumn get chiefComplaint => text().withLength(min: 1, max: 255)();

  /// Working diagnostic hypothesis
  TextColumn get provisionalDiagnosis => text().nullable()();

  /// Confirmed post-investigation diagnosis
  TextColumn get finalDiagnosis => text().nullable()();

  /// Admission date & time
  DateTimeColumn get admittedAt => dateTime()();

  /// Discharge date & time (null if still admitted)
  DateTimeColumn get dischargedAt => dateTime().nullable()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Modification timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft deletion timestamp
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Last server sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
