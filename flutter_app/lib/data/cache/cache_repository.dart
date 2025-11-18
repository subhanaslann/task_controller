import 'package:hive_flutter/hive_flutter.dart';
import 'cache_models.dart';
import '../models/task.dart';
import '../models/user.dart';

/// TekTech CacheRepository
/// 
/// Local cache layer using Hive
/// - Offline data access
/// - Optimistic updates
/// - Sync metadata tracking
class CacheRepository {
  static const String tasksBoxName = 'tasks';
  static const String usersBoxName = 'users';
  static const String syncMetadataBoxName = 'sync_metadata';

  late Box _tasksBox;
  late Box _usersBox;
  late Box _syncMetadataBox;
  bool _isInitialized = false;

  /// Check if repository is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('CacheRepository not initialized. Call init() first.');
    }
  }

  /// Initialize Hive and open boxes
  Future<void> init([String? path]) async {
    if (_isInitialized) return;

    // Initialize Hive (use provided path for testing)
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }

    // Open boxes (JSON-based, no adapters needed)
    _tasksBox = await Hive.openBox(tasksBoxName);
    _usersBox = await Hive.openBox(usersBoxName);
    _syncMetadataBox = await Hive.openBox(syncMetadataBoxName);

    _isInitialized = true;
  }

  // ==================== TASKS ====================

  /// Get all cached tasks
  Future<List<Task>> getAllTasks() async {
    _ensureInitialized();
    try {
      final cached = _tasksBox.values.map((json) => TaskCache.fromJson(Map<String, dynamic>.from(json))).toList();
      return cached.map((c) => c.toTask()).toList();
    } catch (e) {
      // Return empty list on error (corrupted cache)
      return [];
    }
  }

  /// Get cached task by ID
  Future<Task?> getTask(String id) async {
    _ensureInitialized();
    try {
      final json = _tasksBox.get(id);
      if (json == null) return null;
      final cached = TaskCache.fromJson(Map<String, dynamic>.from(json));
      return cached.toTask();
    } catch (e) {
      return null;
    }
  }

  /// Cache tasks (replaces existing)
  Future<void> cacheTasks(List<Task> tasks) async {
    _ensureInitialized();
    await _tasksBox.clear();
    for (var task in tasks) {
      final cached = TaskCache.fromTask(task);
      await _tasksBox.put(task.id, cached.toJson());
    }

    // Update sync metadata
    await _updateSyncMetadata('tasks', tasks.length);
  }

  /// Cache single task
  Future<void> cacheTask(Task task) async {
    _ensureInitialized();
    final cached = TaskCache.fromTask(task);
    await _tasksBox.put(task.id, cached.toJson());
  }

  /// Update task optimistically (marks as dirty)
  Future<void> updateTaskOptimistic(String id, {
    String? title,
    String? note,
    String? status,
    String? priority,
    String? dueDate,
  }) async {
    final json = _tasksBox.get(id);
    if (json != null) {
      final existing = TaskCache.fromJson(Map<String, dynamic>.from(json));
      final updated = existing.copyWithDirty(
        title: title,
        note: note,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );
      await _tasksBox.put(id, updated.toJson());
    }
  }

  /// Get all dirty (unsynced) tasks
  Future<List<TaskCache>> getDirtyTasks() async {
    return _tasksBox.values
        .map((json) => TaskCache.fromJson(Map<String, dynamic>.from(json)))
        .where((t) => t.isDirty)
        .toList();
  }

  /// Clear dirty flag after sync
  Future<void> clearDirtyFlag(String id) async {
    final json = _tasksBox.get(id);
    if (json != null) {
      final existing = TaskCache.fromJson(Map<String, dynamic>.from(json));
      final clean = TaskCache(
        id: existing.id,
        topicId: existing.topicId,
        title: existing.title,
        note: existing.note,
        assigneeId: existing.assigneeId,
        status: existing.status,
        priority: existing.priority,
        dueDate: existing.dueDate,
        createdAt: existing.createdAt,
        updatedAt: existing.updatedAt,
        completedAt: existing.completedAt,
        topicTitle: existing.topicTitle,
        assigneeName: existing.assigneeName,
        cachedAt: existing.cachedAt,
        isDirty: false,
      );
      await _tasksBox.put(id, clean.toJson());
    }
  }

  /// Delete cached task
  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  // ==================== USERS ====================

  /// Get all cached users
  Future<List<User>> getAllUsers() async {
    _ensureInitialized();
    try {
      final cached = _usersBox.values.map((json) => UserCache.fromJson(Map<String, dynamic>.from(json))).toList();
      return cached.map((c) => c.toUser()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get cached user by ID
  Future<User?> getUser(String id) async {
    final json = _usersBox.get(id);
    if (json == null) return null;
    final cached = UserCache.fromJson(Map<String, dynamic>.from(json));
    return cached.toUser();
  }

  /// Cache users (replaces existing)
  Future<void> cacheUsers(List<User> users) async {
    await _usersBox.clear();
    for (var user in users) {
      final cached = UserCache.fromUser(user);
      await _usersBox.put(user.id, cached.toJson());
    }

    // Update sync metadata
    await _updateSyncMetadata('users', users.length);
  }

  /// Cache single user
  Future<void> cacheUser(User user) async {
    final cached = UserCache.fromUser(user);
    await _usersBox.put(user.id, cached.toJson());
  }

  // ==================== SYNC METADATA ====================

  /// Get last sync time for a key
  Future<DateTime?> getLastSyncTime(String key) async {
    final json = _syncMetadataBox.get(key);
    if (json == null) return null;
    final metadata = SyncMetadata.fromJson(Map<String, dynamic>.from(json));
    return metadata.lastSyncAt;
  }

  /// Check if cache is stale (older than threshold)
  Future<bool> isCacheStale(String key, Duration threshold) async {
    final lastSync = await getLastSyncTime(key);
    if (lastSync == null) return true;
    
    return DateTime.now().difference(lastSync) > threshold;
  }

  Future<void> _updateSyncMetadata(String key, int itemCount) async {
    final metadata = SyncMetadata(
      key: key,
      lastSyncAt: DateTime.now(),
      itemCount: itemCount,
    );
    await _syncMetadataBox.put(key, metadata.toJson());
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all cache
  Future<void> clearAll() async {
    _ensureInitialized();
    await _tasksBox.clear();
    await _usersBox.clear();
    await _syncMetadataBox.clear();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final dirtyCount = _tasksBox.values
        .map((json) => TaskCache.fromJson(Map<String, dynamic>.from(json)))
        .where((t) => t.isDirty)
        .length;
    
    return {
      'tasks_count': _tasksBox.length,
      'users_count': _usersBox.length,
      'dirty_tasks_count': dirtyCount,
      'tasks_last_sync': await getLastSyncTime('tasks'),
      'users_last_sync': await getLastSyncTime('users'),
    };
  }

  /// Close all boxes
  Future<void> close() async {
    await _tasksBox.close();
    await _usersBox.close();
    await _syncMetadataBox.close();
  }
}
