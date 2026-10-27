import 'package:drift/drift.dart';
import '../converters/decimal_converter.dart';
import 'inventory_products_table.dart';

/// Drift SQLite Table for Medication Lots & Batches.
///
/// Tracks manufacturer lot numbers, purchase unit costs, remaining stock,
/// and expiration dates used for First-Expired, First-Out (FEFO) dispensing order.
@DataClassName('InventoryBatchData')
class InventoryBatchesTable extends Table {
  @override
  String get tableName => 'inventory_batches';

  /// Primary UUID v7 identifier
  TextColumn get id => text()();

  /// Multi-tenant clinical practice isolation key
  TextColumn get tenantId => text()();

  /// Foreign key linking batch to parent product catalog item
  TextColumn get productId => text().references(InventoryProductsTable, #id)();

  /// Manufacturer lot or batch code
  TextColumn get lotNumber => text().withLength(min: 1, max: 64)();

  /// Batch expiration date (fundamental for FEFO ordering)
  DateTimeColumn get expiresAt => dateTime()();

  /// Purchase unit cost per base unit (high precision)
  TextColumn get unitCost => text().map(const DecimalConverter()).withDefault(const Constant('0'))();

  /// Total initial base quantity received in this batch
  TextColumn get initialBaseQty => text().map(const DecimalConverter())();

  /// Remaining available base quantity remaining in this batch
  TextColumn get remainingBaseQty => text().map(const DecimalConverter())();

  /// Batch status: active, quarantined, recalled, expired, depleted
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Record creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Record modification timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft deletion timestamp
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Last server sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
