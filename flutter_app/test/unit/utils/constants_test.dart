import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/constants.dart';

void main() {
  group('ApiConstants Tests', () {
    test('should have correct base URL', () {
      // Assert - Development URL for Android emulator
      expect(ApiConstants.baseUrl, 'http://10.0.2.2:8080');
    });

    test('should have correct endpoint paths', () {
      // Assert
      expect(ApiConstants.loginEndpoint, '/auth/login');
      expect(ApiConstants.tasksEndpoint, '/tasks');
      expect(ApiConstants.usersEndpoint, '/users');
      expect(ApiConstants.topicsEndpoint, '/topics');
    });
  });

  group('TaskStatus Enum Tests', () {
    test('should have correct values', () {
      // Assert
      expect(TaskStatus.todo.value, 'TODO');
      expect(TaskStatus.inProgress.value, 'IN_PROGRESS');
      expect(TaskStatus.done.value, 'DONE');
    });

    test('should parse from string correctly', () {
      // Act & Assert
      expect(TaskStatus.fromString('TODO'), TaskStatus.todo);
      expect(TaskStatus.fromString('IN_PROGRESS'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('DONE'), TaskStatus.done);
      expect(TaskStatus.fromString('todo'), TaskStatus.todo); // lowercase
    });

    test('should return default value for invalid string', () {
      // Act & Assert
      expect(TaskStatus.fromString('INVALID'), TaskStatus.todo);
    });
  });

  group('Priority Enum Tests', () {
    test('should have correct values', () {
      // Assert
      expect(Priority.low.value, 'LOW');
      expect(Priority.normal.value, 'NORMAL');
      expect(Priority.high.value, 'HIGH');
    });

    test('should parse from string correctly', () {
      // Act & Assert
      expect(Priority.fromString('LOW'), Priority.low);
      expect(Priority.fromString('NORMAL'), Priority.normal);
      expect(Priority.fromString('HIGH'), Priority.high);
      expect(Priority.fromString('low'), Priority.low); // lowercase
    });

    test('should return default value for invalid string', () {
      // Act & Assert
      expect(Priority.fromString('INVALID'), Priority.normal);
    });
  });

  group('UserRole Enum Tests', () {
    test('should have all required roles', () {
      // Assert
      expect(UserRole.admin.value, 'ADMIN');
      expect(UserRole.teamManager.value, 'TEAM_MANAGER');
      expect(UserRole.member.value, 'MEMBER');
      expect(UserRole.guest.value, 'GUEST');
    });
  });
}
