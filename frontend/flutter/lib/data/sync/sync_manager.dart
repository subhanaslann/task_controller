import 'dart:async';
import 'package:logger/logger.dart';
import '../cache/cache_repository.dart';
import '../repositories/task_repository.dart';

/// TekTech SyncManager
///
/// Manages offline/online synchronization
/// - Cache-first strategy
/// - Automatic sync on connectivity
/// - Background sync for dirty data
/// - Conflict resolution
class SyncManager {
  final CacheRepository _cacheRepo;
  final TaskRepository _taskRepo;
  final Logger _logger = Logger();

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _cacheStaleThreshold = Duration(hours: 1);

  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncManager({
    required CacheRepository cacheRepo,
    required TaskRepository taskRepo,
  }) : _cacheRepo = cacheRepo,
       _taskRepo = taskRepo;

  /// Start automatic sync
  void startAutoSync() {
    _logger.i('Starting auto-sync (every ${_syncInterval.inMinutes} minutes)');
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncAll());
  }

  /// Stop automatic sync
  void stopAutoSync() {
    _logger.i('Stopping auto-sync');
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sync all data (tasks + users)
  Future<SyncResult> syncAll({bool force = false}) async {
    if (_isSyncing && !force) {
      _logger.w('Sync already in progress, skipping');
      return SyncResult.skipped();
    }

    _isSyncing = true;
    final startTime = DateTime.now();

    try {
      _logger.i('Starting full sync...');

      // 1. Sync dirty (locally modified) tasks first
      final dirtyTasksResult = await _syncDirtyTasks();

      // 2. Fetch fresh data from server
      final fetchResult = await _fetchAndCacheFreshData(force);

      final duration = DateTime.now().difference(startTime);
      _logger.i('Sync completed in ${duration.inSeconds}s');

      return SyncResult(
        success: true,
        dirtyTasksSynced: dirtyTasksResult.count,
        tasksFetched: fetchResult.tasksFetched,
        usersFetched: fetchResult.usersFetched,
        duration: duration,
      );
    } catch (e, stackTrace) {
      _logger.e('Sync failed', error: e, stackTrace: stackTrace);
      return SyncResult.error(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync dirty (unsynced) tasks
  Future<_DirtySyncResult> _syncDirtyTasks() async {
    final dirtyTasks = await _cacheRepo.getDirtyTasks();

    if (dirtyTasks.isEmpty) {
      _logger.d('No dirty tasks to sync');
      return _DirtySyncResult(count: 0);
    }

    _logger.i('Syncing ${dirtyTasks.length} dirty tasks');
    int synced = 0;

    for (var cachedTask in dirtyTasks) {
      try {
        // Push local changes to server
        final task = cachedTask.toTask();
        await _taskRepo.updateTaskStatus(task.id, task.status);

        // Clear dirty flag
        await _cacheRepo.clearDirtyFlag(task.id);
        synced++;

        _logger.d('Synced dirty task: ${task.id}');
      } catch (e) {
        _logger.w('Failed to sync dirty task ${cachedTask.id}: $e');
        // Keep dirty flag for retry
      }
    }

    return _DirtySyncResult(count: synced);
  }

  /// Fetch fresh data and update cache
  Future<_FetchResult> _fetchAndCacheFreshData(bool force) async {
    int tasksFetched = 0;
    int usersFetched = 0;

    // Check if cache is stale
    final tasksStale =
        force || await _cacheRepo.isCacheStale('tasks', _cacheStaleThreshold);

    // Fetch tasks if stale
    if (tasksStale) {
      try {
        _logger.d('Fetching fresh tasks...');
        final tasks = await _taskRepo.getMyActiveTasks();
        await _cacheRepo.cacheTasks(tasks);
        tasksFetched = tasks.length;
        _logger.i('Cached $tasksFetched tasks');
      } catch (e) {
        _logger.w('Failed to fetch tasks: $e');
      }
    } else {
      _logger.d('Tasks cache is fresh, skipping fetch');
    }

    // Users fetch is skipped - only admin needs users and they don't use cache
    // Guest and member don't have access to /users endpoint
    _logger.d('Skipping users sync (not needed for cache)');

    return _FetchResult(tasksFetched: tasksFetched, usersFetched: usersFetched);
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheRepo.getCacheStats();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    _logger.w('Clearing all cache');
    await _cacheRepo.clearAll();
  }

  /// Dispose resources
  void dispose() {
    stopAutoSync();
  }
}

/// Sync result summary
class SyncResult {
  final bool success;
  final String? error;
  final int dirtyTasksSynced;
  final int tasksFetched;
  final int usersFetched;
  final Duration? duration;

  SyncResult({
    required this.success,
    this.error,
    this.dirtyTasksSynced = 0,
    this.tasksFetched = 0,
    this.usersFetched = 0,
    this.duration,
  });

  factory SyncResult.error(String error) {
    return SyncResult(success: false, error: error);
  }

  factory SyncResult.skipped() {
    return SyncResult(success: false, error: 'Already syncing');
  }

  @override
  String toString() {
    if (!success) return 'SyncResult(failed: $error)';
    return 'SyncResult(dirty: $dirtyTasksSynced, tasks: $tasksFetched, users: $usersFetched, took: ${duration?.inSeconds}s)';
  }
}

class _DirtySyncResult {
  final int count;
  _DirtySyncResult({required this.count});
}

class _FetchResult {
  final int tasksFetched;
  final int usersFetched;
  _FetchResult({required this.tasksFetched, required this.usersFetched});
}
