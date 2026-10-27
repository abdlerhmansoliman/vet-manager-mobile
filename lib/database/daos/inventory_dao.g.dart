// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $InventoryProductsTableTable get inventoryProductsTable =>
      attachedDatabase.inventoryProductsTable;
  $InventoryBatchesTableTable get inventoryBatchesTable =>
      attachedDatabase.inventoryBatchesTable;
  $InventoryContainersTableTable get inventoryContainersTable =>
      attachedDatabase.inventoryContainersTable;
  $ClientsTableTable get clientsTable => attachedDatabase.clientsTable;
  $PatientsTableTable get patientsTable => attachedDatabase.patientsTable;
  $ClinicalCasesTableTable get clinicalCasesTable =>
      attachedDatabase.clinicalCasesTable;
  $InventoryMovementLedgerTableTable get inventoryMovementLedgerTable =>
      attachedDatabase.inventoryMovementLedgerTable;
  InventoryDaoManager get managers => InventoryDaoManager(this);
}

class InventoryDaoManager {
  final _$InventoryDaoMixin _db;
  InventoryDaoManager(this._db);
  $$InventoryProductsTableTableTableManager get inventoryProductsTable =>
      $$InventoryProductsTableTableTableManager(
          _db.attachedDatabase, _db.inventoryProductsTable);
  $$InventoryBatchesTableTableTableManager get inventoryBatchesTable =>
      $$InventoryBatchesTableTableTableManager(
          _db.attachedDatabase, _db.inventoryBatchesTable);
  $$InventoryContainersTableTableTableManager get inventoryContainersTable =>
      $$InventoryContainersTableTableTableManager(
          _db.attachedDatabase, _db.inventoryContainersTable);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db.attachedDatabase, _db.clientsTable);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db.attachedDatabase, _db.patientsTable);
  $$ClinicalCasesTableTableTableManager get clinicalCasesTable =>
      $$ClinicalCasesTableTableTableManager(
          _db.attachedDatabase, _db.clinicalCasesTable);
  $$InventoryMovementLedgerTableTableTableManager
      get inventoryMovementLedgerTable =>
          $$InventoryMovementLedgerTableTableTableManager(
              _db.attachedDatabase, _db.inventoryMovementLedgerTable);
}
