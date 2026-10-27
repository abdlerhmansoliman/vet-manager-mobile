import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/inventory_products_table.dart';
import '../tables/inventory_batches_table.dart';
import '../tables/inventory_containers_table.dart';
import '../tables/inventory_movement_ledger_table.dart';

part 'inventory_dao.g.dart';

/// Aggregated Container bundle containing physical vial and manufacturer batch data.
class ContainerWithBatch {
  final InventoryContainerData container;
  final InventoryBatchData batch;

  const ContainerWithBatch({
    required this.container,
    required this.batch,
  });
}

/// Data Access Object for Pharmacy Catalog, Batches, Physical Containers, and Immutable Movement Ledger.
@DriftAccessor(tables: [
  InventoryProductsTable,
  InventoryBatchesTable,
  InventoryContainersTable,
  InventoryMovementLedgerTable,
])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ---------------------------------------------------------------------------
  // Product Catalog Queries
  // ---------------------------------------------------------------------------

  /// Streams active products for a tenant, ordered alphabetically by name.
  Stream<List<InventoryProductData>> watchProducts({required String tenantId}) {
    return (select(inventoryProductsTable)
          ..where((p) => p.tenantId.equals(tenantId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm(expression: p.name, mode: OrderingMode.asc)]))
        .watch();
  }

  /// Retrieves a product by its primary UUID.
  Future<InventoryProductData?> getProductById(String productId) {
    return (select(inventoryProductsTable)..where((p) => p.id.equals(productId))).getSingleOrNull();
  }

  /// Searches products by name or SKU.
  Future<List<InventoryProductData>> searchProducts({
    required String tenantId,
    required String query,
  }) {
    final term = '%$query%';
    return (select(inventoryProductsTable)
          ..where((p) =>
              p.tenantId.equals(tenantId) &
              p.deletedAt.isNull() &
              (p.name.like(term) | p.sku.like(term)))
          ..orderBy([(p) => OrderingTerm(expression: p.name, mode: OrderingMode.asc)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Batch & FEFO Queries
  // ---------------------------------------------------------------------------

  /// Streams active batches for a product ordered by First-Expired, First-Out (FEFO: expiresAt ASC).
  Stream<List<InventoryBatchData>> watchBatchesForProduct(String productId) {
    return (select(inventoryBatchesTable)
          ..where((b) => b.productId.equals(productId) & b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm(expression: b.expiresAt, mode: OrderingMode.asc)]))
        .watch();
  }

  /// Retrieves active, non-depleted batches ordered strictly by FEFO (earliest expiry first).
  Future<List<InventoryBatchData>> getActiveBatchesFEFO(String productId) {
    return (select(inventoryBatchesTable)
          ..where((b) =>
              b.productId.equals(productId) &
              b.deletedAt.isNull() &
              b.status.isNotIn(['expired', 'quarantined', 'recalled', 'depleted']))
          ..orderBy([(b) => OrderingTerm(expression: b.expiresAt, mode: OrderingMode.asc)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Physical Container Tracking & Open-Vial Priority
  // ---------------------------------------------------------------------------

  /// Streams all containers linked to a specific lot batch.
  Stream<List<InventoryContainerData>> watchContainersForBatch(String batchId) {
    return (select(inventoryContainersTable)
          ..where((c) => c.batchId.equals(batchId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.barcode, mode: OrderingMode.asc)]))
        .watch();
  }

  /// Retrieves a single container by its primary UUID.
  Future<InventoryContainerData?> getContainerById(String containerId) {
    return (select(inventoryContainersTable)..where((c) => c.id.equals(containerId))).getSingleOrNull();
  }

  /// Retrieves available containers for a product, prioritizing open vials first,
  /// then sealed vials ordered by batch expiration (FEFO).
  ///
  /// Priority Order:
  /// 1. Open vials (`status = 'open'`)
  /// 2. Sealed vials (`status = 'sealed'`)
  /// 3. Earliest expiration date (`expiresAt ASC`)
  Future<List<ContainerWithBatch>> getAvailableContainersForProduct(String productId) async {
    final query = select(inventoryContainersTable).join([
      innerJoin(
        inventoryBatchesTable,
        inventoryBatchesTable.id.equalsExp(inventoryContainersTable.batchId),
      ),
    ])
      ..where(
        inventoryContainersTable.productId.equals(productId) &
        inventoryContainersTable.deletedAt.isNull() &
        inventoryContainersTable.status.isNotIn(['depleted']) &
        inventoryBatchesTable.deletedAt.isNull() &
        inventoryBatchesTable.status.isNotIn(['expired', 'quarantined', 'recalled', 'depleted']),
      )
      ..orderBy([
        // 1. Open vials first (1), then sealed vials (2)
        OrderingTerm(
          expression: const CustomExpression<int>(
            "CASE inventory_containers.status WHEN 'open' THEN 1 ELSE 2 END",
          ),
          mode: OrderingMode.asc,
        ),
        // 2. Earliest expiring batch first (FEFO)
        OrderingTerm(
          expression: inventoryBatchesTable.expiresAt,
          mode: OrderingMode.asc,
        ),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      return ContainerWithBatch(
        container: row.readTable(inventoryContainersTable),
        batch: row.readTable(inventoryBatchesTable),
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Movement Ledger Queries (Immutable Audit Trail)
  // ---------------------------------------------------------------------------

  /// Streams ledger history for a product in reverse chronological order.
  Stream<List<InventoryMovementLedgerData>> watchLedgerForProduct(String productId) {
    return (select(inventoryMovementLedgerTable)
          ..where((l) => l.productId.equals(productId))
          ..orderBy([(l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Streams ledger history for an encounter / clinical case.
  Stream<List<InventoryMovementLedgerData>> watchLedgerForCase(String caseId) {
    return (select(inventoryMovementLedgerTable)
          ..where((l) => l.clinicalCaseId.equals(caseId))
          ..orderBy([(l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Controlled Dosing & Void Transactions
  // ---------------------------------------------------------------------------

  /// Administers a fractional medication dose atomically.
  ///
  /// Executes:
  /// 1. Verifies container availability and remaining balance.
  /// 2. Deducts dose from container volume (marking as 'open' or 'depleted').
  /// 3. Deducts from parent batch remaining quantity.
  /// 4. Deducts from product catalog cached stock on hand.
  /// 5. Appends immutable entry to [InventoryMovementLedgerTable].
  Future<InventoryMovementLedgerData> administerDose({
    required String tenantId,
    required String productId,
    required String containerId,
    required Decimal doseQuantity,
    required String recordedByUserId,
    String? witnessedByUserId,
    bool witnessPinVerified = false,
    String? clinicalCaseId,
    String? patientId,
    String? notes,
    String? customIdempotencyKey,
  }) async {
    if (doseQuantity <= Decimal.zero) {
      throw ArgumentError('Dose quantity must be strictly positive');
    }

    return transaction(() async {
      final container = await (select(inventoryContainersTable)
            ..where((c) => c.id.equals(containerId) & c.tenantId.equals(tenantId)))
          .getSingleOrNull();

      if (container == null) {
        throw StateError('Container not found: $containerId');
      }
      if (container.status == 'depleted') {
        throw StateError('Cannot administer from depleted container: $containerId');
      }

      final newContainerBalance = container.remainingBalance - doseQuantity;
      if (newContainerBalance < Decimal.zero) {
        throw StateError(
          'Insufficient container balance: ${container.remainingBalance} < $doseQuantity',
        );
      }

      final batch = await (select(inventoryBatchesTable)
            ..where((b) => b.id.equals(container.batchId)))
          .getSingleOrNull();

      if (batch == null) {
        throw StateError('Batch not found: ${container.batchId}');
      }

      final now = DateTime.now().toUtc();
      final newContainerStatus = newContainerBalance == Decimal.zero ? 'depleted' : 'open';

      // 1. Update Container
      await (update(inventoryContainersTable)..where((c) => c.id.equals(containerId))).write(
        InventoryContainersTableCompanion(
          remainingBalance: Value(newContainerBalance),
          status: Value(newContainerStatus),
          openedAt: Value(container.openedAt ?? now),
          openedByUserId: Value(container.openedByUserId ?? recordedByUserId),
          updatedAt: Value(now),
          syncStatus: const Value('pending_update'),
        ),
      );

      // 2. Update Batch remaining quantity
      final newBatchBalance = batch.remainingBaseQty - doseQuantity;
      final newBatchStatus = newBatchBalance <= Decimal.zero ? 'depleted' : batch.status;
      await (update(inventoryBatchesTable)..where((b) => b.id.equals(batch.id))).write(
        InventoryBatchesTableCompanion(
          remainingBaseQty: Value(newBatchBalance < Decimal.zero ? Decimal.zero : newBatchBalance),
          status: Value(newBatchStatus),
          updatedAt: Value(now),
          syncStatus: const Value('pending_update'),
        ),
      );

      // 3. Update Product stock quantity
      final product = await (select(inventoryProductsTable)
            ..where((p) => p.id.equals(productId)))
          .getSingleOrNull();
      if (product != null) {
        final newProductStock = product.currentStockQty - doseQuantity;
        await (update(inventoryProductsTable)..where((p) => p.id.equals(productId))).write(
          InventoryProductsTableCompanion(
            currentStockQty: Value(newProductStock < Decimal.zero ? Decimal.zero : newProductStock),
            updatedAt: Value(now),
            syncStatus: const Value('pending_update'),
          ),
        );
      }

      // 4. Insert strictly immutable Movement Ledger entry
      final ledgerId = const Uuid().v7();
      final idempotency = customIdempotencyKey ?? const Uuid().v7();
      final ledgerEntry = InventoryMovementLedgerData(
        id: ledgerId,
        tenantId: tenantId,
        productId: productId,
        batchId: batch.id,
        containerId: containerId,
        movementType: 'consumed',
        quantity: doseQuantity,
        balanceAfter: newContainerBalance,
        idempotencyKey: idempotency,
        recordedByUserId: recordedByUserId,
        witnessedByUserId: witnessedByUserId,
        witnessPinVerified: witnessPinVerified,
        clinicalCaseId: clinicalCaseId,
        patientId: patientId,
        notes: notes,
        createdAt: now,
        syncStatus: 'pending_push',
        lastSyncedAt: null,
      );

      await into(inventoryMovementLedgerTable).insert(ledgerEntry);

      return ledgerEntry;
    });
  }

  /// Voids / reverses a previously administered dose in an immutable append-only manner.
  ///
  /// In accordance with clinical DEA/veterinary regulations:
  /// - The original ledger row is NEVER modified or deleted.
  /// - A new reversal ledger entry (`movementType = 'reversal_void'`) is appended.
  /// - Restores balance to the physical container, batch, and product catalog.
  Future<InventoryMovementLedgerData> voidDoseTransaction({
    required String tenantId,
    required String originalLedgerId,
    required String voidedByUserId,
    required String voidReason,
    String? witnessUserId,
    bool witnessPinVerified = false,
  }) async {
    return transaction(() async {
      final originalLedger = await (select(inventoryMovementLedgerTable)
            ..where((l) => l.id.equals(originalLedgerId) & l.tenantId.equals(tenantId)))
          .getSingleOrNull();

      if (originalLedger == null) {
        throw StateError('Original ledger entry not found: $originalLedgerId');
      }
      if (originalLedger.movementType != 'consumed') {
        throw StateError('Cannot void non-consumption ledger entry: ${originalLedger.movementType}');
      }

      final now = DateTime.now().toUtc();
      final restoredQty = originalLedger.quantity;

      // 1. Restore container balance
      Decimal newContainerBalance = Decimal.zero;
      if (originalLedger.containerId != null) {
        final container = await (select(inventoryContainersTable)
              ..where((c) => c.id.equals(originalLedger.containerId!)))
            .getSingleOrNull();
        if (container != null) {
          newContainerBalance = container.remainingBalance + restoredQty;
          await (update(inventoryContainersTable)..where((c) => c.id.equals(container.id))).write(
            InventoryContainersTableCompanion(
              remainingBalance: Value(newContainerBalance),
              status: const Value('open'),
              updatedAt: Value(now),
              syncStatus: const Value('pending_update'),
            ),
          );
        }
      }

      // 2. Restore batch balance
      if (originalLedger.batchId != null) {
        final batch = await (select(inventoryBatchesTable)
              ..where((b) => b.id.equals(originalLedger.batchId!)))
            .getSingleOrNull();
        if (batch != null) {
          final newBatchBalance = batch.remainingBaseQty + restoredQty;
          await (update(inventoryBatchesTable)..where((b) => b.id.equals(batch.id))).write(
            InventoryBatchesTableCompanion(
              remainingBaseQty: Value(newBatchBalance),
              status: const Value('active'),
              updatedAt: Value(now),
              syncStatus: const Value('pending_update'),
            ),
          );
        }
      }

      // 3. Restore product stock
      final product = await (select(inventoryProductsTable)
            ..where((p) => p.id.equals(originalLedger.productId)))
          .getSingleOrNull();
      if (product != null) {
        final newProductStock = product.currentStockQty + restoredQty;
        await (update(inventoryProductsTable)..where((p) => p.id.equals(product.id))).write(
          InventoryProductsTableCompanion(
            currentStockQty: Value(newProductStock),
            updatedAt: Value(now),
            syncStatus: const Value('pending_update'),
          ),
        );
      }

      // 4. Append immutable reversal ledger record
      final reversalId = const Uuid().v7();
      final reversalEntry = InventoryMovementLedgerData(
        id: reversalId,
        tenantId: tenantId,
        productId: originalLedger.productId,
        batchId: originalLedger.batchId,
        containerId: originalLedger.containerId,
        movementType: 'reversal_void',
        quantity: restoredQty,
        balanceAfter: newContainerBalance,
        idempotencyKey: const Uuid().v7(),
        recordedByUserId: voidedByUserId,
        witnessedByUserId: witnessUserId,
        witnessPinVerified: witnessPinVerified,
        clinicalCaseId: originalLedger.clinicalCaseId,
        patientId: originalLedger.patientId,
        notes: 'VOID of $originalLedgerId: $voidReason',
        createdAt: now,
        syncStatus: 'pending_push',
        lastSyncedAt: null,
      );

      await into(inventoryMovementLedgerTable).insert(reversalEntry);

      return reversalEntry;
    });
  }
}
