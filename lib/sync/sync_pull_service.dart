import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../database/app_database.dart';
import 'conflict_resolver.dart';

/// Result summary of an inbound delta pull operation.
class SyncPullResult {
  final DateTime serverTimestamp;
  final int totalDeltasApplied;
  final bool isSuccess;
  final String? errorMessage;

  const SyncPullResult({
    required this.serverTimestamp,
    required this.totalDeltasApplied,
    required this.isSuccess,
    this.errorMessage,
  });
}

/// Service that queries the backend sync endpoint and ingests delta updates into Drift.
class SyncPullService {
  final ApiClient apiClient;
  final AppDatabase db;
  final ConflictResolver conflictResolver;
  final ISecureStorageService storageService;

  SyncPullService({
    required this.apiClient,
    required this.db,
    required this.conflictResolver,
    required this.storageService,
  });

  /// Storage key template for tracking last pulled timestamp per tenant.
  static String cursorStorageKey(String tenantId) => 'sync_pull_cursor_$tenantId';

  /// Pulls delta updates from `GET /api/v1/sync/pull` and applies them locally.
  Future<SyncPullResult> pull({required String tenantId}) async {
    try {
      final cursorKey = cursorStorageKey(tenantId);
      final lastPulledAt = await storageService.read(cursorKey);

      final queryParams = <String, dynamic>{
        'tenant_id': tenantId,
      };
      if (lastPulledAt != null && lastPulledAt.isNotEmpty) {
        queryParams['since'] = lastPulledAt;
      }

      final response = await apiClient.dio.get<Map<String, dynamic>>(
        '/sync/pull',
        queryParameters: queryParams,
      );

      final data = response.data ?? {};
      final serverTimestampStr = data['timestamp']?.toString();
      final serverTimestamp =
          DateTime.tryParse(serverTimestampStr ?? '') ?? DateTime.now().toUtc();
      final rawDeltas = data['deltas'];
      final deltas = rawDeltas is Map
          ? Map<String, dynamic>.from(rawDeltas)
          : <String, dynamic>{};

      int count = 0;
      for (final list in deltas.values) {
        if (list is List) count += list.length;
      }

      // Apply deltas through the conflict resolver
      await conflictResolver.applyServerDeltas(
        tenantId: tenantId,
        deltas: deltas,
      );

      // Advance the local synchronization cursor
      await storageService.write(cursorKey, serverTimestamp.toIso8601String());

      return SyncPullResult(
        serverTimestamp: serverTimestamp,
        totalDeltasApplied: count,
        isSuccess: true,
      );
    } on DioException catch (e) {
      return SyncPullResult(
        serverTimestamp: DateTime.now().toUtc(),
        totalDeltasApplied: 0,
        isSuccess: false,
        errorMessage: e.message ?? 'Network error pulling sync deltas',
      );
    } catch (e) {
      return SyncPullResult(
        serverTimestamp: DateTime.now().toUtc(),
        totalDeltasApplied: 0,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}
