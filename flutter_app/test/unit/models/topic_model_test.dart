import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Topic Model - JSON Serialization', () {
    test('fromJson should correctly parse complete topic JSON', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Backend Development',
        'description': 'API and database tasks',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, 'topic-123');
      expect(topic.organizationId, 'org-456');
      expect(topic.title, 'Backend Development');
      expect(topic.description, 'API and database tasks');
      expect(topic.isActive, true);
      expect(topic.createdAt, '2025-01-01T00:00:00.000Z');
      expect(topic.updatedAt, '2025-01-02T00:00:00.000Z');
    });

    test('fromJson should handle topic without description', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'General Tasks',
        'description': null,
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.description, null);
    });

    test('fromJson should handle inactive topic', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Archived Topic',
        'description': 'Old tasks',
        'isActive': false,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.isActive, false);
    });

    test('fromJson should handle topic with tasks array', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic with Tasks',
        'description': 'Description',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'tasks': [
          {
            'id': 'task-1',
            'title': 'Task 1',
            'status': 'TODO',
            'priority': 'HIGH',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
          },
          {
            'id': 'task-2',
            'title': 'Task 2',
            'status': 'IN_PROGRESS',
            'priority': 'NORMAL',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
          },
        ],
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.tasks, isNotNull);
      expect(topic.tasks!.length, 2);
      expect(topic.tasks![0].title, 'Task 1');
      expect(topic.tasks![1].title, 'Task 2');
    });

    test('fromJson should handle topic with _count', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'description': 'Description',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        '_count': {
          'tasks': 5,
        },
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.count, isNotNull);
      expect(topic.count?.tasks, 5);
    });

    test('toJson should correctly convert topic to JSON', () {
      // Arrange
      final topic = Topic(
        id: 'topic-123',
        organizationId: 'org-456',
        title: 'Backend Development',
        description: 'API tasks',
        isActive: true,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = topic.toJson();

      // Assert
      expect(json['id'], 'topic-123');
      expect(json['organizationId'], 'org-456');
      expect(json['title'], 'Backend Development');
      expect(json['description'], 'API tasks');
      expect(json['isActive'], true);
    });

    test('toJson should handle null description', () {
      // Arrange
      final topic = Topic(
        id: 'topic-123',
        organizationId: 'org-456',
        title: 'Topic',
        description: null,
        isActive: true,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = topic.toJson();

      // Assert
      expect(json['description'], null);
    });
  });

  group('Topic Model - Tasks Array Handling', () {
    test('should handle empty tasks array', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Empty Topic',
        'description': 'No tasks yet',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'tasks': [],
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.tasks, isEmpty);
    });

    test('should handle null tasks array', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'description': 'Description',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.tasks, null);
    });

    test('should parse tasks with different statuses', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'tasks': [
          {
            'id': 'task-1',
            'title': 'Todo Task',
            'status': 'TODO',
            'priority': 'HIGH',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
          },
          {
            'id': 'task-2',
            'title': 'In Progress Task',
            'status': 'IN_PROGRESS',
            'priority': 'NORMAL',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
          },
          {
            'id': 'task-3',
            'title': 'Done Task',
            'status': 'DONE',
            'priority': 'LOW',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
            'completedAt': '2025-01-03T00:00:00.000Z',
          },
        ],
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.tasks!.length, 3);
      expect(topic.tasks![0].status, TaskStatus.todo);
      expect(topic.tasks![1].status, TaskStatus.inProgress);
      expect(topic.tasks![2].status, TaskStatus.done);
      expect(topic.tasks![2].completedAt, isNotNull);
    });
  });

  group('Topic Model - Count Field', () {
    test('should parse _count with tasks number', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        '_count': {
          'tasks': 10,
        },
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.count?.tasks, 10);
    });

    test('should handle _count with zero tasks', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        '_count': {
          'tasks': 0,
        },
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.count?.tasks, 0);
    });

    test('should handle missing _count field', () {
      // Arrange
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.count, null);
    });
  });

  group('Topic Model - Data Validation', () {
    test('should create topic with all required fields', () {
      // Act
      final topic = Topic(
        id: 'topic-123',
        organizationId: 'org-456',
        title: 'Test Topic',
        description: 'Test description',
        isActive: true,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Assert
      expect(topic.id, isNotEmpty);
      expect(topic.organizationId, isNotEmpty);
      expect(topic.title, isNotEmpty);
      expect(topic.isActive, isA<bool>());
    });

    test('should handle topic with long description', () {
      // Arrange
      final longDescription = 'A' * 500; // 500 characters
      final json = {
        'id': 'topic-123',
        'organizationId': 'org-456',
        'title': 'Topic',
        'description': longDescription,
        'isActive': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.description, longDescription);
      expect(topic.description!.length, 500);
    });
  });
}

