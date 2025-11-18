import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/cache/cache_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('TaskCache', () {
    test('fromTask should convert Task to TaskCache', () {
      // Arrange
      final task = TestData.todoTask;

      // Act
      final cached = TaskCache.fromTask(task);

      // Assert
      expect(cached.id, task.id);
      expect(cached.title, task.title);
      expect(cached.status, task.status.value);
      expect(cached.priority, task.priority.value);
      expect(cached.isDirty, false);
      expect(cached.cachedAt, isNotNull);
    });

    test('toTask should convert TaskCache to Task', () {
      // Arrange
      final task = TestData.todoTask;
      final cached = TaskCache.fromTask(task);

      // Act
      final converted = cached.toTask();

      // Assert
      expect(converted.id, task.id);
      expect(converted.title, task.title);
      expect(converted.status, task.status);
      expect(converted.priority, task.priority);
    });

    test('copyWithDirty should create dirty copy with updated fields', () {
      // Arrange
      final task = TestData.todoTask;
      final cached = TaskCache.fromTask(task);

      // Act
      final dirty = cached.copyWithDirty(
        status: TaskStatus.inProgress.value,
        title: 'Updated title',
      );

      // Assert
      expect(dirty.isDirty, true);
      expect(dirty.status, TaskStatus.inProgress.value);
      expect(dirty.title, 'Updated title');
      expect(dirty.id, cached.id); // ID unchanged
    });

    test('copyWithDirty should preserve original values when not specified', () {
      // Arrange
      final task = TestData.todoTask;
      final cached = TaskCache.fromTask(task);

      // Act
      final dirty = cached.copyWithDirty(status: TaskStatus.done.value);

      // Assert
      expect(dirty.title, cached.title); // Title unchanged
      expect(dirty.priority, cached.priority); // Priority unchanged
      expect(dirty.status, TaskStatus.done.value); // Status changed
    });

    test('toJson and fromJson should serialize correctly', () {
      // Arrange
      final task = TestData.todoTask;
      final cached = TaskCache.fromTask(task);

      // Act
      final json = cached.toJson();
      final deserialized = TaskCache.fromJson(json);

      // Assert
      expect(deserialized.id, cached.id);
      expect(deserialized.title, cached.title);
      expect(deserialized.status, cached.status);
      expect(deserialized.isDirty, cached.isDirty);
    });

    test('should handle null optional fields', () {
      // Arrange
      final taskCache = TaskCache(
        id: 'test-1',
        title: 'Test task',
        status: TaskStatus.todo.value,
        priority: Priority.normal.value,
        cachedAt: DateTime.now(),
        note: null,
        topicId: null,
        assigneeId: null,
      );

      // Act
      final task = taskCache.toTask();

      // Assert
      expect(task.note, null);
      expect(task.topicId, null);
      expect(task.assigneeId, null);
    });
  });

  group('UserCache', () {
    test('fromUser should convert User to UserCache', () {
      // Arrange
      final user = TestData.adminUser;

      // Act
      final cached = UserCache.fromUser(user);

      // Assert
      expect(cached.id, user.id);
      expect(cached.name, user.name);
      expect(cached.email, user.email);
      expect(cached.role, user.role.value);
      expect(cached.cachedAt, isNotNull);
    });

    test('toUser should convert UserCache to User', () {
      // Arrange
      final user = TestData.adminUser;
      final cached = UserCache.fromUser(user);

      // Act
      final converted = cached.toUser();

      // Assert
      expect(converted.id, user.id);
      expect(converted.name, user.name);
      expect(converted.email, user.email);
      expect(converted.role, user.role);
    });

    test('toJson and fromJson should serialize correctly', () {
      // Arrange
      final user = TestData.adminUser;
      final cached = UserCache.fromUser(user);

      // Act
      final json = cached.toJson();
      final deserialized = UserCache.fromJson(json);

      // Assert
      expect(deserialized.id, cached.id);
      expect(deserialized.name, cached.name);
      expect(deserialized.email, cached.email);
      expect(deserialized.role, cached.role);
    });
  });

  group('SyncMetadata', () {
    test('should create SyncMetadata correctly', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final metadata = SyncMetadata(
        key: 'tasks',
        lastSyncAt: now,
        itemCount: 10,
      );

      // Assert
      expect(metadata.key, 'tasks');
      expect(metadata.lastSyncAt, now);
      expect(metadata.itemCount, 10);
    });

    test('toJson and fromJson should serialize correctly', () {
      // Arrange
      final now = DateTime.now();
      final metadata = SyncMetadata(
        key: 'tasks',
        lastSyncAt: now,
        itemCount: 10,
      );

      // Act
      final json = metadata.toJson();
      final deserialized = SyncMetadata.fromJson(json);

      // Assert
      expect(deserialized.key, metadata.key);
      expect(deserialized.itemCount, metadata.itemCount);
      expect(
        deserialized.lastSyncAt.millisecondsSinceEpoch,
        metadata.lastSyncAt.millisecondsSinceEpoch,
      );
    });
  });
}
