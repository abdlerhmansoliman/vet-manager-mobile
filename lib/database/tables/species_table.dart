import 'package:drift/drift.dart';

/// Drift SQLite Table for Biological Species (Dynamic & Offline-First).
@DataClassName('SpeciesData')
class SpeciesTable extends Table {
  @override
  String get tableName => 'species';

  /// Primary UUID v7 identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Display name of the species (e.g. Canine, Feline, Falcon, Camel)
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Unique code / slug per tenant (e.g. canine, feline, falcon, camel)
  TextColumn get code => text().withLength(min: 1, max: 64)();

  /// Optional icon identifier or asset key
  TextColumn get icon => text().nullable().withLength(max: 64)();

  /// Indicates if this is a system-seeded default species
  BoolColumn get isSystemDefault => boolean().withDefault(const Constant(false))();

  /// Active status flag
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Modification timestamp
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
