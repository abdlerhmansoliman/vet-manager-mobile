import 'package:drift/drift.dart';
import 'clinical_cases_table.dart';
import 'patients_table.dart';

/// Drift SQLite Table for Patient Medical Diagnoses (SNOMED-CT / VeNom / ICD compatible).
@DataClassName('DiagnosisData')
class DiagnosesTable extends Table {
  @override
  String get tableName => 'diagnoses';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Foreign key linking diagnosis to animal patient
  TextColumn get patientId => text().references(PatientsTable, #id)();

  /// Clinician who established diagnosis
  TextColumn get userId => text()();

  /// Optional foreign key linking diagnosis to an encounter
  TextColumn get caseId => text().nullable().references(ClinicalCasesTable, #id)();

  /// Primary diagnostic term (e.g. "Canine Parvoviral Enteritis", "Feline Lower Urinary Tract Disease")
  TextColumn get diagnosis => text().withLength(min: 1, max: 255)();

  /// Pathological details, staging, or etiology
  TextColumn get description => text().nullable()();

  /// Diagnostic status: active, resolved, rule_out, chronic
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Clinician notes regarding response to treatment
  TextColumn get notes => text().nullable()();

  /// Timestamp when diagnosis was confirmed
  DateTimeColumn get diagnosedAt => dateTime()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Modification timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
