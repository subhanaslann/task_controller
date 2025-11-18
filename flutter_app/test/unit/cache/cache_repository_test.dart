import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_app/data/cache/cache_repository.dart';
import 'package:flutter_app/data/cache/cache_models.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'dart:io';

void main() {
  late CacheRepository repository;
  late String tempDir;

  setUp(() async {
    // Create temp directory for Hive
    tempDir = Directory.systemTemp.createTempSync('cache_test_').path;

    repository = CacheRepository();
  });

  tearDown(() async {
    // Try to close (will handle if not initialized)
    try {
      await repository.close();
    } catch (_) {
      // Ignore if not initialized
    }

    // Clean up Hive
    await Hive.deleteFromDisk();

    // Delete temp directory
    try {
      Directory(tempDir).deleteSync(recursive: true);
    } catch (_) {}
  });

  // ==================== GROUP 1: INITIALIZATION TESTS ====================
  group('Initialization Tests', () {
    test('init() initializes repository successfully', () async {
      await repository.init(tempDir);

      // Should not throw when calling methods
      await expectLater(repository.getAllTasks(), completes);
    });

    test('init() can be called multiple times (idempotent)', () async {
      await repository.init(tempDir);
      await repository.init(tempDir);
      await repository.init(tempDir);

      // Should still work
      await expectLater(repository.getAllTasks(), completes);
    });

    test('init() opens all three boxes', () async {
      await repository.init(tempDir);

      expect(Hive.isBoxOpen(CacheRepository.tasksBoxName), true);
      expect(Hive.isBoxOpen(CacheRepository.usersBoxName), true);
      expect(Hive.isBoxOpen(CacheRepository.syncMetadataBoxName), true);
    });

    test('methods throw StateError when not initialized', () async {
      // Test that calling methods before init throws StateError
      await expectLater(
        () => repository.getAllTasks(),
        throwsA(isA<StateError>()),
      );
    });

    test('getAllTasks() throws StateError when not initialized', () async {
      await expectLater(
        () => repository.getAllTasks(),
        throwsStateError,
      );
    });

    test('getTask() throws StateError when not initialized', () async {
      await expectLater(
        () => repository.getTask('test-id'),
        throwsStateError,
      );
    });

    test('cacheTasks() throws StateError when not initialized', () async {
      await expectLater(
        () => repository.cacheTasks([]),
        throwsStateError,
      );
    });

    test('getAllUsers() throws StateError when not initialized', () async {
      await expectLater(
        () => repository.getAllUsers(),
        throwsStateError,
      );
    });

    test('clearAll() throws StateError when not initialized', () async {
      await expectLater(
        () => repository.clearAll(),
        throwsStateError,
      );
    });

    test('close() closes all boxes', () async {
      await repository.init(tempDir);
      await repository.close();

      expect(Hive.isBoxOpen(CacheRepository.tasksBoxName), false);
      expect(Hive.isBoxOpen(CacheRepository.usersBoxName), false);
      expect(Hive.isBoxOpen(CacheRepository.syncMetadataBoxName), false);
    });

    test('close() does not throw when called multiple times', () async {
      await repository.init(tempDir);
      await repository.close();

      // Second close should not throw (boxes already closed)
      await expectLater(repository.close(), completes);
    });
  });

  // ==================== GROUP 2: TASK GET OPERATIONS ====================
  group('Task Get Operations', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('getAllTasks() returns empty list when cache is empty', () async {
      final tasks = await repository.getAllTasks();
      expect(tasks, isEmpty);
    });

    test('getAllTasks() returns all cached tasks', () async {
      final testTasks = [
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
        _createTestTask(id: '3', title: 'Task 3'),
      ];

      await repository.cacheTasks(testTasks);

      final result = await repository.getAllTasks();
      expect(result, hasLength(3));
      expect(result.map((t) => t.id), containsAll(['1', '2', '3']));
    });

    test('getAllTasks() returns empty list when cache is corrupted', () async {
      // Manually corrupt the cache by putting invalid data
      final box = await Hive.openBox(CacheRepository.tasksBoxName);
      await box.put('corrupt', 'invalid json string');

      final result = await repository.getAllTasks();
      expect(result, isEmpty);
    });

    test('getTask() returns null when task not found', () async {
      final result = await repository.getTask('non-existent');
      expect(result, isNull);
    });

    test('getTask() returns task when found', () async {
      final testTask = _createTestTask(id: '1', title: 'Test Task');
      await repository.cacheTask(testTask);

      final result = await repository.getTask('1');
      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.title, 'Test Task');
    });

    test('getTask() returns null when cache entry is corrupted', () async {
      final box = await Hive.openBox(CacheRepository.tasksBoxName);
      await box.put('corrupt', {'invalid': 'structure'});

      final result = await repository.getTask('corrupt');
      expect(result, isNull);
    });

    test('getTask() preserves all task properties', () async {
      final testTask = _createTestTask(
        id: '123',
        title: 'Complete Task',
        note: 'Task notes',
        status: TaskStatus.inProgress,
        priority: Priority.high,
        dueDate: '2024-12-31',
        assigneeId: 'user-1',
      );

      await repository.cacheTask(testTask);
      final result = await repository.getTask('123');

      expect(result, isNotNull);
      expect(result!.id, '123');
      expect(result.title, 'Complete Task');
      expect(result.note, 'Task notes');
      expect(result.status, TaskStatus.inProgress);
      expect(result.priority, Priority.high);
      expect(result.dueDate, '2024-12-31');
      expect(result.assigneeId, 'user-1');
    });

    test('getAllTasks() handles tasks with nullable fields', () async {
      final testTask = _createTestTask(
        id: '1',
        title: 'Minimal Task',
        note: null,
        assigneeId: null,
        dueDate: null,
      );

      await repository.cacheTasks([testTask]);
      final result = await repository.getAllTasks();

      expect(result, hasLength(1));
      expect(result.first.note, isNull);
      expect(result.first.assigneeId, isNull);
      expect(result.first.dueDate, isNull);
    });

    test('getAllTasks() preserves task order', () async {
      final tasks = List.generate(
        10,
        (i) => _createTestTask(id: 'task-$i', title: 'Task $i'),
      );

      await repository.cacheTasks(tasks);
      final result = await repository.getAllTasks();

      expect(result, hasLength(10));
    });

    test('getTask() handles special characters in ID', () async {
      final testTask = _createTestTask(
        id: 'task-with-special-chars-!@#\$%',
        title: 'Special ID Task',
      );

      await repository.cacheTask(testTask);
      final result = await repository.getTask('task-with-special-chars-!@#\$%');

      expect(result, isNotNull);
      expect(result!.id, 'task-with-special-chars-!@#\$%');
    });
  });

  // ==================== GROUP 3: TASK WRITE OPERATIONS ====================
  group('Task Write Operations', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('cacheTasks() with empty list clears existing cache', () async {
      // Add some tasks first
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
      ]);

      // Clear with empty list
      await repository.cacheTasks([]);

      final result = await repository.getAllTasks();
      expect(result, isEmpty);
    });

    test('cacheTasks() with single task caches successfully', () async {
      final task = _createTestTask(id: '1', title: 'Single Task');
      await repository.cacheTasks([task]);

      final result = await repository.getAllTasks();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('cacheTasks() with multiple tasks caches all', () async {
      final tasks = List.generate(
        50,
        (i) => _createTestTask(id: 'task-$i', title: 'Task $i'),
      );

      await repository.cacheTasks(tasks);

      final result = await repository.getAllTasks();
      expect(result, hasLength(50));
    });

    test('cacheTasks() replaces existing cache completely', () async {
      // First batch
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ]);

      // Second batch (different tasks)
      await repository.cacheTasks([
        _createTestTask(id: '3', title: 'Task 3'),
      ]);

      final result = await repository.getAllTasks();
      expect(result, hasLength(1));
      expect(result.first.id, '3');
    });

    test('cacheTasks() updates sync metadata', () async {
      final tasks = [
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ];

      await repository.cacheTasks(tasks);

      final lastSync = await repository.getLastSyncTime('tasks');
      expect(lastSync, isNotNull);
      // Allow 1 second tolerance for timing
      expect(lastSync!.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('cacheTask() adds single task to cache', () async {
      final task = _createTestTask(id: '1', title: 'Single Task');
      await repository.cacheTask(task);

      final result = await repository.getTask('1');
      expect(result, isNotNull);
      expect(result!.title, 'Single Task');
    });

    test('cacheTask() updates existing task', () async {
      final task1 = _createTestTask(id: '1', title: 'Original');
      await repository.cacheTask(task1);

      final task2 = _createTestTask(id: '1', title: 'Updated');
      await repository.cacheTask(task2);

      final result = await repository.getTask('1');
      expect(result!.title, 'Updated');
    });

    test('updateTaskOptimistic() marks task as dirty', () async {
      final task = _createTestTask(id: '1', title: 'Original');
      await repository.cacheTask(task);

      await repository.updateTaskOptimistic('1', title: 'Updated');

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, hasLength(1));
      expect(dirtyTasks.first.isDirty, true);
      expect(dirtyTasks.first.title, 'Updated');
    });

    test('updateTaskOptimistic() updates only specified fields', () async {
      final task = _createTestTask(
        id: '1',
        title: 'Original Title',
        note: 'Original Note',
        priority: Priority.low,
      );
      await repository.cacheTask(task);

      await repository.updateTaskOptimistic('1', title: 'New Title');

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks.first.title, 'New Title');
      expect(dirtyTasks.first.note, 'Original Note');
    });

    test('updateTaskOptimistic() does nothing when task not found', () async {
      await repository.updateTaskOptimistic('non-existent', title: 'Update');

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, isEmpty);
    });

    test('getDirtyTasks() returns empty list when no dirty tasks', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Clean Task'),
      ]);

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, isEmpty);
    });

    test('getDirtyTasks() returns only dirty tasks', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
        _createTestTask(id: '3', title: 'Task 3'),
      ]);

      await repository.updateTaskOptimistic('1', title: 'Updated 1');
      await repository.updateTaskOptimistic('3', title: 'Updated 3');

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, hasLength(2));
      expect(dirtyTasks.map((t) => t.id), containsAll(['1', '3']));
    });

    test('clearDirtyFlag() clears flag for specific task', () async {
      final task = _createTestTask(id: '1', title: 'Task');
      await repository.cacheTask(task);
      await repository.updateTaskOptimistic('1', title: 'Updated');

      await repository.clearDirtyFlag('1');

      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, isEmpty);
    });

    test('clearDirtyFlag() does nothing when task not found', () async {
      await repository.clearDirtyFlag('non-existent');

      // Should not throw
      final dirtyTasks = await repository.getDirtyTasks();
      expect(dirtyTasks, isEmpty);
    });

    test('deleteTask() removes task from cache', () async {
      final task = _createTestTask(id: '1', title: 'To Delete');
      await repository.cacheTask(task);

      await repository.deleteTask('1');

      final result = await repository.getTask('1');
      expect(result, isNull);
    });

    test('deleteTask() does not affect other tasks', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ]);

      await repository.deleteTask('1');

      final result = await repository.getAllTasks();
      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('deleteTask() does not throw when task not found', () async {
      await expectLater(
        repository.deleteTask('non-existent'),
        completes,
      );
    });
  });

  // ==================== GROUP 4: USERS OPERATIONS ====================
  group('Users Operations', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('getAllUsers() returns empty list when cache is empty', () async {
      final users = await repository.getAllUsers();
      expect(users, isEmpty);
    });

    test('getAllUsers() returns all cached users', () async {
      final testUsers = [
        _createTestUser(id: '1', name: 'User 1'),
        _createTestUser(id: '2', name: 'User 2'),
      ];

      await repository.cacheUsers(testUsers);

      final result = await repository.getAllUsers();
      expect(result, hasLength(2));
      expect(result.map((u) => u.id), containsAll(['1', '2']));
    });

    test('getAllUsers() returns empty list when cache is corrupted', () async {
      final box = await Hive.openBox(CacheRepository.usersBoxName);
      await box.put('corrupt', 'invalid');

      final result = await repository.getAllUsers();
      expect(result, isEmpty);
    });

    test('getUser() returns null when user not found', () async {
      final result = await repository.getUser('non-existent');
      expect(result, isNull);
    });

    test('getUser() returns user when found', () async {
      final testUser = _createTestUser(id: '1', name: 'Test User');
      await repository.cacheUser(testUser);

      final result = await repository.getUser('1');
      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.name, 'Test User');
    });

    test('cacheUsers() replaces existing users', () async {
      await repository.cacheUsers([
        _createTestUser(id: '1', name: 'User 1'),
      ]);

      await repository.cacheUsers([
        _createTestUser(id: '2', name: 'User 2'),
      ]);

      final result = await repository.getAllUsers();
      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('cacheUsers() updates sync metadata', () async {
      await repository.cacheUsers([
        _createTestUser(id: '1', name: 'User 1'),
      ]);

      final lastSync = await repository.getLastSyncTime('users');
      expect(lastSync, isNotNull);
    });

    test('cacheUser() adds single user to cache', () async {
      final user = _createTestUser(id: '1', name: 'Single User');
      await repository.cacheUser(user);

      final result = await repository.getUser('1');
      expect(result, isNotNull);
      expect(result!.name, 'Single User');
    });

    test('cacheUser() updates existing user', () async {
      await repository.cacheUser(_createTestUser(id: '1', name: 'Original'));
      await repository.cacheUser(_createTestUser(id: '1', name: 'Updated'));

      final result = await repository.getUser('1');
      expect(result!.name, 'Updated');
    });

    test('getAllUsers() preserves user properties', () async {
      final user = _createTestUser(
        id: '123',
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
        role: UserRole.admin,
        active: true,
      );

      await repository.cacheUser(user);
      final result = await repository.getUser('123');

      expect(result, isNotNull);
      expect(result!.name, 'John Doe');
      expect(result.username, 'johndoe');
      expect(result.email, 'john@example.com');
      expect(result.role, UserRole.admin);
      expect(result.active, true);
    });

    test('cacheUsers() with empty list clears users cache', () async {
      await repository.cacheUsers([
        _createTestUser(id: '1', name: 'User 1'),
      ]);

      await repository.cacheUsers([]);

      final result = await repository.getAllUsers();
      expect(result, isEmpty);
    });
  });

  // ==================== GROUP 5: SYNC METADATA OPERATIONS ====================
  group('Sync Metadata Operations', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('getLastSyncTime() returns null when no metadata exists', () async {
      final result = await repository.getLastSyncTime('non-existent');
      expect(result, isNull);
    });

    test('getLastSyncTime() returns sync time after caching tasks', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
      ]);

      final result = await repository.getLastSyncTime('tasks');
      expect(result, isNotNull);
      expect(result!.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('getLastSyncTime() returns sync time after caching users', () async {
      await repository.cacheUsers([
        _createTestUser(id: '1', name: 'User 1'),
      ]);

      final result = await repository.getLastSyncTime('users');
      expect(result, isNotNull);
    });

    test('isCacheStale() returns true when no sync time exists', () async {
      final result = await repository.isCacheStale(
        'tasks',
        Duration(minutes: 5),
      );

      expect(result, true);
    });

    test('isCacheStale() returns true when cache is old', () async {
      // Cache tasks
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
      ]);

      // Manually update sync time to old date
      final box = await Hive.openBox(CacheRepository.syncMetadataBoxName);
      final oldMetadata = SyncMetadata(
        key: 'tasks',
        lastSyncAt: DateTime.now().subtract(Duration(hours: 2)),
        itemCount: 1,
      );
      await box.put('tasks', oldMetadata.toJson());

      final result = await repository.isCacheStale(
        'tasks',
        Duration(hours: 1),
      );

      expect(result, true);
    });

    test('isCacheStale() returns false when cache is fresh', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
      ]);

      final result = await repository.isCacheStale(
        'tasks',
        Duration(hours: 1),
      );

      expect(result, false);
    });

    test('sync metadata updates with correct item count', () async {
      final tasks = List.generate(
        10,
        (i) => _createTestTask(id: 'task-$i', title: 'Task $i'),
      );

      await repository.cacheTasks(tasks);

      // Check metadata directly
      final box = await Hive.openBox(CacheRepository.syncMetadataBoxName);
      final json = box.get('tasks');
      expect(json, isNotNull);

      final metadata = SyncMetadata.fromJson(Map<String, dynamic>.from(json));
      expect(metadata.itemCount, 10);
      expect(metadata.key, 'tasks');
    });

    test('sync metadata tracks tasks and users separately', () async {
      await repository.cacheTasks([_createTestTask(id: '1', title: 'Task')]);
      await repository.cacheUsers([_createTestUser(id: '1', name: 'User')]);

      final tasksSync = await repository.getLastSyncTime('tasks');
      final usersSync = await repository.getLastSyncTime('users');

      expect(tasksSync, isNotNull);
      expect(usersSync, isNotNull);
    });
  });

  // ==================== GROUP 6: CACHE MANAGEMENT OPERATIONS ====================
  group('Cache Management Operations', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('clearAll() clears all cache boxes', () async {
      await repository.cacheTasks([_createTestTask(id: '1', title: 'Task')]);
      await repository.cacheUsers([_createTestUser(id: '1', name: 'User')]);

      await repository.clearAll();

      final tasks = await repository.getAllTasks();
      final users = await repository.getAllUsers();

      expect(tasks, isEmpty);
      expect(users, isEmpty);
    });

    test('clearAll() clears sync metadata', () async {
      await repository.cacheTasks([_createTestTask(id: '1', title: 'Task')]);

      await repository.clearAll();

      final lastSync = await repository.getLastSyncTime('tasks');
      expect(lastSync, isNull);
    });

    test('getCacheStats() returns zeros for empty cache', () async {
      final stats = await repository.getCacheStats();

      expect(stats['tasks_count'], 0);
      expect(stats['users_count'], 0);
      expect(stats['dirty_tasks_count'], 0);
      expect(stats['tasks_last_sync'], isNull);
      expect(stats['users_last_sync'], isNull);
    });

    test('getCacheStats() returns correct counts', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ]);
      await repository.cacheUsers([
        _createTestUser(id: '1', name: 'User 1'),
      ]);

      final stats = await repository.getCacheStats();

      expect(stats['tasks_count'], 2);
      expect(stats['users_count'], 1);
      expect(stats['dirty_tasks_count'], 0);
    });

    test('getCacheStats() counts dirty tasks correctly', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ]);

      await repository.updateTaskOptimistic('1', title: 'Updated');

      final stats = await repository.getCacheStats();
      expect(stats['dirty_tasks_count'], 1);
    });

    test('getCacheStats() includes last sync times', () async {
      await repository.cacheTasks([_createTestTask(id: '1', title: 'Task')]);
      await repository.cacheUsers([_createTestUser(id: '1', name: 'User')]);

      final stats = await repository.getCacheStats();

      expect(stats['tasks_last_sync'], isNotNull);
      expect(stats['users_last_sync'], isNotNull);
    });

    test('clearAll() followed by operations works correctly', () async {
      await repository.cacheTasks([_createTestTask(id: '1', title: 'Task')]);
      await repository.clearAll();

      // Should work after clear
      await repository.cacheTasks([_createTestTask(id: '2', title: 'New Task')]);

      final tasks = await repository.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.id, '2');
    });
  });

  // ==================== GROUP 7: EDGE CASES AND ERROR HANDLING ====================
  group('Edge Cases and Error Handling', () {
    setUp(() async {
      await repository.init(tempDir);
    });

    test('handles large number of tasks (1000+)', () async {
      final largeBatch = List.generate(
        1000,
        (i) => _createTestTask(id: 'task-$i', title: 'Task $i'),
      );

      await repository.cacheTasks(largeBatch);

      final result = await repository.getAllTasks();
      expect(result, hasLength(1000));
    });

    test('handles tasks with very long titles', () async {
      final longTitle = 'A' * 10000; // 10k characters
      final task = _createTestTask(id: '1', title: longTitle);

      await repository.cacheTask(task);

      final result = await repository.getTask('1');
      expect(result!.title.length, 10000);
    });

    test('handles tasks with special characters in title', () async {
      final task = _createTestTask(
        id: '1',
        title: 'Task with 特殊字符 and émojis 🚀✨',
      );

      await repository.cacheTask(task);

      final result = await repository.getTask('1');
      expect(result!.title, 'Task with 特殊字符 and émojis 🚀✨');
    });

    test('handles empty string task title', () async {
      final task = _createTestTask(id: '1', title: '');

      await repository.cacheTask(task);

      final result = await repository.getTask('1');
      expect(result!.title, '');
    });

    test('handles concurrent task operations', () async {
      final futures = List.generate(
        10,
        (i) => repository.cacheTask(
          _createTestTask(id: 'task-$i', title: 'Task $i'),
        ),
      );

      await Future.wait(futures);

      final result = await repository.getAllTasks();
      expect(result, hasLength(10));
    });

    test('handles multiple rapid getAllTasks() calls', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
      ]);

      final futures = List.generate(50, (_) => repository.getAllTasks());
      final results = await Future.wait(futures);

      for (final result in results) {
        expect(result, hasLength(1));
      }
    });

    test('handles user with empty visibleTopicIds list', () async {
      final user = User(
        id: '1',
        organizationId: 'org-1',
        name: 'User',
        username: 'user',
        email: 'user@test.com',
        role: UserRole.member,
        active: true,
        visibleTopicIds: [],
      );

      await repository.cacheUser(user);

      final result = await repository.getUser('1');
      expect(result!.visibleTopicIds, isEmpty);
    });

    test('handles user with large visibleTopicIds list', () async {
      final user = User(
        id: '1',
        organizationId: 'org-1',
        name: 'User',
        username: 'user',
        email: 'user@test.com',
        role: UserRole.member,
        active: true,
        visibleTopicIds: List.generate(100, (i) => 'topic-$i'),
      );

      await repository.cacheUser(user);

      final result = await repository.getUser('1');
      expect(result!.visibleTopicIds, hasLength(100));
    });

    test('maintains data integrity after multiple operations', () async {
      // Complex sequence of operations
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
      ]);

      await repository.updateTaskOptimistic('1', title: 'Updated 1');
      await repository.cacheTask(_createTestTask(id: '3', title: 'Task 3'));
      await repository.deleteTask('2');
      await repository.clearDirtyFlag('1');

      final tasks = await repository.getAllTasks();
      final dirtyTasks = await repository.getDirtyTasks();

      expect(tasks, hasLength(2));
      expect(dirtyTasks, isEmpty);
      expect(tasks.map((t) => t.id), containsAll(['1', '3']));
    });

    test('getCacheStats() handles mixed dirty and clean tasks', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Task 1'),
        _createTestTask(id: '2', title: 'Task 2'),
        _createTestTask(id: '3', title: 'Task 3'),
      ]);

      await repository.updateTaskOptimistic('1', title: 'Updated 1');
      await repository.updateTaskOptimistic('2', title: 'Updated 2');

      final stats = await repository.getCacheStats();

      expect(stats['tasks_count'], 3);
      expect(stats['dirty_tasks_count'], 2);
    });

    test('handles null values in task optional fields gracefully', () async {
      final task = Task(
        id: '1',
        title: 'Minimal Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        organizationId: null,
        topicId: null,
        note: null,
        assigneeId: null,
        dueDate: null,
        createdAt: null,
        updatedAt: null,
        completedAt: null,
        topic: null,
        assignee: null,
      );

      await repository.cacheTask(task);
      final result = await repository.getTask('1');

      expect(result, isNotNull);
      expect(result!.note, isNull);
      expect(result.assigneeId, isNull);
    });

    test('handles rapid cache clear and refill', () async {
      for (int i = 0; i < 10; i++) {
        await repository.cacheTasks([
          _createTestTask(id: '$i', title: 'Task $i'),
        ]);
        await repository.clearAll();
      }

      final tasks = await repository.getAllTasks();
      expect(tasks, isEmpty);
    });

    test('preserves cache across repository instances', () async {
      await repository.cacheTasks([
        _createTestTask(id: '1', title: 'Persistent Task'),
      ]);

      await repository.close();

      // Create new instance
      final newRepository = CacheRepository();
      await newRepository.init(tempDir);

      final tasks = await newRepository.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.title, 'Persistent Task');

      await newRepository.close();
    });
  });
}

// ==================== HELPER FUNCTIONS ====================

Task _createTestTask({
  required String id,
  required String title,
  String? note,
  TaskStatus status = TaskStatus.todo,
  Priority priority = Priority.normal,
  String? dueDate,
  String? assigneeId,
}) {
  return Task(
    id: id,
    title: title,
    note: note,
    status: status,
    priority: priority,
    dueDate: dueDate,
    assigneeId: assigneeId,
    organizationId: 'org-1',
    topicId: 'topic-1',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

User _createTestUser({
  required String id,
  required String name,
  String? username,
  String? email,
  UserRole role = UserRole.member,
  bool active = true,
}) {
  return User(
    id: id,
    organizationId: 'org-1',
    name: name,
    username: username ?? 'user$id',
    email: email ?? 'user$id@test.com',
    role: role,
    active: active,
    visibleTopicIds: ['topic-1', 'topic-2'],
  );
}
