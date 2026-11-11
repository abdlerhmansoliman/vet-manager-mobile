import 'package:drift/drift.dart';
import 'clinical_cases_table.dart';

/// Drift SQLite Table for Clinical Visits & Encounters scoped to a Case.
@DataClassName('VisitData')
class VisitsTable extends Table {
  @override
  String get tableName => 'visits';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Foreign key linking visit to parent clinical case
  TextColumn get caseId => text().references(ClinicalCasesTable, #id)();

  /// Patient identifier
  TextColumn get patientId => text()();

  /// Assigned veterinarian identifier
  TextColumn get veterinarianId => text()();

  /// Cached veterinarian display name
  TextColumn get veterinarianName => text()();

  /// Title or purpose of the encounter (e.g. "Initial Consultation", "Follow-up Visit - Nov 11, 2026")
  TextColumn get title => text().withLength(min: 1, max: 255)();

  /// Encounter workflow type: consultation, follow_up, emergency, routine, surgery_recheck
  TextColumn get visitType => text().withDefault(const Constant('consultation'))();

  /// Clinical lifecycle status: open, signed, closed
  TextColumn get status => text().withDefault(const Constant('open'))();

  /// Whether the medical record for this encounter has been formally signed and locked
  BoolColumn get isSigned => boolean().withDefault(const Constant(false))();

  /// Timestamp when encounter was signed by clinician
  DateTimeColumn get signedAt => dateTime().nullable()();

  /// Name or title of signing clinician
  TextColumn get signedBy => text().nullable()();

  /// Date & time of the visit encounter
  DateTimeColumn get visitDate => dateTime()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Modification timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft deletion timestamp
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
