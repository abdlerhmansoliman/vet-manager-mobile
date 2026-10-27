import 'package:drift/drift.dart';
import '../converters/decimal_converter.dart';
import 'inventory_products_table.dart';
import 'inventory_batches_table.dart';

/// Drift SQLite Table for Physical Containers, Vials, and Bottles.
///
/// Tracks individual serialized containers in the clinic or ambulatory vet truck,
/// enabling open-vial priority to minimize drug waste.
@DataClassName('InventoryContainerData')
class InventoryContainersTable extends Table {
  @override
  String get tableName => 'inventory_containers';

  /// Primary UUID v7 identifier
  TextColumn get id => text()();

  /// Multi-tenant clinical practice isolation key
  TextColumn get tenantId => text()();

  /// Foreign key linking physical container to its manufacturer batch
  TextColumn get batchId => text().references(InventoryBatchesTable, #id)();

  /// Foreign key linking physical container to product catalog item
  TextColumn get productId => text().references(InventoryProductsTable, #id)();

  /// Unique serialized barcode on the physical bottle/vial
  TextColumn get barcode => text().withLength(min: 1, max: 128)();

  /// Total physical capacity or initial volume of this container
  TextColumn get initialVolume => text().map(const DecimalConverter())();

  /// Current remaining volume or count inside this physical container
  TextColumn get remainingBalance => text().map(const DecimalConverter())();

  /// Physical containment state: sealed, open, depleted
  TextColumn get status => text().withDefault(const Constant('sealed'))();

  /// Timestamp when container seal was pierced / opened
  DateTimeColumn get openedAt => dateTime().nullable()();

  /// Attending veterinarian or technician who first unsealed the container
  TextColumn get openedByUserId => text().nullable()();

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
