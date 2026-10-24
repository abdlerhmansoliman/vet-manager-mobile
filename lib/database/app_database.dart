import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/clients_table.dart';
import 'tables/patients_table.dart';
import 'tables/clinical_cases_table.dart';
import 'tables/clinical_progress_notes_table.dart';
import 'tables/diagnoses_table.dart';
import 'tables/media_upload_queue_table.dart';
import 'tables/sync_queue_table.dart';
import 'daos/clinical_case_dao.dart';

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
    ClinicalProgressNotesTable,
    DiagnosesTable,
    MediaUploadQueueTable,
    SyncQueueTable,
  ],
  daos: [
    ClinicalCaseDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  AppDatabase.forTesting(QueryExecutor e) : super(e);

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
