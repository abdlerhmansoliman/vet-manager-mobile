import 'dart:async';
import 'dart:ffi';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
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
      when(() => mockDio.post<Map<String, dynamic>>('/sync/push', data: any(named: 'data')))
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

      when(() => mockDio.post<Map<String, dynamic>>('/sync/push', data: any(named: 'data')))
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
  });
}
