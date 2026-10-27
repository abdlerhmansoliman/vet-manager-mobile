import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../core/storage/secure_storage_service.dart';
import '../database/app_database.dart';
import 'sync_pull_service.dart';
import 'sync_queue_dispatcher.dart';

/// Operational synchronization states.
enum SyncStatus {
  idle,
  syncing,
  offline,
  error,
}

/// Immutable snapshot of the sync engine state.
class SyncState {
  final SyncStatus status;
  final int pendingMutationsCount;
  final DateTime? lastSyncedAt;
  final String? lastError;
  final bool isOnline;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingMutationsCount = 0,
    this.lastSyncedAt,
    this.lastError,
    this.isOnline = true,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingMutationsCount,
    DateTime? lastSyncedAt,
    String? lastError,
    bool? isOnline,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingMutationsCount: pendingMutationsCount ?? this.pendingMutationsCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Master Orchestrator for VetManager Mobile Offline Synchronization.
///
/// Features:
/// - Real-time network connectivity monitoring via [Connectivity].
/// - Automatic queue flushing and delta pull upon regaining network access.
/// - Reactive state stream for UI badges, banners, and offline indicators.
/// - In-memory and testable abstractions.
class SyncManager {
  final SyncQueueDispatcher queueDispatcher;
  final SyncPullService pullService;
  final AppDatabase db;
  final ISecureStorageService storageService;
  final Connectivity connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<SyncState> _stateController = StreamController<SyncState>.broadcast();

  SyncState _currentState = const SyncState();
  bool _isDisposed = false;
  bool _isSyncing = false;

  SyncManager({
    required this.queueDispatcher,
    required this.pullService,
    required this.db,
    required this.storageService,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity() {
    _initConnectivityListener();
  }

  /// Reactive stream of sync status for UI indicators.
  Stream<SyncState> get stateStream => _stateController.stream;

  /// Current synchronous snapshot.
  SyncState get currentState => _currentState;

  /// Reactive stream of pending queue count for a specific tenant.
  Stream<int> watchPendingCount({required String tenantId}) {
    return (db.select(db.syncQueueTable)
          ..where((q) => q.tenantId.equals(tenantId) & q.status.isNotIn(['synced'])))
        .watch()
        .map((list) => list.length);
  }

  void _initConnectivityListener() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      final isOnline = _isConnectivityOnline(results);
      final wasOffline = !_currentState.isOnline;

      _updateState(_currentState.copyWith(isOnline: isOnline));

      // Trigger automatic sync when transitioning from offline to online
      if (wasOffline && isOnline) {
        syncNow();
      }
    });
  }

  bool _isConnectivityOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  /// Executes bidirectional synchronization (Push outbound -> Pull inbound).
  Future<void> syncNow({String? tenantId}) async {
    if (_isSyncing) return;
    _isSyncing = true;

    _updateState(_currentState.copyWith(status: SyncStatus.syncing, lastError: null));

    try {
      final activeTenantId = tenantId ?? await storageService.getTenantId();
      if (activeTenantId == null || activeTenantId.isEmpty) {
        _isSyncing = false;
        _updateState(_currentState.copyWith(status: SyncStatus.idle));
        return;
      }

      // 1. Push: Flush outbound mutations in FIFO order
      final pushResult = await queueDispatcher.flush(tenantId: activeTenantId);

      // 2. Pull: Ingest remote server deltas
      final pullResult = await pullService.pull(tenantId: activeTenantId);

      final now = DateTime.now().toUtc();
      final hasError = !pushResult.isSuccess || !pullResult.isSuccess;
      final errorMessage = pushResult.errorMessage ?? pullResult.errorMessage;

      // Count remaining pending items
      final pendingCount = await (db.select(db.syncQueueTable)
            ..where((q) => q.tenantId.equals(activeTenantId) & q.status.isNotIn(['synced'])))
          .get()
          .then((l) => l.length);

      _updateState(
        _currentState.copyWith(
          status: hasError ? SyncStatus.error : SyncStatus.idle,
          pendingMutationsCount: pendingCount,
          lastSyncedAt: hasError ? _currentState.lastSyncedAt : now,
          lastError: errorMessage,
        ),
      );
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          status: SyncStatus.error,
          lastError: e.toString(),
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  void _updateState(SyncState newState) {
    if (_isDisposed) return;
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Releases resources and subscriptions.
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _stateController.close();
  }
}
