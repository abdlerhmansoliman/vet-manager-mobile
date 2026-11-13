import 'dart:ffi';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/database/daos/species_dao.dart';

void main() {
  late AppDatabase db;
  late SpeciesDao dao;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.speciesDao;
  });

  tearDown(() async {
    await db.close();
  });

  const tenantId = 'tenant-clinic-1';

  group('SpeciesDao — Biological Species Persistence & Offline Sync', () {
    test('seedDefaultSpeciesIfEmpty seeds standard default species for empty tenant', () async {
      await dao.seedDefaultSpeciesIfEmpty(tenantId);

      final species = await dao.getActiveSpecies(tenantId: tenantId);
      expect(species, isNotEmpty);
      expect(species.length, equals(9));

      final codes = species.map((s) => s.code).toList();
      expect(codes, containsAll(['canine', 'feline', 'equine', 'bovine', 'ovine', 'caprine', 'avian', 'camel', 'other']));

      for (final s in species) {
        expect(s.isSystemDefault, isTrue);
        expect(s.isActive, isTrue);
        expect(s.syncStatus, equals('synced'));
      }

      // Calling again is idempotent and does not create duplicate entries
      await dao.seedDefaultSpeciesIfEmpty(tenantId);
      final countAgain = await dao.getActiveSpecies(tenantId: tenantId);
      expect(countAgain.length, equals(9));
    });

    test('createCustomSpecies creates new species and enqueues sync mutation', () async {
      final falcon = await dao.createCustomSpecies(
        tenantId: tenantId,
        name: 'Falcon',
        icon: 'bird',
      );

      expect(falcon.name, equals('Falcon'));
      expect(falcon.code, equals('falcon'));
      expect(falcon.isSystemDefault, isFalse);
      expect(falcon.isActive, isTrue);
      expect(falcon.syncStatus, equals('pending_create'));

      // Verify species exists in database
      final speciesList = await dao.getActiveSpecies(tenantId: tenantId);
      expect(speciesList.any((s) => s.code == 'falcon'), isTrue);

      // Verify sync mutation outbox record
      final queued = await db.select(db.syncQueueTable).get();
      expect(queued.length, equals(1));
      expect(queued.first.entityType, equals('species'));
      expect(queued.first.entityId, equals(falcon.id));
      expect(queued.first.action, equals('upsert'));
      expect(queued.first.status, equals('pending'));
      expect(queued.first.payload, contains('falcon'));
    });

    test('createCustomSpecies reactivates soft-deleted or inactive species', () async {
      final created = await dao.createCustomSpecies(
        tenantId: tenantId,
        name: 'Arabian Oryx',
      );

      // Soft delete it
      await (db.update(db.speciesTable)..where((s) => s.id.equals(created.id))).write(
        SpeciesTableCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          isActive: const Value(false),
        ),
      );

      var active = await dao.getActiveSpecies(tenantId: tenantId);
      expect(active.any((s) => s.id == created.id), isFalse);

      // Call create again with same name
      final reactivated = await dao.createCustomSpecies(
        tenantId: tenantId,
        name: 'Arabian Oryx',
      );

      expect(reactivated.id, equals(created.id));
      expect(reactivated.isActive, isTrue);
      expect(reactivated.deletedAt, isNull);

      active = await dao.getActiveSpecies(tenantId: tenantId);
      expect(active.any((s) => s.id == created.id), isTrue);
    });

    test('watchActiveSpecies emits updates when new species is created', () async {
      expect(await dao.getActiveSpecies(tenantId: tenantId), isEmpty);

      final initial = await dao.watchActiveSpecies(tenantId: tenantId).first;
      expect(initial, isEmpty);

      await dao.createCustomSpecies(tenantId: tenantId, name: 'Camel');

      final updated = await dao.watchActiveSpecies(tenantId: tenantId).first;
      expect(updated.length, equals(1));
      expect(updated.first.code, equals('camel'));
    });

    test('upsertSyncedSpecies bulk inserts server delta records', () async {
      final now = DateTime.now().toUtc();
      await dao.upsertSyncedSpecies([
        SpeciesTableCompanion.insert(
          id: 'server-sp-1',
          tenantId: tenantId,
          name: 'Llama',
          code: 'llama',
          icon: const Value('camel'),
          isSystemDefault: const Value(false),
          isActive: const Value(true),
          createdAt: now,
          updatedAt: now,
          syncStatus: const Value('synced'),
          lastSyncedAt: Value(now),
        ),
      ]);

      final active = await dao.getActiveSpecies(tenantId: tenantId);
      expect(active.length, equals(1));
      expect(active.first.name, equals('Llama'));
      expect(active.first.code, equals('llama'));
      expect(active.first.syncStatus, equals('synced'));
    });
  });
}
