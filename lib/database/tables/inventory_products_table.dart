import 'package:drift/drift.dart';
import '../converters/decimal_converter.dart';

/// Drift SQLite Table for Pharmacy Products Master Catalog.
///
/// Stores medication metadata, controlled substance classifications,
/// stock minimum thresholds, and base dispensing units.
@DataClassName('InventoryProductData')
class InventoryProductsTable extends Table {
  @override
  String get tableName => 'inventory_products';

  /// Primary UUID v7 identifier
  TextColumn get id => text()();

  /// Multi-tenant clinical practice isolation key
  TextColumn get tenantId => text()();

  /// Stock Keeping Unit or internal item barcode identifier
  TextColumn get sku => text().withLength(min: 1, max: 64)();

  /// Commercial trade name or generic pharmaceutical designation
  TextColumn get name => text().withLength(min: 1, max: 255)();

  /// Formulation details, active concentrations, or indications
  TextColumn get description => text().nullable()();

  /// Base measurement unit for inventory calculation: ml, mg, tablet, bolus, vial
  TextColumn get baseUnit => text().withDefault(const Constant('ml'))();

  /// Flag indicating whether the drug is subject to controlled substance protocols
  BoolColumn get isControlled => boolean().withDefault(const Constant(false))();

  /// DEA/National Controlled Substance Schedule (e.g., 'schedule_ii', 'schedule_iii', 'schedule_iv', 'schedule_v')
  TextColumn get controlledSchedule => text().nullable()();

  /// Safety restock threshold in base units
  TextColumn get minThreshold => text().map(const DecimalConverter()).withDefault(const Constant('0'))();

  /// Aggregated cached stock on hand in base units
  TextColumn get currentStockQty => text().map(const DecimalConverter()).withDefault(const Constant('0'))();

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
