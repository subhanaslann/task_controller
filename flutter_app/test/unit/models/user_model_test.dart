import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model - JSON Serialization', () {
    test('fromJson should correctly parse valid JSON', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'John Doe',
        'username': 'johndoe',
        'email': 'john@test.com',
        'role': 'MEMBER',
        'active': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'visibleTopicIds': ['topic-1', 'topic-2'],
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, 'user-123');
      expect(user.organizationId, 'org-456');
      expect(user.name, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.email, 'john@test.com');
      expect(user.role, UserRole.member);
      expect(user.active, true);
      expect(user.visibleTopicIds, ['topic-1', 'topic-2']);
    });

    test('fromJson should handle ADMIN role', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'Admin User',
        'username': 'admin',
        'email': 'admin@test.com',
        'role': 'ADMIN',
        'active': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.role, UserRole.admin);
    });

    test('fromJson should handle TEAM_MANAGER role', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'Manager',
        'username': 'manager',
        'email': 'manager@test.com',
        'role': 'TEAM_MANAGER',
        'active': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.role, UserRole.teamManager);
    });

    test('fromJson should handle GUEST role', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'Guest User',
        'username': 'guest',
        'email': 'guest@test.com',
        'role': 'GUEST',
        'active': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'visibleTopicIds': ['topic-1'],
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.role, UserRole.guest);
      expect(user.visibleTopicIds.length, 1);
    });

    test('fromJson should use default empty list for visibleTopicIds if missing', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'User',
        'username': 'user',
        'email': 'user@test.com',
        'role': 'MEMBER',
        'active': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.visibleTopicIds, isEmpty);
    });

    test('toJson should correctly convert user to JSON', () {
      // Arrange
      final user = User(
        id: 'user-123',
        organizationId: 'org-456',
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@test.com',
        role: UserRole.member,
        active: true,
        visibleTopicIds: ['topic-1'],
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 'user-123');
      expect(json['organizationId'], 'org-456');
      expect(json['name'], 'John Doe');
      expect(json['username'], 'johndoe');
      expect(json['email'], 'john@test.com');
      expect(json['role'], 'MEMBER');
      expect(json['active'], true);
      expect(json['visibleTopicIds'], ['topic-1']);
    });

    test('toJson should convert role enum to uppercase string', () {
      // Arrange
      final adminUser = User(
        id: 'user-123',
        organizationId: 'org-456',
        name: 'Admin',
        username: 'admin',
        email: 'admin@test.com',
        role: UserRole.admin,
        active: true,
      );

      // Act
      final json = adminUser.toJson();

      // Assert
      expect(json['role'], 'ADMIN');
    });

    test('fromJson should handle inactive user', () {
      // Arrange
      final json = {
        'id': 'user-123',
        'organizationId': 'org-456',
        'name': 'Inactive User',
        'username': 'inactive',
        'email': 'inactive@test.com',
        'role': 'MEMBER',
        'active': false,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.active, false);
    });
  });

  group('User Model - Data Validation', () {
    test('should create user with all required fields', () {
      // Act
      final user = User(
        id: 'user-123',
        organizationId: 'org-456',
        name: 'Test User',
        username: 'testuser',
        email: 'test@test.com',
        role: UserRole.member,
        active: true,
      );

      // Assert
      expect(user.id, isNotEmpty);
      expect(user.organizationId, isNotEmpty);
      expect(user.name, isNotEmpty);
      expect(user.username, isNotEmpty);
      expect(user.email, isNotEmpty);
      expect(user.role, isA<UserRole>());
      expect(user.active, isA<bool>());
    });

    test('should default visibleTopicIds to empty list', () {
      // Act
      final user = User(
        id: 'user-123',
        organizationId: 'org-456',
        name: 'Test User',
        username: 'testuser',
        email: 'test@test.com',
        role: UserRole.member,
        active: true,
      );

      // Assert
      expect(user.visibleTopicIds, isEmpty);
    });

    test('should preserve visibleTopicIds when provided', () {
      // Act
      final user = User(
        id: 'user-123',
        organizationId: 'org-456',
        name: 'Guest User',
        username: 'guest',
        email: 'guest@test.com',
        role: UserRole.guest,
        active: true,
        visibleTopicIds: ['topic-1', 'topic-2', 'topic-3'],
      );

      // Assert
      expect(user.visibleTopicIds.length, 3);
      expect(user.visibleTopicIds, contains('topic-1'));
      expect(user.visibleTopicIds, contains('topic-2'));
      expect(user.visibleTopicIds, contains('topic-3'));
    });
  });
}

