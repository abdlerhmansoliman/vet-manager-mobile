import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/sync/conflict_resolver.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  test('apply real backend sync pull payload without errors', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final resolver = ConflictResolver(db: db);

    final file = File('/tmp/real_sync_pull.json');
    if (!file.existsSync()) {
      fail('/tmp/real_sync_pull.json does not exist');
    }

    final jsonMap = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final deltas = jsonMap['deltas'] as Map<String, dynamic>;

    await resolver.applyServerDeltas(
      tenantId: '32cd8fcf-7ab9-4dbd-a9bd-75f9f7fe4cd7',
      deltas: deltas,
    );

    final clients = await db.select(db.clientsTable).get();
    final patients = await db.select(db.patientsTable).get();
    final cases = await db.select(db.clinicalCasesTable).get();


    expect(clients.length, greaterThan(0));
    expect(patients.length, greaterThan(0));
    expect(cases.length, greaterThan(0));
    final notes = await db.select(db.clinicalProgressNotesTable).get();
    final products = await db.select(db.inventoryProductsTable).get();
    final batches = await db.select(db.inventoryBatchesTable).get();
    final containers = await db.select(db.inventoryContainersTable).get();


    expect(notes.length, greaterThan(0));
    expect(products.length, greaterThan(0));
    expect(batches.length, greaterThan(0));
    expect(containers.length, greaterThan(0));


    await db.close();
  });
}
