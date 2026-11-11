import 'package:drift/drift.dart';
import 'clinical_cases_table.dart';
import 'visits_table.dart';

/// Drift SQLite Table for Medication Doses administered during a Clinical Visit.
@DataClassName('DoseAdministrationData')
class DoseAdministrationsTable extends Table {
  @override
  String get tableName => 'dose_administrations';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Scoped encounter/visit identifier
  TextColumn get visitId => text().references(VisitsTable, #id)();

  /// Parent clinical case identifier
  TextColumn get caseId => text().references(ClinicalCasesTable, #id)();

  /// Patient identifier
  TextColumn get patientId => text()();

  /// Name of the administered drug/medication
  TextColumn get medicineName => text().withLength(min: 1, max: 255)();

  /// Administered dosage quantity (e.g. "1.5", "250")
  TextColumn get doseQuantity => text()();

  /// Measurement unit (e.g. "ml", "mg", "tablets")
  TextColumn get unit => text()();

  /// Administration route (e.g. "SQ (Subcutaneous)", "IV (Intravenous)", "PO (Oral)")
  TextColumn get route => text()();

  /// Optional clinical administration notes
  TextColumn get clinicalNotes => text().nullable()();

  /// Administering clinician identifier
  TextColumn get veterinarianId => text()();

  /// Administering clinician display name
  TextColumn get veterinarianName => text()();

  /// Exact timestamp when dose was given
  DateTimeColumn get administeredAt => dateTime()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
