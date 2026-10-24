import 'package:drift/drift.dart';
import 'clinical_cases_table.dart';

/// Drift SQLite Table for Veterinary SOAP Notes & Inpatient Progress Logs.
@DataClassName('ClinicalProgressNoteData')
class ClinicalProgressNotesTable extends Table {
  @override
  String get tableName => 'clinical_progress_notes';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Foreign key linking note to clinical encounter
  TextColumn get caseId => text().references(ClinicalCasesTable, #id)();

  /// Patient identifier
  TextColumn get patientId => text()();

  /// Authoring clinician or veterinary nurse identifier
  TextColumn get veterinarianId => text()();

  /// Clinician display name
  TextColumn get veterinarianName => text()();

  /// Note category: soap, nursing_log, discharge_summary, addendum
  TextColumn get noteType => text().withDefault(const Constant('soap'))();

  /// SOAP (S): Owner observations, demeanor, appetite, vomiting/diarrhea history
  TextColumn get subjective => text().nullable()();

  /// SOAP (O): Clinical examination findings, physical palpation
  TextColumn get objective => text().nullable()();

  /// SOAP (A): Clinical interpretation & differential diagnosis
  TextColumn get assessment => text().nullable()();

  /// SOAP (P): Treatment protocols, surgical plan, prescriptions
  TextColumn get plan => text().nullable()();

  /// Objective Vital: Rectal temperature in degrees Celsius (e.g. 38.5)
  RealColumn get temperatureCelsius => real().nullable()();

  /// Objective Vital: Heart rate in beats per minute
  IntColumn get heartRateBpm => integer().nullable()();

  /// Objective Vital: Respiratory rate in breaths per minute
  IntColumn get respiratoryRateBpm => integer().nullable()();

  /// Body Condition Score (1 to 9 Purina scale)
  IntColumn get bodyConditionScore => integer().nullable()();

  /// Colorado State University Acute Pain Scale (0 to 4)
  IntColumn get painScore => integer().nullable()();

  /// Timestamp when clinical examination was performed
  DateTimeColumn get recordedAt => dateTime()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Modification timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
