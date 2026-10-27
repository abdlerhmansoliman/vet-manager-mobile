import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../core/network/api_client.dart';
import '../database/app_database.dart';
import 'conflict_resolver.dart';

/// Summary of an outbound batch sync push operation.
class SyncPushResult {
  final int syncedCount;
  final int failedCount;
  final bool isSuccess;
  final String? errorMessage;
  final List<PushAckResult> acks;

  const SyncPushResult({
    required this.syncedCount,
    required this.failedCount,
    required this.isSuccess,
    this.errorMessage,
    this.acks = const [],
  });
}

/// Dispatches queued offline mutations to `POST /api/v1/sync/push` in strict FIFO order.
class SyncQueueDispatcher {
  final ApiClient apiClient;
  final AppDatabase db;
  final ConflictResolver conflictResolver;

  SyncQueueDispatcher({
    required this.apiClient,
    required this.db,
    required this.conflictResolver,
  });

  /// Flushes pending offline mutations in FIFO order.
  Future<SyncPushResult> flush({
    required String tenantId,
    int batchSize = 50,
  }) async {
    // 1. Fetch pending items ordered by offline client timestamp (FIFO)
    final pendingItems = await (db.select(db.syncQueueTable)
          ..where((q) =>
              q.tenantId.equals(tenantId) &
              q.status.isNotIn(['synced', 'in_flight']))
          ..orderBy([(q) => OrderingTerm(expression: q.clientTimestamp, mode: OrderingMode.asc)])
          ..limit(batchSize))
        .get();

    if (pendingItems.isEmpty) {
      return const SyncPushResult(syncedCount: 0, failedCount: 0, isSuccess: true);
    }

    final itemIds = pendingItems.map((e) => e.id).toList();

    // 2. Mark in-flight to prevent race conditions during rapid triggers
    await (db.update(db.syncQueueTable)..where((q) => q.id.isIn(itemIds))).write(
      const SyncQueueTableCompanion(status: Value('in_flight')),
    );

    // 3. Assemble batch push payload
    final mutationsList = pendingItems.map((item) {
      dynamic parsedPayload;
      try {
        parsedPayload = jsonDecode(item.payload);
      } catch (_) {
        parsedPayload = item.payload;
      }

      return {
        'mutation_id': item.id,
        'entity_type': item.entityType,
        'entity_id': item.entityId,
        'action': item.action,
        'payload': parsedPayload,
        'client_timestamp': item.clientTimestamp.toIso8601String(),
        'idempotency_key': item.idempotencyKey,
      };
    }).toList();

    try {
      final response = await apiClient.dio.post<Map<String, dynamic>>(
        '/sync/push',
        data: {'mutations': mutationsList},
      );

      final data = response.data ?? {};
      final resultsList = data['results'] as List<dynamic>? ?? [];
      final acks = <PushAckResult>[];

      int syncedCount = 0;
      int failedCount = 0;

      for (final rawAck in resultsList) {
        if (rawAck is Map<String, dynamic>) {
          final ack = PushAckResult.fromJson(rawAck);
          acks.add(ack);

          if (ack.status != PushAckStatus.rejected) {
            // Reconcile and apply acknowledgment locally
            await conflictResolver.resolvePushAck(ack);

            // Mutation successfully confirmed on server -> remove from queue
            await (db.delete(db.syncQueueTable)..where((q) => q.id.equals(ack.mutationId))).go();
            syncedCount++;
          } else {
            // Rejected on server
            await (db.update(db.syncQueueTable)..where((q) => q.id.equals(ack.mutationId))).write(
              SyncQueueTableCompanion(
                status: const Value('failed'),
                lastError: Value(ack.message ?? 'Server rejected mutation'),
              ),
            );
            failedCount++;
          }
        }
      }

      // If server returned a success response without individual results, mark all as synced
      if (resultsList.isEmpty && response.statusCode == 200) {
        for (final item in pendingItems) {
          final syntheticAck = PushAckResult(
            mutationId: item.id,
            entityType: item.entityType,
            entityId: item.entityId,
            status: PushAckStatus.applied,
          );
          await conflictResolver.resolvePushAck(syntheticAck);
          await (db.delete(db.syncQueueTable)..where((q) => q.id.equals(item.id))).go();
          syncedCount++;
        }
      }

      return SyncPushResult(
        syncedCount: syncedCount,
        failedCount: failedCount,
        isSuccess: true,
        acks: acks,
      );
    } on DioException catch (e) {
      // Revert in-flight items back to pending with incremented attempt count
      await _handlePushError(pendingItems, e.message ?? 'Network failure during sync push');
      return SyncPushResult(
        syncedCount: 0,
        failedCount: pendingItems.length,
        isSuccess: false,
        errorMessage: e.message ?? 'Network failure during sync push',
      );
    } catch (e) {
      await _handlePushError(pendingItems, e.toString());
      return SyncPushResult(
        syncedCount: 0,
        failedCount: pendingItems.length,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _handlePushError(List<SyncQueueData> items, String error) async {
    for (final item in items) {
      await (db.update(db.syncQueueTable)..where((q) => q.id.equals(item.id))).write(
        SyncQueueTableCompanion(
          status: const Value('pending'),
          attempts: Value(item.attempts + 1),
          lastError: Value(error),
        ),
      );
    }
  }
}
