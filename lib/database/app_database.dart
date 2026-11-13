import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'converters/decimal_converter.dart';

import 'tables/clients_table.dart';
import 'tables/patients_table.dart';
import 'tables/clinical_cases_table.dart';
import 'tables/visits_table.dart';
import 'tables/clinical_progress_notes_table.dart';
import 'tables/dose_administrations_table.dart';
import 'tables/diagnoses_table.dart';
import 'tables/media_upload_queue_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/inventory_products_table.dart';
import 'tables/inventory_batches_table.dart';
import 'tables/inventory_containers_table.dart';
import 'tables/inventory_movement_ledger_table.dart';
import 'tables/species_table.dart';
import 'daos/client_patient_dao.dart';
import 'daos/clinical_case_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/species_dao.dart';

part 'app_database.g.dart';

/// Enterprise Offline-First Drift SQLite Database for VetManager.
///
/// Features:
/// - Strong foreign key enforcement via PRAGMA foreign_keys = ON
/// - Zero-leakage multi-tenant practice isolation
/// - Offline FIFO sync outbox queue
/// - In-memory test execution support
@DriftDatabase(
  tables: [
    ClientsTable,
    PatientsTable,
    ClinicalCasesTable,
    VisitsTable,
    ClinicalProgressNotesTable,
    DoseAdministrationsTable,
    DiagnosesTable,
    MediaUploadQueueTable,
    SyncQueueTable,
    InventoryProductsTable,
    InventoryBatchesTable,
    InventoryContainersTable,
    InventoryMovementLedgerTable,
    SpeciesTable,
  ],
  daos: [
    ClientPatientDao,
    ClinicalCaseDao,
    InventoryDao,
    SpeciesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('PRAGMA foreign_keys = ON;');
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        final m = createMigrator();
        for (final table in allTables) {
          try {
            await m.createTable(table);
          } catch (_) {
            // Table already exists in schema
          }
        }
        try {
          await customStatement('ALTER TABLE clinical_progress_notes ADD COLUMN visit_id TEXT REFERENCES visits(id);');
        } catch (_) {
          // Column already exists
        }
        try {
          await customStatement('ALTER TABLE media_upload_queue ADD COLUMN visit_id TEXT REFERENCES visits(id);');
        } catch (_) {
          // Column already exists
        }
      },
    );
  }
}

LazyDatabase _openConnection({String dbName = 'vetmanager_clinical.sqlite'}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));
    return NativeDatabase.createInBackground(file);
  });
}
