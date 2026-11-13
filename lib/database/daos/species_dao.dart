import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/species_table.dart';
import '../tables/sync_queue_table.dart';

part 'species_dao.g.dart';

/// Data Access Object for biological species taxonomy.
@DriftAccessor(tables: [
  SpeciesTable,
  SyncQueueTable,
])
class SpeciesDao extends DatabaseAccessor<AppDatabase> with _$SpeciesDaoMixin {
  final Uuid _uuid;

  SpeciesDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Watches all active non-deleted species for a given tenant.
  Stream<List<SpeciesData>> watchActiveSpecies({required String tenantId}) {
    final query = select(speciesTable)
      ..where((s) => s.tenantId.equals(tenantId) & s.deletedAt.isNull() & s.isActive.equals(true))
      ..orderBy([
        (s) => OrderingTerm(expression: s.isSystemDefault, mode: OrderingMode.desc),
        (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  /// Gets a one-time snapshot of active non-deleted species.
  Future<List<SpeciesData>> getActiveSpecies({required String tenantId}) {
    final query = select(speciesTable)
      ..where((s) => s.tenantId.equals(tenantId) & s.deletedAt.isNull() & s.isActive.equals(true))
      ..orderBy([
        (s) => OrderingTerm(expression: s.isSystemDefault, mode: OrderingMode.desc),
        (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  /// Creates a new custom species offline and enqueues an outbound sync mutation.
  /// If a species with the same code exists (even if soft-deleted), it restores/updates it.
  Future<SpeciesData> createCustomSpecies({
    required String tenantId,
    required String name,
    String? icon,
  }) async {
    final trimmedName = name.trim();
    final normalizedCode = trimmedName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final now = DateTime.now().toUtc();

    return transaction(() async {
      final existing = await (select(speciesTable)
            ..where((s) => s.tenantId.equals(tenantId) & s.code.equals(normalizedCode)))
          .getSingleOrNull();

      if (existing != null) {
        // If it was soft-deleted or inactive, reactivate it
        if (existing.deletedAt != null || !existing.isActive) {
          final updated = existing.copyWith(
            isActive: true,
            deletedAt: const Value(null),
            updatedAt: now,
            syncStatus: 'pending_update',
          );
          await update(speciesTable).replace(updated);

          // Enqueue update mutation
          await _enqueueSyncMutation(
            tenantId: tenantId,
            speciesId: existing.id,
            action: 'upsert',
            payload: {
              'id': existing.id,
              'name': existing.name,
              'code': existing.code,
              'icon': existing.icon,
              'is_system_default': existing.isSystemDefault,
              'is_active': true,
              'updated_at': now.toIso8601String(),
            },
            now: now,
          );
          return updated;
        }
        return existing;
      }

      final speciesId = _uuid.v7();
      final newSpecies = SpeciesData(
        id: speciesId,
        tenantId: tenantId,
        name: trimmedName,
        code: normalizedCode,
        icon: icon,
        isSystemDefault: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        syncStatus: 'pending_create',
        lastSyncedAt: null,
      );

      await into(speciesTable).insert(newSpecies);

      // Enqueue outbound sync mutation
      await _enqueueSyncMutation(
        tenantId: tenantId,
        speciesId: speciesId,
        action: 'upsert',
        payload: {
          'id': speciesId,
          'name': trimmedName,
          'code': normalizedCode,
          'icon': icon,
          'is_system_default': false,
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        now: now,
      );

      return newSpecies;
    });
  }

  /// Upserts incoming species records from server sync deltas.
  Future<void> upsertSyncedSpecies(List<SpeciesTableCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(speciesTable, items);
    });
  }

  /// Seeds default system species for a tenant if none exist.
  Future<void> seedDefaultSpeciesIfEmpty(String tenantId) async {
    final countQuery = selectOnly(speciesTable)..addColumns([speciesTable.id.count()]);
    countQuery.where(speciesTable.tenantId.equals(tenantId));
    final count = await countQuery.map((row) => row.read(speciesTable.id.count())).getSingle();

    if (count != null && count > 0) return;

    final now = DateTime.now().toUtc();
    final defaultSpecies = [
      ('Canine', 'canine', 'dog'),
      ('Feline', 'feline', 'cat'),
      ('Equine', 'equine', 'horse'),
      ('Bovine', 'bovine', 'cow'),
      ('Ovine', 'ovine', 'sheep'),
      ('Caprine', 'caprine', 'goat'),
      ('Avian', 'avian', 'bird'),
      ('Camel', 'camel', 'camel'),
      ('Other', 'other', 'other'),
    ];

    await batch((b) {
      for (final s in defaultSpecies) {
        b.insert(
          speciesTable,
          SpeciesTableCompanion.insert(
            id: _uuid.v7(),
            tenantId: tenantId,
            name: s.$1,
            code: s.$2,
            icon: Value(s.$3),
            isSystemDefault: const Value(true),
            isActive: const Value(true),
            createdAt: now,
            updatedAt: now,
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(now),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> _enqueueSyncMutation({
    required String tenantId,
    required String speciesId,
    required String action,
    required Map<String, dynamic> payload,
    required DateTime now,
  }) async {
    final mutationId = _uuid.v7();
    await into(syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        id: mutationId,
        tenantId: tenantId,
        entityType: 'species',
        entityId: speciesId,
        action: action,
        payload: jsonEncode(payload),
        clientTimestamp: now,
        idempotencyKey: _uuid.v7(),
        createdAt: now,
        status: const Value('pending'),
        attempts: const Value(0),
      ),
    );
  }
}
