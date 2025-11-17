import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task Model - JSON Serialization', () {
    test('fromJson should correctly parse complete task JSON', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'organizationId': 'org-456',
        'topicId': 'topic-789',
        'title': 'Complete feature',
        'note': 'Detailed description',
        'assigneeId': 'user-001',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'dueDate': '2025-12-31T23:59:59.000Z',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'completedAt': null,
        'topic': {
          'id': 'topic-789',
          'title': 'Backend Development',
        },
        'assignee': {
          'id': 'user-001',
          'name': 'John Doe',
          'username': 'johndoe',
        },
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, 'task-123');
      expect(task.topicId, 'topic-789');
      expect(task.title, 'Complete feature');
      expect(task.note, 'Detailed description');
      expect(task.assigneeId, 'user-001');
      expect(task.status, TaskStatus.inProgress);
      expect(task.priority, Priority.high);
      expect(task.dueDate, '2025-12-31T23:59:59.000Z');
      expect(task.completedAt, null);
      expect(task.topic, isNotNull);
      expect(task.assignee, isNotNull);
    });

    test('fromJson should handle TODO status', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'NORMAL',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.status, TaskStatus.todo);
    });

    test('fromJson should handle DONE status with completedAt', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Completed Task',
        'status': 'DONE',
        'priority': 'NORMAL',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'completedAt': '2025-01-02T12:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.status, TaskStatus.done);
      expect(task.completedAt, isNotNull);
    });

    test('fromJson should handle LOW priority', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Low Priority Task',
        'status': 'TODO',
        'priority': 'LOW',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.priority, Priority.low);
    });

    test('fromJson should handle minimal task (no optional fields)', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Minimal Task',
        'status': 'TODO',
        'priority': 'NORMAL',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, 'task-123');
      expect(task.title, 'Minimal Task');
      expect(task.topicId, null);
      expect(task.note, null);
      expect(task.assigneeId, null);
      expect(task.dueDate, null);
      expect(task.completedAt, null);
      expect(task.topic, null);
      expect(task.assignee, null);
    });

    test('toJson should correctly convert task to JSON', () {
      // Arrange
      final task = Task(
        id: 'task-123',
        organizationId: 'org-456',
        topicId: 'topic-789',
        title: 'Test Task',
        note: 'Test note',
        assigneeId: 'user-001',
        status: TaskStatus.todo,
        priority: Priority.high,
        dueDate: '2025-12-31T23:59:59.000Z',
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = task.toJson();

      // Assert
      expect(json['id'], 'task-123');
      expect(json['title'], 'Test Task');
      expect(json['status'], 'TODO');
      expect(json['priority'], 'HIGH');
    });

    test('toJson should convert status enum to uppercase string', () {
      // Arrange
      final task = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Task',
        status: TaskStatus.inProgress,
        priority: Priority.normal,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = task.toJson();

      // Assert
      expect(json['status'], 'IN_PROGRESS');
    });
  });

  group('Task Model - Guest Filtering', () {
    test('fromJson should preserve all fields for non-guest users', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'organizationId': 'org-456',
        'topicId': 'topic-789',
        'title': 'Task',
        'note': 'Sensitive note',
        'assigneeId': 'user-001',
        'status': 'TODO',
        'priority': 'NORMAL',
        'dueDate': '2025-12-31T23:59:59.000Z',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'assignee': {
          'id': 'user-001',
          'name': 'John Doe',
          'username': 'johndoe',
        },
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.note, isNotNull);
      expect(task.assignee?.username, isNotNull);
    });

    test('fromJson should handle guest-filtered task (no note, no username)', () {
      // Arrange - This is what the API returns for guest users
      final json = {
        'id': 'task-123',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'NORMAL',
        'dueDate': '2025-12-31T23:59:59.000Z',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'assignee': {
          'id': 'user-001',
          'name': 'John Doe',
          // No username for guest users
        },
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.note, null);
      expect(task.assignee?.name, 'John Doe');
    });
  });

  group('Task Model - copyWith', () {
    test('copyWith should update status only', () {
      // Arrange
      final original = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Original Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final updated = original.copyWith(status: TaskStatus.inProgress);

      // Assert
      expect(updated.status, TaskStatus.inProgress);
      expect(updated.title, original.title); // Unchanged
      expect(updated.priority, original.priority); // Unchanged
    });

    test('copyWith should update priority only', () {
      // Arrange
      final original = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final updated = original.copyWith(priority: Priority.high);

      // Assert
      expect(updated.priority, Priority.high);
      expect(updated.status, original.status); // Unchanged
    });

    test('copyWith should update note', () {
      // Arrange
      final original = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        note: 'Old note',
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final updated = original.copyWith(note: 'New note');

      // Assert
      expect(updated.note, 'New note');
    });

    test('copyWith should update dueDate', () {
      // Arrange
      final original = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final updated = original.copyWith(dueDate: '2025-12-31T23:59:59.000Z');

      // Assert
      expect(updated.dueDate, '2025-12-31T23:59:59.000Z');
    });

    test('copyWith should update multiple fields', () {
      // Arrange
      final original = Task(
        id: 'task-123',
        organizationId: 'org-456',
        title: 'Task',
        status: TaskStatus.todo,
        priority: Priority.normal,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final updated = original.copyWith(
        status: TaskStatus.done,
        priority: Priority.low,
        note: 'Completed',
      );

      // Assert
      expect(updated.status, TaskStatus.done);
      expect(updated.priority, Priority.low);
      expect(updated.note, 'Completed');
    });
  });

  group('Task Model - Date Handling', () {
    test('should parse ISO 8601 date strings', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'NORMAL',
        'dueDate': '2025-12-31T23:59:59.000Z',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T10:30:45.123Z',
        'completedAt': '2025-01-03T15:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.dueDate, contains('2025-12-31'));
      expect(task.createdAt, contains('2025-01-01'));
      expect(task.updatedAt, contains('2025-01-02'));
      expect(task.completedAt, contains('2025-01-03'));
    });

    test('should handle null dates', () {
      // Arrange
      final json = {
        'id': 'task-123',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'NORMAL',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.dueDate, null);
      expect(task.completedAt, null);
    });
  });
}

