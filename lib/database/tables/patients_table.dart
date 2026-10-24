import 'package:drift/drift.dart';
import 'clients_table.dart';

/// Drift SQLite Table for Veterinary Patients (Companion & Large Animals).
@DataClassName('PatientData')
class PatientsTable extends Table {
  @override
  String get tableName => 'patients';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Foreign key linking patient to owner
  TextColumn get clientId => text().references(ClientsTable, #id)();

  /// Pet name or livestock visual ear tag
  TextColumn get nameOrTag => text().withLength(min: 1, max: 100)();

  /// Biological species: Canine, Feline, Equine, Bovine, Ovine, Caprine, Avian, Reptile, Other
  TextColumn get species => text().withLength(min: 1, max: 64)();

  /// Specific breed or mixed heritage
  TextColumn get breed => text().nullable().withLength(max: 100)();

  /// Gender & reproductive status: male_intact, male_neutered, female_intact, female_spayed, unknown
  TextColumn get gender => text().withDefault(const Constant('unknown'))();

  /// Approximate or calculated age in whole years
  IntColumn get age => integer().nullable()();

  /// Verified date of birth if known
  DateTimeColumn get dateOfBirth => dateTime().nullable()();

  /// Indicates if age was estimated during triage
  BoolColumn get isApproximateAge => boolean().withDefault(const Constant(false))();

  /// ISO 11784/11785 15-digit RFID microchip implant identifier
  TextColumn get microchipNumber => text().nullable().withLength(max: 32)();

  /// Official livestock visual identification tag
  TextColumn get earTagId => text().nullable().withLength(max: 64)();

  /// Coat coloration, patterns, and distinctive scars
  TextColumn get coatColorMarkings => text().nullable().withLength(max: 191)();

  /// Current body weight in kilograms (accurate to 3 decimals)
  RealColumn get currentWeightKg => real().nullable()();

  /// Timestamp when current weight was recorded
  DateTimeColumn get weightRecordedAt => dateTime().nullable()();

  /// Chronic medical conditions, vaccination background
  TextColumn get history => text().nullable()();

  /// Behavioral cautions (e.g. muzzle required, fractious feline)
  TextColumn get notes => text().nullable()();

  /// Patient status: active, deceased, archived, transferred
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Date/time of passing if deceased
  DateTimeColumn get deceasedAt => dateTime().nullable()();

  /// Known drug or dietary allergies stored as serialized JSON array
  TextColumn get allergies => text().nullable()();

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
