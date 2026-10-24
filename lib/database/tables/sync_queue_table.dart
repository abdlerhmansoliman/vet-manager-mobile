import 'package:drift/drift.dart';

/// Drift SQLite Table storing FIFO Offline Mutation Queue.
///
/// Ensures deterministic outbox ordering and atomic replay against
/// the backend multi-tenant sync API with UUIDv7 Idempotency-Keys.
@DataClassName('SyncQueueData')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Domain entity type: client, patient, case, progress_note, diagnosis
  TextColumn get entityType => text().withLength(min: 1, max: 64)();

  /// Entity UUID
  TextColumn get entityId => text()();

  /// Mutation verb: create, update, delete
  TextColumn get action => text().withLength(min: 1, max: 16)();

  /// Full JSON snapshot payload sent to backend sync endpoint
  TextColumn get payload => text()();

  /// Offline client local timestamp of mutation
  DateTimeColumn get clientTimestamp => dateTime()();

  /// Unique UUIDv7 idempotency key preventing duplicate server execution
  TextColumn get idempotencyKey => text().withLength(min: 16, max: 64)();

  /// Queue status: pending, in_flight, failed, synced
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Cumulative transmission attempts
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Detailed error string or HTTP response upon sync failure
  TextColumn get lastError => text().nullable()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
