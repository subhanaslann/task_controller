import 'package:flutter_app/data/models/organization_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrganizationStats', () {
    test('should create OrganizationStats from JSON', () {
      // Arrange
      final json = {
        'userCount': 10,
        'activeUserCount': 8,
        'taskCount': 50,
        'activeTaskCount': 30,
        'completedTaskCount': 20,
        'topicCount': 5,
        'activeTopicCount': 4,
      };

      // Act
      final stats = OrganizationStats.fromJson(json);

      // Assert
      expect(stats.userCount, 10);
      expect(stats.activeUserCount, 8);
      expect(stats.taskCount, 50);
      expect(stats.activeTaskCount, 30);
      expect(stats.completedTaskCount, 20);
      expect(stats.topicCount, 5);
      expect(stats.activeTopicCount, 4);
    });

    test('should convert OrganizationStats to JSON', () {
      // Arrange
      final stats = OrganizationStats(
        userCount: 10,
        activeUserCount: 8,
        taskCount: 50,
        activeTaskCount: 30,
        completedTaskCount: 20,
        topicCount: 5,
        activeTopicCount: 4,
      );

      // Act
      final json = stats.toJson();

      // Assert
      expect(json['userCount'], 10);
      expect(json['activeUserCount'], 8);
      expect(json['taskCount'], 50);
      expect(json['activeTaskCount'], 30);
      expect(json['completedTaskCount'], 20);
      expect(json['topicCount'], 5);
      expect(json['activeTopicCount'], 4);
    });

    test('should handle zero values', () {
      // Arrange
      final stats = OrganizationStats(
        userCount: 0,
        activeUserCount: 0,
        taskCount: 0,
        activeTaskCount: 0,
        completedTaskCount: 0,
        topicCount: 0,
        activeTopicCount: 0,
      );

      // Act & Assert
      expect(stats.userCount, 0);
      expect(stats.activeUserCount, 0);
      expect(stats.taskCount, 0);
    });
  });
}
