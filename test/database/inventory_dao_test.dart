import 'dart:ffi';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/database/daos/inventory_dao.dart';

void main() {
  late AppDatabase db;
  late InventoryDao dao;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.inventoryDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('Inventory Database Schema & Foreign Key Constraints', () {
    test('enforces foreign key constraints when inserting batch with invalid productId', () async {
      expect(
        () async {
          await db.into(db.inventoryBatchesTable).insert(
                InventoryBatchesTableCompanion.insert(
                  id: 'batch-001',
                  tenantId: 'tenant-1',
                  productId: 'nonexistent-product-id',
                  lotNumber: 'LOT-999',
                  expiresAt: DateTime(2027, 1, 1),
                  initialBaseQty: Decimal.parse('100.0'),
                  remainingBaseQty: Decimal.parse('100.0'),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('enforces foreign key constraints when inserting container with invalid batchId', () async {
      final now = DateTime.now();
      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: 'prod-001',
              tenantId: 'tenant-1',
              sku: 'SKU-001',
              name: 'Ketamine 100mg/ml',
              createdAt: now,
              updatedAt: now,
            ),
          );

      expect(
        () async {
          await db.into(db.inventoryContainersTable).insert(
                InventoryContainersTableCompanion.insert(
                  id: 'vial-001',
                  tenantId: 'tenant-1',
                  productId: 'prod-001',
                  batchId: 'nonexistent-batch-id',
                  barcode: 'BAR-001',
                  initialVolume: Decimal.parse('50.0'),
                  remainingBalance: Decimal.parse('50.0'),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('FEFO (First-Expired, First-Out) Lot Tracking', () {
    test('getActiveBatchesFEFO orders batches by earliest expiry date', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-propofol';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'PRO-100',
              name: 'Propofol 10mg/ml',
              baseUnit: const Value('ml'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert Batch 1: Expires in 12 months (2027-10-24)
      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-late',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-2027',
              expiresAt: DateTime(2027, 10, 24),
              initialBaseQty: Decimal.parse('100.0'),
              remainingBaseQty: Decimal.parse('100.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert Batch 2: Expires in 2 months (2026-12-24) -> Should be FIRST in FEFO
      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-early',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-2026-EARLY',
              expiresAt: DateTime(2026, 12, 24),
              initialBaseQty: Decimal.parse('100.0'),
              remainingBaseQty: Decimal.parse('100.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert Batch 3: Expires in 6 months (2027-04-24)
      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-mid',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-2027-MID',
              expiresAt: DateTime(2027, 4, 24),
              initialBaseQty: Decimal.parse('100.0'),
              remainingBaseQty: Decimal.parse('100.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final batches = await dao.getActiveBatchesFEFO(productId);

      expect(batches.length, 3);
      expect(batches[0].id, 'batch-early'); // Earliest expiry first
      expect(batches[1].id, 'batch-mid');
      expect(batches[2].id, 'batch-late');
    });
  });

  group('Physical Container & Open Vial Priority', () {
    test('getAvailableContainersForProduct prioritizes OPEN vials before SEALED vials, regardless of creation order', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-diazepam';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'DIA-10',
              name: 'Diazepam 5mg/ml',
              baseUnit: const Value('ml'),
              isControlled: const Value(true),
              controlledSchedule: const Value('schedule_iv'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Batch A: Expires sooner (2027-01-01), but its vial is SEALED
      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-A',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-A-2027',
              expiresAt: DateTime(2027, 1, 1),
              initialBaseQty: Decimal.parse('50.0'),
              remainingBaseQty: Decimal.parse('50.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: 'vial-sealed-A',
              tenantId: 'tenant-1',
              productId: productId,
              batchId: 'batch-A',
              barcode: 'BAR-A-SEALED',
              initialVolume: Decimal.parse('50.0'),
              remainingBalance: Decimal.parse('50.0'),
              status: const Value('sealed'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Batch B: Expires later (2027-06-01), but its vial is already OPEN
      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-B',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-B-2027',
              expiresAt: DateTime(2027, 6, 1),
              initialBaseQty: Decimal.parse('50.0'),
              remainingBaseQty: Decimal.parse('35.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: 'vial-open-B',
              tenantId: 'tenant-1',
              productId: productId,
              batchId: 'batch-B',
              barcode: 'BAR-B-OPEN',
              initialVolume: Decimal.parse('50.0'),
              remainingBalance: Decimal.parse('35.0'),
              status: const Value('open'),
              openedAt: Value(now),
              openedByUserId: const Value('vet-dr-smith'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final available = await dao.getAvailableContainersForProduct(productId);

      expect(available.length, 2);
      // Critical clinical rule: Must pick the open vial first to prevent drug waste!
      expect(available[0].container.id, 'vial-open-B');
      expect(available[0].container.status, 'open');
      expect(available[1].container.id, 'vial-sealed-A');
      expect(available[1].container.status, 'sealed');
    });

    test('getAvailableContainersForProduct filters out depleted vials', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-buprenorphine';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'BUP-03',
              name: 'Buprenorphine 0.3mg/ml',
              baseUnit: const Value('ml'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: 'batch-bup',
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-BUP',
              expiresAt: DateTime(2027, 12, 31),
              initialBaseQty: Decimal.parse('10.0'),
              remainingBaseQty: Decimal.parse('0.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: 'vial-depleted',
              tenantId: 'tenant-1',
              productId: productId,
              batchId: 'batch-bup',
              barcode: 'BAR-DEPLETED',
              initialVolume: Decimal.parse('10.0'),
              remainingBalance: Decimal.parse('0.0'),
              status: const Value('depleted'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final available = await dao.getAvailableContainersForProduct(productId);
      expect(available, isEmpty);
    });
  });

  group('Atomic Dose Administration & Movement Ledger', () {
    test('administerDose updates container, batch, and product balances and records immutable ledger row', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-morphine';
      const batchId = 'batch-mor-1';
      const containerId = 'vial-mor-101';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'MOR-10',
              name: 'Morphine Sulfate 10mg/ml',
              baseUnit: const Value('ml'),
              isControlled: const Value(true),
              controlledSchedule: const Value('schedule_ii'),
              currentStockQty: Value(Decimal.parse('50.0')),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: batchId,
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-MOR-001',
              expiresAt: DateTime(2027, 12, 31),
              initialBaseQty: Decimal.parse('50.0'),
              remainingBaseQty: Decimal.parse('50.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: containerId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: batchId,
              barcode: 'BAR-MOR-101',
              initialVolume: Decimal.parse('50.0'),
              remainingBalance: Decimal.parse('50.0'),
              status: const Value('sealed'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Administer 1.5 ml dose
      final ledgerRow = await dao.administerDose(
        tenantId: 'tenant-1',
        productId: productId,
        containerId: containerId,
        doseQuantity: Decimal.parse('1.5'),
        recordedByUserId: 'vet-dr-house',
        witnessedByUserId: 'tech-cameron',
        witnessPinVerified: true,
        notes: 'Pre-anesthetic analgesia for feline fracture repair',
      );

      expect(ledgerRow.movementType, 'consumed');
      expect(ledgerRow.quantity, Decimal.parse('1.5'));
      expect(ledgerRow.balanceAfter, Decimal.parse('48.5'));
      expect(ledgerRow.witnessPinVerified, true);
      expect(ledgerRow.witnessedByUserId, 'tech-cameron');

      // Verify Container was marked OPEN and volume was deducted
      final updatedContainer = await dao.getContainerById(containerId);
      expect(updatedContainer!.status, 'open');
      expect(updatedContainer.remainingBalance, Decimal.parse('48.5'));
      expect(updatedContainer.openedByUserId, 'vet-dr-house');

      // Verify Batch was deducted
      final batches = await dao.getActiveBatchesFEFO(productId);
      expect(batches.first.remainingBaseQty, Decimal.parse('48.5'));

      // Verify Product currentStockQty was deducted
      final updatedProduct = await dao.getProductById(productId);
      expect(updatedProduct!.currentStockQty, Decimal.parse('48.5'));
    });

    test('administerDose marks container as DEPLETED when remaining volume reaches zero', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-acepromazine';
      const batchId = 'batch-ace-1';
      const containerId = 'vial-ace-1';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'ACE-10',
              name: 'Acepromazine 10mg/ml',
              currentStockQty: Value(Decimal.parse('5.0')),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: batchId,
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-ACE-01',
              expiresAt: DateTime(2027, 5, 1),
              initialBaseQty: Decimal.parse('5.0'),
              remainingBaseQty: Decimal.parse('5.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: containerId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: batchId,
              barcode: 'BAR-ACE-01',
              initialVolume: Decimal.parse('5.0'),
              remainingBalance: Decimal.parse('5.0'),
              status: const Value('open'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Administer all remaining 5.0 ml
      await dao.administerDose(
        tenantId: 'tenant-1',
        productId: productId,
        containerId: containerId,
        doseQuantity: Decimal.parse('5.0'),
        recordedByUserId: 'vet-1',
      );

      final container = await dao.getContainerById(containerId);
      expect(container!.remainingBalance, Decimal.zero);
      expect(container.status, 'depleted');

      // Attempting further administration should throw StateError
      expect(
        () => dao.administerDose(
          tenantId: 'tenant-1',
          productId: productId,
          containerId: containerId,
          doseQuantity: Decimal.parse('0.5'),
          recordedByUserId: 'vet-1',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('voidDoseTransaction performs append-only reversal without mutating the original ledger row', () async {
      final now = DateTime(2026, 10, 24);
      const productId = 'prod-midazolam';
      const batchId = 'batch-mid-1';
      const containerId = 'vial-mid-1';

      await db.into(db.inventoryProductsTable).insert(
            InventoryProductsTableCompanion.insert(
              id: productId,
              tenantId: 'tenant-1',
              sku: 'MID-5',
              name: 'Midazolam 5mg/ml',
              isControlled: const Value(true),
              controlledSchedule: const Value('schedule_iv'),
              currentStockQty: Value(Decimal.parse('20.0')),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryBatchesTable).insert(
            InventoryBatchesTableCompanion.insert(
              id: batchId,
              tenantId: 'tenant-1',
              productId: productId,
              lotNumber: 'LOT-MID',
              expiresAt: DateTime(2027, 8, 1),
              initialBaseQty: Decimal.parse('20.0'),
              remainingBaseQty: Decimal.parse('20.0'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.inventoryContainersTable).insert(
            InventoryContainersTableCompanion.insert(
              id: containerId,
              tenantId: 'tenant-1',
              productId: productId,
              batchId: batchId,
              barcode: 'BAR-MID-01',
              initialVolume: Decimal.parse('20.0'),
              remainingBalance: Decimal.parse('20.0'),
              status: const Value('open'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Step 1: Administer dose of 2.0 ml
      final originalLedger = await dao.administerDose(
        tenantId: 'tenant-1',
        productId: productId,
        containerId: containerId,
        doseQuantity: Decimal.parse('2.0'),
        recordedByUserId: 'vet-1',
        notes: 'Pre-med dose',
      );

      var container = await dao.getContainerById(containerId);
      expect(container!.remainingBalance, Decimal.parse('18.0'));

      // Step 2: Void the dose (e.g., patient procedure was canceled before injection)
      final voidRow = await dao.voidDoseTransaction(
        tenantId: 'tenant-1',
        originalLedgerId: originalLedger.id,
        voidedByUserId: 'vet-supervisor',
        voidReason: 'Surgery canceled; drug was not drawn',
        witnessUserId: 'tech-witness',
        witnessPinVerified: true,
      );

      expect(voidRow.movementType, 'reversal_void');
      expect(voidRow.quantity, Decimal.parse('2.0'));
      expect(voidRow.balanceAfter, Decimal.parse('20.0'));

      // Step 3: Verify the original ledger row was NOT mutated or deleted (strictly append-only!)
      final ledgerRows = await (db.select(db.inventoryMovementLedgerTable)
            ..orderBy([(l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.asc)]))
          .get();

      expect(ledgerRows.length, 2);
      expect(ledgerRows[0].id, originalLedger.id);
      expect(ledgerRows[0].movementType, 'consumed');
      expect(ledgerRows[0].quantity, Decimal.parse('2.0'));

      expect(ledgerRows[1].id, voidRow.id);
      expect(ledgerRows[1].movementType, 'reversal_void');
      expect(ledgerRows[1].quantity, Decimal.parse('2.0'));

      // Step 4: Verify balances are restored
      container = await dao.getContainerById(containerId);
      expect(container!.remainingBalance, Decimal.parse('20.0'));

      final batches = await dao.getActiveBatchesFEFO(productId);
      expect(batches.first.remainingBaseQty, Decimal.parse('20.0'));

      final product = await dao.getProductById(productId);
      expect(product!.currentStockQty, Decimal.parse('20.0'));
    });
  });
}
