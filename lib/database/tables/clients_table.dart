import 'package:drift/drift.dart';

/// Drift SQLite Table for Client / Animal Owner records.
///
/// Mirrors the multi-tenant backend schema with soft-deletion
/// and offline sync lifecycle metadata.
@DataClassName('ClientData')
class ClientsTable extends Table {
  @override
  String get tableName => 'clients';

  /// Primary UUIDv4 / UUIDv7 identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Client classification: individual, commercial_farm, rescue_center, breeder
  TextColumn get clientType => text().withDefault(const Constant('individual'))();

  /// Full client name or organization title
  TextColumn get name => text().withLength(min: 1, max: 191)();

  /// Primary representative or emergency contact name
  TextColumn get contactPerson => text().nullable().withLength(max: 191)();

  /// Primary communication telephone number
  TextColumn get phonePrimary => text().withLength(min: 3, max: 32)();

  /// Secondary telephone number
  TextColumn get phoneSecondary => text().nullable().withLength(max: 32)();

  /// Street address or geolocation notes
  TextColumn get physicalAddress => text().nullable()();

  /// General client billing notes or preferences
  TextColumn get notes => text().nullable()();

  /// Timestamp of creation
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp of latest modification
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft delete timestamp (null if active)
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Offline synchronization status: 'synced', 'pending_create', 'pending_update', 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Timestamp of last successful server round-trip
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
