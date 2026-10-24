// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_case_dao.dart';

// ignore_for_file: type=lint
mixin _$ClinicalCaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClientsTableTable get clientsTable => attachedDatabase.clientsTable;
  $PatientsTableTable get patientsTable => attachedDatabase.patientsTable;
  $ClinicalCasesTableTable get clinicalCasesTable =>
      attachedDatabase.clinicalCasesTable;
  $ClinicalProgressNotesTableTable get clinicalProgressNotesTable =>
      attachedDatabase.clinicalProgressNotesTable;
  $DiagnosesTableTable get diagnosesTable => attachedDatabase.diagnosesTable;
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  ClinicalCaseDaoManager get managers => ClinicalCaseDaoManager(this);
}

class ClinicalCaseDaoManager {
  final _$ClinicalCaseDaoMixin _db;
  ClinicalCaseDaoManager(this._db);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db.attachedDatabase, _db.clientsTable);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db.attachedDatabase, _db.patientsTable);
  $$ClinicalCasesTableTableTableManager get clinicalCasesTable =>
      $$ClinicalCasesTableTableTableManager(
          _db.attachedDatabase, _db.clinicalCasesTable);
  $$ClinicalProgressNotesTableTableTableManager
      get clinicalProgressNotesTable =>
          $$ClinicalProgressNotesTableTableTableManager(
              _db.attachedDatabase, _db.clinicalProgressNotesTable);
  $$DiagnosesTableTableTableManager get diagnosesTable =>
      $$DiagnosesTableTableTableManager(
          _db.attachedDatabase, _db.diagnosesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
          _db.attachedDatabase, _db.syncQueueTable);
}
