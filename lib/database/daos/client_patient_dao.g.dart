// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_patient_dao.dart';

// ignore_for_file: type=lint
mixin _$ClientPatientDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClientsTableTable get clientsTable => attachedDatabase.clientsTable;
  $PatientsTableTable get patientsTable => attachedDatabase.patientsTable;
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  ClientPatientDaoManager get managers => ClientPatientDaoManager(this);
}

class ClientPatientDaoManager {
  final _$ClientPatientDaoMixin _db;
  ClientPatientDaoManager(this._db);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db.attachedDatabase, _db.clientsTable);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db.attachedDatabase, _db.patientsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
          _db.attachedDatabase, _db.syncQueueTable);
}
