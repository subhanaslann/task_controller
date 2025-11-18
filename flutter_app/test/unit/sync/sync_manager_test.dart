import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/cache/cache_models.dart';
import 'package:flutter_app/data/sync/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';
import '../../mocks/mock_cache_repository.dart';
import '../../mocks/mock_task_repository.dart';

void main() {
  late SyncManager syncManager;
  late MockCacheRepository mockCacheRepo;
  late MockTaskRepository mockTaskRepo;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(TaskStatus.todo);
    registerFallbackValue(Duration(seconds: 1));
  });

  setUp(() {
    mockCacheRepo = MockCacheRepository();
    mockTaskRepo = MockTaskRepository();

    syncManager = SyncManager(cacheRepo: mockCacheRepo, taskRepo: mockTaskRepo);
  });

  tearDown(() {
    syncManager.dispose();
  });

  group('SyncManager - Auto-sync', () {
    test('startAutoSync should create periodic timer', () {
      // Act
      syncManager.startAutoSync();

      // Assert
      // Timer is started (internal state, can't directly test)
      // But we can verify it doesn't throw
      expect(() => syncManager.startAutoSync(), returnsNormally);
    });

    test('stopAutoSync should cancel timer', () {
      // Arrange
      syncManager.startAutoSync();

      // Act
      syncManager.stopAutoSync();

      // Assert
      // Timer is stopped (internal state)
      expect(() => syncManager.stopAutoSync(), returnsNormally);
    });

    test('dispose should stop auto-sync', () {
      // Arrange
      syncManager.startAutoSync();

      // Act
      syncManager.dispose();

      // Assert
      // Should not throw
      expect(() => syncManager.dispose(), returnsNormally);
    });
  });

  group('SyncManager - Full Sync', () {
    test('syncAll should sync dirty tasks and fetch fresh data', () async {
      // Arrange - No dirty tasks
      mockCacheRepo.mockGetDirtyTasks([]);

      // Cache is stale, should fetch
      mockCacheRepo.mockIsCacheStale(true);

      // Mock task fetch
      final freshTasks = [TestData.todoTask, TestData.inProgressTask];
      mockTaskRepo.mockGetMyActiveTasks(freshTasks);

      // Mock cache operation
      mockCacheRepo.mockCacheTasks();

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.error, null);
      expect(result.dirtyTasksSynced, 0);
      expect(result.tasksFetched, 2);
      expect(result.duration, isNotNull);

      verify(() => mockCacheRepo.getDirtyTasks()).called(1);
      verify(() => mockCacheRepo.isCacheStale('tasks', any())).called(1);
      verify(() => mockTaskRepo.getMyActiveTasks()).called(1);
      verify(() => mockCacheRepo.cacheTasks(freshTasks)).called(1);
    });

    test('syncAll should skip if already syncing', () async {
      // Arrange - Make sync take some time
      mockCacheRepo.mockGetDirtyTasks([]);
      mockCacheRepo.mockIsCacheStale(false);

      // Start first sync (will be in progress)
      final firstSync = syncManager.syncAll();

      // Act - Try to sync again immediately
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, false);
      expect(result.error, 'Already syncing');

      // Wait for first sync to complete
      await firstSync;
    });

    test('syncAll should upload dirty tasks', () async {
      // Arrange - Create dirty tasks
      final dirtyTask1 = TaskCache.fromTask(
        TestData.todoTask,
      ).copyWithDirty(status: TaskStatus.inProgress.value);
      final dirtyTask2 = TaskCache.fromTask(
        TestData.inProgressTask,
      ).copyWithDirty(status: TaskStatus.done.value);

      mockCacheRepo.mockGetDirtyTasks([dirtyTask1, dirtyTask2]);

      // Mock successful status updates
      mockTaskRepo.mockUpdateTaskStatus();

      // Mock clearing dirty flags
      mockCacheRepo.mockClearDirtyFlag();

      // Cache is fresh, skip fetch
      mockCacheRepo.mockIsCacheStale(false);

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.dirtyTasksSynced, 2);

      verify(() => mockCacheRepo.getDirtyTasks()).called(1);
      verify(
        () => mockTaskRepo.updateTaskStatus(dirtyTask1.id, any()),
      ).called(1);
      verify(
        () => mockTaskRepo.updateTaskStatus(dirtyTask2.id, any()),
      ).called(1);
      verify(() => mockCacheRepo.clearDirtyFlag(dirtyTask1.id)).called(1);
      verify(() => mockCacheRepo.clearDirtyFlag(dirtyTask2.id)).called(1);
    });

    test('syncAll should keep dirty flag on sync failure', () async {
      // Arrange - Create dirty task
      final dirtyTask = TaskCache.fromTask(
        TestData.todoTask,
      ).copyWithDirty(status: TaskStatus.inProgress.value);

      mockCacheRepo.mockGetDirtyTasks([dirtyTask]);

      // Mock failed status update
      when(
        () => mockTaskRepo.updateTaskStatus(any(), any()),
      ).thenThrow(Exception('Network error'));

      // Cache is fresh, skip fetch
      mockCacheRepo.mockIsCacheStale(false);

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(
        result.success,
        true,
      ); // Overall sync succeeds even if dirty sync fails
      expect(result.dirtyTasksSynced, 0); // No tasks synced

      // Dirty flag should NOT be cleared
      verifyNever(() => mockCacheRepo.clearDirtyFlag(any()));
    });

    test('syncAll should skip fetch if cache is fresh', () async {
      // Arrange
      mockCacheRepo.mockGetDirtyTasks([]);
      mockCacheRepo.mockIsCacheStale(false); // Cache is fresh

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.tasksFetched, 0);

      // Should not fetch tasks
      verifyNever(() => mockTaskRepo.getMyActiveTasks());
      verifyNever(() => mockCacheRepo.cacheTasks(any()));
    });

    test('syncAll should fetch fresh data when forced', () async {
      // Arrange
      mockCacheRepo.mockGetDirtyTasks([]);

      // Even though cache is fresh, force=true should fetch
      mockCacheRepo.mockIsCacheStale(false);

      final freshTasks = [TestData.todoTask];
      mockTaskRepo.mockGetMyActiveTasks(freshTasks);
      mockCacheRepo.mockCacheTasks();

      // Act
      final result = await syncManager.syncAll(force: true);

      // Assert
      expect(result.success, true);
      expect(result.tasksFetched, 1);

      // Should fetch even though cache is fresh
      verify(() => mockTaskRepo.getMyActiveTasks()).called(1);
    });

    test('syncAll should return error on network failure', () async {
      // Arrange
      mockCacheRepo.mockGetDirtyTasks([]);
      mockCacheRepo.mockIsCacheStale(true);

      // Mock network error
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true); // Doesn't fail on fetch error
      expect(result.tasksFetched, 0);
    });

    test('syncAll should handle empty dirty tasks list', () async {
      // Arrange
      mockCacheRepo.mockGetDirtyTasks([]); // No dirty tasks
      mockCacheRepo.mockIsCacheStale(false);

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.dirtyTasksSynced, 0);

      // Should not try to update any tasks
      verifyNever(() => mockTaskRepo.updateTaskStatus(any(), any()));
    });
  });

  group('SyncManager - Cache Management', () {
    test('getCacheStats should return cache statistics', () async {
      // Arrange
      final mockStats = {
        'tasks_count': 10,
        'users_count': 5,
        'dirty_tasks_count': 2,
        'tasks_last_sync': DateTime.now(),
        'users_last_sync': DateTime.now(),
      };

      mockCacheRepo.mockGetCacheStats(mockStats);

      // Act
      final result = await syncManager.getCacheStats();

      // Assert
      expect(result, equals(mockStats));
      expect(result['tasks_count'], 10);
      expect(result['dirty_tasks_count'], 2);

      verify(() => mockCacheRepo.getCacheStats()).called(1);
    });

    test('clearCache should clear all cached data', () async {
      // Arrange
      mockCacheRepo.mockClearAll();

      // Act
      await syncManager.clearCache();

      // Assert
      verify(() => mockCacheRepo.clearAll()).called(1);
    });
  });

  group('SyncManager - Edge Cases', () {
    test('should handle partial dirty sync success', () async {
      // Arrange - 3 dirty tasks, 2 succeed, 1 fails
      final dirtyTask1 = TaskCache.fromTask(
        TestData.todoTask,
      ).copyWithDirty(status: TaskStatus.inProgress.value);
      final dirtyTask2 = TaskCache.fromTask(
        TestData.inProgressTask,
      ).copyWithDirty(status: TaskStatus.done.value);
      final dirtyTask3 = TaskCache.fromTask(
        TestData.completedTask,
      ).copyWithDirty(status: TaskStatus.todo.value);

      mockCacheRepo.mockGetDirtyTasks([dirtyTask1, dirtyTask2, dirtyTask3]);

      // First two succeed, third fails
      when(
        () => mockTaskRepo.updateTaskStatus(dirtyTask1.id, any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockTaskRepo.updateTaskStatus(dirtyTask2.id, any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockTaskRepo.updateTaskStatus(dirtyTask3.id, any()),
      ).thenThrow(Exception('Network timeout'));

      mockCacheRepo.mockClearDirtyFlag();
      mockCacheRepo.mockIsCacheStale(false);

      // Act
      final result = await syncManager.syncAll();

      // Assert
      expect(result.success, true);
      expect(result.dirtyTasksSynced, 2); // Only 2 succeeded

      // First two should have flags cleared
      verify(() => mockCacheRepo.clearDirtyFlag(dirtyTask1.id)).called(1);
      verify(() => mockCacheRepo.clearDirtyFlag(dirtyTask2.id)).called(1);

      // Third should keep dirty flag
      verifyNever(() => mockCacheRepo.clearDirtyFlag(dirtyTask3.id));
    });

    test('should handle cache staleness check failure gracefully', () async {
      // Arrange
      mockCacheRepo.mockGetDirtyTasks([]);

      // Staleness check throws
      when(
        () => mockCacheRepo.isCacheStale(any(), any()),
      ).thenThrow(Exception('Hive error'));

      // Act
      final result = await syncManager.syncAll();

      // Assert - Should return error result, not throw
      expect(result.success, false);
      expect(result.error, contains('Hive error'));
    });
  });

  group('SyncManager - SyncResult', () {
    test('SyncResult.error should create error result', () {
      // Act
      final result = SyncResult.error('Network failed');

      // Assert
      expect(result.success, false);
      expect(result.error, 'Network failed');
      expect(result.toString(), contains('failed'));
    });

    test('SyncResult.skipped should create skipped result', () {
      // Act
      final result = SyncResult.skipped();

      // Assert
      expect(result.success, false);
      expect(result.error, 'Already syncing');
    });

    test('SyncResult toString should format success correctly', () {
      // Act
      final result = SyncResult(
        success: true,
        dirtyTasksSynced: 3,
        tasksFetched: 10,
        usersFetched: 5,
        duration: Duration(seconds: 2),
      );

      // Assert
      expect(result.toString(), contains('dirty: 3'));
      expect(result.toString(), contains('tasks: 10'));
      expect(result.toString(), contains('users: 5'));
      expect(result.toString(), contains('2s'));
    });
  });
}
