import 'package:drift/drift.dart';
import '../converters/decimal_converter.dart';
import 'inventory_products_table.dart';
import 'inventory_batches_table.dart';
import 'inventory_containers_table.dart';
import 'clinical_cases_table.dart';
import 'patients_table.dart';

/// Drift SQLite Table for Immutable Pharmacy Movement & Controlled Substance Ledger.
///
/// Strictly append-only audit trail conforming to DEA and regulatory veterinary standards.
/// Historical records are NEVER updated or deleted in place. Voids are recorded as new reversal rows.
@DataClassName('InventoryMovementLedgerData')
class InventoryMovementLedgerTable extends Table {
  @override
  String get tableName => 'inventory_movement_ledger';

  /// Primary UUID v7 identifier
  TextColumn get id => text()();

  /// Multi-tenant clinical practice isolation key
  TextColumn get tenantId => text()();

  /// Foreign key referencing affected product catalog item
  TextColumn get productId => text().references(InventoryProductsTable, #id)();

  /// Foreign key referencing affected batch/lot (nullable for global adjustments)
  TextColumn get batchId => text().nullable().references(InventoryBatchesTable, #id)();

  /// Foreign key referencing physical container/vial (nullable if not containerized)
  TextColumn get containerId => text().nullable().references(InventoryContainersTable, #id)();

  /// Immutable transaction classification: received, consumed, wasted, reversal_void, adjustment, expired_writeoff
  TextColumn get movementType => text()();

  /// Quantity moved, administered, or wasted (strictly positive Decimal)
  TextColumn get quantity => text().map(const DecimalConverter())();

  /// Balance remaining in container or batch immediately following this transaction
  TextColumn get balanceAfter => text().map(const DecimalConverter())();

  /// Client-side UUID v7 idempotency token to prevent duplicate sync commits
  TextColumn get idempotencyKey => text().withLength(min: 36, max: 36)();

  /// Identifier of practitioner who administered or recorded the transaction
  TextColumn get recordedByUserId => text()();

  /// Identifier of secondary practitioner who co-signed/witnessed (required for Schedule II-V)
  TextColumn get witnessedByUserId => text().nullable()();

  /// Indicates whether the witness 4-digit PIN verification succeeded
  BoolColumn get witnessPinVerified => boolean().withDefault(const Constant(false))();

  /// Optional clinical encounter associated with this dose administration
  TextColumn get clinicalCaseId => text().nullable().references(ClinicalCasesTable, #id)();

  /// Optional animal patient that received the medication
  TextColumn get patientId => text().nullable().references(PatientsTable, #id)();

  /// Transaction narrative, dosage justification, or void reason
  TextColumn get notes => text().nullable()();

  /// Timestamp when event occurred (immutable append-only; no updatedAt or deletedAt)
  DateTimeColumn get createdAt => dateTime()();

  /// Offline synchronization lifecycle: synced, pending_push
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Last server sync timestamp
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
