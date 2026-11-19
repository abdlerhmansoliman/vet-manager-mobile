import 'dart:async';
import 'dart:ffi';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/core/network/api_client.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/sync/conflict_resolver.dart';
import 'package:vet_manager_mobile/sync/sync_manager.dart';
import 'package:vet_manager_mobile/sync/sync_pull_service.dart';
import 'package:vet_manager_mobile/sync/sync_queue_dispatcher.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockDio extends Mock implements Dio {}
class MockSecureStorageService extends Mock implements ISecureStorageService {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late AppDatabase db;
  late ConflictResolver resolver;
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late MockSecureStorageService mockStorage;
  late MockConnectivity mockConnectivity;
  late SyncQueueDispatcher dispatcher;
  late SyncPullService pullService;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    resolver = ConflictResolver(db: db);
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    mockStorage = MockSecureStorageService();
    mockConnectivity = MockConnectivity();
    connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

    when(() => mockApiClient.dio).thenReturn(mockDio);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);

    dispatcher = SyncQueueDispatcher(
      apiClient: mockApiClient,
      db: db,
      conflictResolver: resolver,
    );

    pullService = SyncPullService(
      apiClient: mockApiClient,
      db: db,
      conflictResolver: resolver,
      storageService: mockStorage,
    );
  });

  tearDown(() async {
    await connectivityController.close();
    await db.close();
  });

  group('SyncQueueDispatcher — FIFO Outbox & Error Recovery', () {
    test('flush sends pending mutations in strict FIFO timestamp order and removes confirmed records', () async {
      const tenantId = 'tenant-alpha';
      final t1 = DateTime(2026, 10, 24, 10, 0);
      final t2 = DateTime(2026, 10, 24, 10, 5);

      // Insert item 2 first, item 1 second to verify FIFO sorting
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-2',
              tenantId: tenantId,
              entityType: 'patient',
              entityId: 'pat-2',
              action: 'create',
              payload: '{"name": "Shadow"}',
              clientTimestamp: t2,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000002',
              createdAt: t2,
            ),
          );

      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-1',
              tenantId: tenantId,
              entityType: 'client',
              entityId: 'client-1',
              action: 'create',
              payload: '{"name": "Sarah Connor"}',
              clientTimestamp: t1,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000001',
              createdAt: t1,
            ),
          );

      // Mock server batch response
      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#data] as Map<String, dynamic>;
        final mutations = body['mutations'] as List<dynamic>;

        // Strict FIFO verification: mut-1 (earlier timestamp) must be dispatched before mut-2
        expect(mutations.length, 2);
        expect(mutations[0]['mutation_id'], 'mut-1');
        expect(mutations[1]['mutation_id'], 'mut-2');

        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          statusCode: 200,
          data: {
            'status': 'success',
            'results': [
              {
                'mutation_id': 'mut-1',
                'entity_type': 'client',
                'entity_id': 'client-1',
                'status': 'applied',
              },
              {
                'mutation_id': 'mut-2',
                'entity_type': 'patient',
                'entity_id': 'pat-2',
                'status': 'applied',
              },
            ]
          },
        );
      });

      final result = await dispatcher.flush(tenantId: tenantId);

      expect(result.isSuccess, isTrue);
      expect(result.syncedCount, 2);
      expect(result.failedCount, 0);

      // Verified: Confirmed mutations are removed from the queue
      final remaining = await db.select(db.syncQueueTable).get();
      expect(remaining, isEmpty);
    });

    test('flush reverts in-flight mutations to pending with incremented attempt on network failure', () async {
      const tenantId = 'tenant-beta';
      final now = DateTime.now().toUtc();

      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-offline-1',
              tenantId: tenantId,
              entityType: 'clinical_case',
              entityId: 'case-1',
              action: 'create',
              payload: '{"caseNumber": "CAS-99"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000099',
              createdAt: now,
            ),
          );

      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/sync/push'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out in rural zone',
        ),
      );

      final result = await dispatcher.flush(tenantId: tenantId);

      expect(result.isSuccess, isFalse);
      expect(result.syncedCount, 0);

      // Verify item remains in queue with incremented attempts
      final queued = await db.select(db.syncQueueTable).get();
      expect(queued.length, 1);
      expect(queued.first.status, 'pending');
      expect(queued.first.attempts, 1);
      expect(queued.first.lastError, contains('Connection timed out'));
    });
  });

  group('SyncPullService — Delta Ingestion', () {
    test('pull fetches remote deltas and updates cursor timestamp in storage', () async {
      const tenantId = 'tenant-gamma';
      const cursorKey = 'sync_pull_cursor_$tenantId';
      final serverTime = DateTime(2026, 10, 24, 12, 0).toUtc();

      when(() => mockStorage.read(cursorKey)).thenAnswer((_) async => null);
      when(() => mockStorage.write(cursorKey, serverTime.toIso8601String()))
          .thenAnswer((_) async {});

      when(() => mockDio.get<Map<String, dynamic>>(
            '/sync/pull',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/sync/pull'),
            statusCode: 200,
            data: {
              'timestamp': serverTime.toIso8601String(),
              'deltas': {
                'clients': [
                  {
                    'id': 'c-delta-1',
                    'name': 'Oak Ridge Equine Center',
                    'phone_primary': '555-8888',
                  }
                ]
              }
            },
          ));

      final pullResult = await pullService.pull(tenantId: tenantId);

      expect(pullResult.isSuccess, isTrue);
      expect(pullResult.totalDeltasApplied, 1);
      verify(() => mockStorage.write(cursorKey, serverTime.toIso8601String())).called(1);

      final client = await (db.select(db.clientsTable)..where((c) => c.id.equals('c-delta-1'))).getSingleOrNull();
      expect(client, isNotNull);
      expect(client!.name, 'Oak Ridge Equine Center');
    });
  });

  group('SyncManager — Orchestrator & Connectivity', () {
    test('syncNow executes push followed by pull when tenant is present', () async {
      const tenantId = 'tenant-orchestrator';

      when(() => mockStorage.getTenantId()).thenAnswer((_) async => tenantId);
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      // Mock successful push
      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/sync/push'),
                statusCode: 200,
                data: <String, dynamic>{'status': 'success', 'results': <dynamic>[]},
              ));

      // Mock successful pull
      when(() => mockDio.get<Map<String, dynamic>>('/sync/pull', queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/sync/pull'),
                statusCode: 200,
                data: <String, dynamic>{
                  'timestamp': DateTime.now().toUtc().toIso8601String(),
                  'deltas': <String, dynamic>{},
                },
              ));

      final manager = SyncManager(
        queueDispatcher: dispatcher,
        pullService: pullService,
        db: db,
        storageService: mockStorage,
        connectivity: mockConnectivity,
      );

      final states = <SyncState>[];
      final sub = manager.stateStream.listen(states.add);

      await manager.syncNow(tenantId: tenantId);

      // State transitions to syncing and then to idle
      expect(states.any((s) => s.status == SyncStatus.syncing), isTrue);
      expect(manager.currentState.status, SyncStatus.idle);
      expect(manager.currentState.lastSyncedAt, isNotNull);

      await sub.cancel();
      manager.dispose();
    });

    test('transitions from offline to online triggers automatic syncNow', () async {
      const tenantId = 'tenant-auto';

      when(() => mockStorage.getTenantId()).thenAnswer((_) async => tenantId);
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/sync/push'),
                statusCode: 200,
                data: <String, dynamic>{'status': 'success', 'results': <dynamic>[]},
              ));

      when(() => mockDio.get<Map<String, dynamic>>('/sync/pull', queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/sync/pull'),
                statusCode: 200,
                data: <String, dynamic>{
                  'timestamp': DateTime.now().toUtc().toIso8601String(),
                  'deltas': <String, dynamic>{},
                },
              ));

      final manager = SyncManager(
        queueDispatcher: dispatcher,
        pullService: pullService,
        db: db,
        storageService: mockStorage,
        connectivity: mockConnectivity,
      );

      // 1. Simulate offline state
      connectivityController.add([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(manager.currentState.isOnline, isFalse);

      // 2. Simulate regaining WiFi connection
      connectivityController.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(manager.currentState.isOnline, isTrue);

      manager.dispose();
    });

    test('ingests visits deltas with soft-delete tombstones', () async {
      const tenantId = 'tenant-visits';
      final now = DateTime.now().toUtc();

      // Seed parent client and case
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'c-1',
              tenantId: tenantId,
              name: 'Owner',
              phonePrimary: '555-1234',
              clientType: const Value('individual'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'p-1',
              tenantId: tenantId,
              clientId: 'c-1',
              nameOrTag: 'Max',
              species: 'Canine',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-visit-1',
              tenantId: tenantId,
              caseNumber: 'CAS-001',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Limping',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Ingest visits delta containing an active visit and a soft-deleted visit
      await resolver.applyServerDeltas(
        tenantId: tenantId,
        deltas: {
          'visits': [
            {
              'id': 'v-active-1',
              'case_id': 'case-visit-1',
              'title': 'Active Visit',
              'visit_type': 'consultation',
              'status': 'open',
              'is_signed': false,
              'visit_date': now.toIso8601String(),
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
            },
            {
              'id': 'v-deleted-1',
              'case_id': 'case-visit-1',
              'title': 'Deleted Visit',
              'visit_type': 'consultation',
              'status': 'open',
              'is_signed': false,
              'visit_date': now.toIso8601String(),
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
              'deleted_at': now.toIso8601String(),
            },
          ],
        },
      );

      final visits = await db.select(db.visitsTable).get();
      expect(visits.length, 2);

      final active = visits.firstWhere((v) => v.id == 'v-active-1');
      expect(active.deletedAt, isNull);
      expect(active.title, 'Active Visit');

      final deleted = visits.firstWhere((v) => v.id == 'v-deleted-1');
      expect(deleted.deletedAt, isNotNull);
    });

    test('flush marks rejected mutations as failed and prevents infinite retry loop', () async {
      const tenantId = 'tenant-rejected';
      final now = DateTime.now().toUtc();

      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-rejected-1',
              tenantId: tenantId,
              entityType: 'visit',
              entityId: 'visit-locked-1',
              action: 'update',
              payload: '{"title": "Attempted Edit on Signed Visit"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000077',
              createdAt: now,
            ),
          );

      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/sync/push'),
            statusCode: 200,
            data: {
              'status': 'success',
              'results': [
                {
                  'mutation_id': 'mut-rejected-1',
                  'entity_type': 'visit',
                  'entity_id': 'visit-locked-1',
                  'status': 'rejected',
                  'message': 'Clinical visit visit-locked-1 is signed and locked (is_signed=true).',
                },
              ],
            },
          ));

      final result = await dispatcher.flush(tenantId: tenantId);

      expect(result.failedCount, 1);
      expect(result.syncedCount, 0);

      // Verify item was marked failed with error message
      final queueItem = await (db.select(db.syncQueueTable)..where((q) => q.id.equals('mut-rejected-1'))).getSingle();
      expect(queueItem.status, 'failed');
      expect(queueItem.lastError, contains('signed and locked'));

      // Subsequent flush must ignore failed items to prevent infinite retry loop
      final secondResult = await dispatcher.flush(tenantId: tenantId);
      expect(secondResult.syncedCount, 0);
      expect(secondResult.failedCount, 0);
    });

    test('flush sorts mutations in strict dependency order: Client -> Patient -> Case -> Visit', () async {
      const tenantId = 'tenant-order';
      final now = DateTime.now().toUtc();

      // Insert in reverse order (Visit first, Client last)
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-ord-visit',
              tenantId: tenantId,
              entityType: 'visit',
              entityId: 'v-1',
              action: 'create',
              payload: '{"title": "Encounter"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000004',
              createdAt: now,
            ),
          );
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-ord-case',
              tenantId: tenantId,
              entityType: 'case',
              entityId: 'c-1',
              action: 'create',
              payload: '{"chief_complaint": "Exam"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000003',
              createdAt: now,
            ),
          );
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-ord-patient',
              tenantId: tenantId,
              entityType: 'patient',
              entityId: 'p-1',
              action: 'create',
              payload: '{"name_or_tag": "Rex"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000002',
              createdAt: now,
            ),
          );
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: 'mut-ord-client',
              tenantId: tenantId,
              entityType: 'client',
              entityId: 'cl-1',
              action: 'create',
              payload: '{"name": "Alice"}',
              clientTimestamp: now,
              idempotencyKey: '018d4f20-8000-7000-8000-000000000001',
              createdAt: now,
            ),
          );

      when(() => mockDio.post<Map<String, dynamic>>(
            '/sync/push',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((inv) async {
        final body = inv.namedArguments[#data] as Map<String, dynamic>;
        final mutations = body['mutations'] as List<dynamic>;

        // Must be ordered: client (mut-ord-client) -> patient (mut-ord-patient) -> case (mut-ord-case) -> visit (mut-ord-visit)
        expect(mutations[0]['entity_type'], 'client');
        expect(mutations[1]['entity_type'], 'patient');
        expect(mutations[2]['entity_type'], 'case');
        expect(mutations[3]['entity_type'], 'visit');

        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          statusCode: 200,
          data: {
            'status': 'success',
            'results': mutations.map((m) => {
              'mutation_id': m['mutation_id'],
              'entity_type': m['entity_type'],
              'entity_id': m['entity_id'],
              'status': 'applied',
            }).toList(),
          },
        );
      });

      final result = await dispatcher.flush(tenantId: tenantId);
      expect(result.syncedCount, 4);
    });

    test('ConflictResolver ingests dose_administrations deltas into local database', () async {
      const tenantId = 'tenant-alpha';
      final now = DateTime.now().toUtc();

      // Seed parent hierarchy: client -> patient -> case -> visit
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'c-dose-1',
              tenantId: tenantId,
              name: 'Owner',
              phonePrimary: '555-1234',
              clientType: const Value('individual'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-dose-1',
              tenantId: tenantId,
              clientId: 'c-dose-1',
              nameOrTag: 'Buddy',
              species: 'Canine',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-dose-1',
              tenantId: tenantId,
              caseNumber: 'CAS-DOSE-001',
              patientId: 'pat-dose-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Limping',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.visitsTable).insert(
            VisitsTableCompanion.insert(
              id: 'visit-dose-1',
              tenantId: tenantId,
              caseId: 'case-dose-1',
              patientId: 'pat-dose-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Miller',
              title: 'Initial Consultation',
              visitDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Ingest dose delta from server
      await resolver.applyServerDeltas(
        tenantId: tenantId,
        deltas: {
          'dose_administrations': [
            {
              'id': 'dose-srv-1',
              'case_id': 'case-dose-1',
              'visit_id': 'visit-dose-1',
              'patient_id': 'pat-dose-1',
              'medicine_name': 'Meloxicam 1.5mg/ml',
              'dose_amount_base_units': '0.5000',
              'unit': 'ml',
              'route_administered': 'SQ',
              'clinical_notes': 'Injected subcutaneously between shoulder blades',
              'administered_by_user_id': 'vet-1',
              'created_at': now.toIso8601String(),
            },
          ],
        },
      );

      final doses = await (db.select(db.doseAdministrationsTable)
            ..where((d) => d.id.equals('dose-srv-1')))
          .get();

      expect(doses.length, 1);
      final dose = doses.first;
      expect(dose.medicineName, 'Meloxicam 1.5mg/ml');
      expect(dose.doseQuantity, '0.5000');
      expect(dose.unit, 'ml');
      expect(dose.route, 'SQ');
      expect(dose.veterinarianId, 'vet-1');
      expect(dose.patientId, 'pat-dose-1');
      expect(dose.tenantId, tenantId);
      expect(dose.syncStatus, 'synced');
    });

    test('ConflictResolver rejects doses with mismatched visit-case hierarchy or missing required drug info', () async {
      const tenantId = 'tenant-alpha';
      final now = DateTime.now().toUtc();

      // Seed valid hierarchy
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'c-val-1',
              tenantId: tenantId,
              name: 'Owner',
              phonePrimary: '555-9999',
              clientType: const Value('individual'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-val-1',
              tenantId: tenantId,
              clientId: 'c-val-1',
              nameOrTag: 'Bella',
              species: 'Feline',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-val-1',
              tenantId: tenantId,
              caseNumber: 'CAS-VAL-001',
              patientId: 'pat-val-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Vomiting',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.visitsTable).insert(
            VisitsTableCompanion.insert(
              id: 'visit-val-1',
              tenantId: tenantId,
              caseId: 'case-val-1',
              patientId: 'pat-val-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Miller',
              title: 'Checkup',
              visitDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Attempt to ingest doses:
      // 1. Visit belongs to a different case
      // 2. Missing medicine name
      // 3. Missing dose quantity
      await resolver.applyServerDeltas(
        tenantId: tenantId,
        deltas: {
          'dose_administrations': [
            {
              'id': 'dose-invalid-1',
              'case_id': 'case-other-unknown',
              'visit_id': 'visit-val-1',
              'patient_id': 'pat-val-1',
              'medicine_name': 'Amoxicillin',
              'dose_amount_base_units': '1.0000',
            },
            {
              'id': 'dose-invalid-2',
              'case_id': 'case-val-1',
              'visit_id': 'visit-val-1',
              'patient_id': 'pat-val-1',
              'medicine_name': '', // Empty name!
              'dose_amount_base_units': '1.0000',
            },
            {
              'id': 'dose-invalid-3',
              'case_id': 'case-val-1',
              'visit_id': 'visit-val-1',
              'patient_id': 'pat-val-1',
              'medicine_name': 'Amoxicillin',
              'dose_amount_base_units': '', // Empty dose!
            },
          ],
        },
      );

      final invalidDoses = await (db.select(db.doseAdministrationsTable)
            ..where((d) => d.id.isIn(['dose-invalid-1', 'dose-invalid-2', 'dose-invalid-3'])))
          .get();

      expect(invalidDoses, isEmpty);
    });

    test('ConflictResolver preserves un-synced offline dose from being overwritten by server delta', () async {
      const tenantId = 'tenant-alpha';
      final now = DateTime.now().toUtc();

      // Seed valid hierarchy
      await db.into(db.clientsTable).insert(
            ClientsTableCompanion.insert(
              id: 'c-offline-1',
              tenantId: tenantId,
              name: 'Owner',
              phonePrimary: '555-8888',
              clientType: const Value('individual'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.patientsTable).insert(
            PatientsTableCompanion.insert(
              id: 'pat-offline-1',
              tenantId: tenantId,
              clientId: 'c-offline-1',
              nameOrTag: 'Rocky',
              species: 'Canine',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: 'case-offline-1',
              tenantId: tenantId,
              caseNumber: 'CAS-OFFLINE-001',
              patientId: 'pat-offline-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Pain Management',
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.visitsTable).insert(
            VisitsTableCompanion.insert(
              id: 'visit-offline-1',
              tenantId: tenantId,
              caseId: 'case-offline-1',
              patientId: 'pat-offline-1',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Miller',
              title: 'Pain Exam',
              visitDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Local dose recorded offline with pending sync
      await db.into(db.doseAdministrationsTable).insert(
            DoseAdministrationsTableCompanion.insert(
              id: 'dose-offline-1',
              tenantId: tenantId,
              visitId: 'visit-offline-1',
              caseId: 'case-offline-1',
              patientId: 'pat-offline-1',
              medicineName: 'Tramadol 50mg',
              doseQuantity: '2.0000',
              unit: 'tablets',
              route: 'PO',
              veterinarianId: 'vet-1',
              veterinarianName: 'Dr. John Miller',
              administeredAt: now,
              createdAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      // Incoming server delta for same ID
      await resolver.applyServerDeltas(
        tenantId: tenantId,
        deltas: {
          'dose_administrations': [
            {
              'id': 'dose-offline-1',
              'case_id': 'case-offline-1',
              'visit_id': 'visit-offline-1',
              'patient_id': 'pat-offline-1',
              'medicine_name': 'Server Tramadol Overwrite Attempt',
              'dose_amount_base_units': '10.0000',
              'unit': 'tablets',
              'route_administered': 'PO',
              'created_at': now.toIso8601String(),
            },
          ],
        },
      );

      final dose = await (db.select(db.doseAdministrationsTable)
            ..where((d) => d.id.equals('dose-offline-1')))
          .getSingle();

      // Must NOT be overwritten
      expect(dose.medicineName, 'Tramadol 50mg');
      expect(dose.doseQuantity, '2.0000');
      expect(dose.syncStatus, 'pending');
    });
  });
}
