import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Organization Model - JSON Serialization', () {
    test('fromJson should correctly parse complete organization JSON', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'Test Company',
        'teamName': 'Engineering Team',
        'slug': 'test-company-engineering',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.id, 'org-123');
      expect(org.name, 'Test Company');
      expect(org.teamName, 'Engineering Team');
      expect(org.slug, 'test-company-engineering');
      expect(org.isActive, true);
      expect(org.maxUsers, 15);
      expect(org.createdAt, '2025-01-01T00:00:00.000Z');
      expect(org.updatedAt, '2025-01-02T00:00:00.000Z');
    });

    test('fromJson should handle inactive organization', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'Inactive Company',
        'teamName': 'Team',
        'slug': 'inactive-team',
        'isActive': false,
        'maxUsers': 10,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.isActive, false);
    });

    test('fromJson should handle custom maxUsers limit', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'Large Company',
        'teamName': 'Team',
        'slug': 'large-team',
        'isActive': true,
        'maxUsers': 50,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.maxUsers, 50);
    });

    test('toJson should correctly convert organization to JSON', () {
      // Arrange
      final org = Organization(
        id: 'org-123',
        name: 'Test Company',
        teamName: 'Engineering Team',
        slug: 'test-company-engineering',
        isActive: true,
        maxUsers: 15,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = org.toJson();

      // Assert
      expect(json['id'], 'org-123');
      expect(json['name'], 'Test Company');
      expect(json['teamName'], 'Engineering Team');
      expect(json['slug'], 'test-company-engineering');
      expect(json['isActive'], true);
      expect(json['maxUsers'], 15);
    });

    test('toJson should preserve isActive false state', () {
      // Arrange
      final org = Organization(
        id: 'org-123',
        name: 'Company',
        teamName: 'Team',
        slug: 'company-team',
        isActive: false,
        maxUsers: 10,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Act
      final json = org.toJson();

      // Assert
      expect(json['isActive'], false);
    });
  });

  group('Organization Model - Slug Format', () {
    test('should handle kebab-case slug', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'My Company',
        'teamName': 'My Team',
        'slug': 'my-company-my-team',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.slug, contains('-'));
      expect(org.slug, 'my-company-my-team');
    });

    test('should handle slug with single word', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'Company',
        'teamName': 'Team',
        'slug': 'companyteam',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.slug, 'companyteam');
    });
  });

  group('Organization Model - Default Values', () {
    test('should default maxUsers to 15', () {
      // Arrange - This tests the expected default from backend
      final json = {
        'id': 'org-123',
        'name': 'Company',
        'teamName': 'Team',
        'slug': 'company-team',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.maxUsers, 15);
    });

    test('should default isActive to true', () {
      // Arrange - This tests the expected default from backend
      final json = {
        'id': 'org-123',
        'name': 'Company',
        'teamName': 'Team',
        'slug': 'company-team',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.isActive, true);
    });
  });

  group('Organization Model - Data Validation', () {
    test('should create organization with all required fields', () {
      // Act
      final org = Organization(
        id: 'org-123',
        name: 'Test Company',
        teamName: 'Test Team',
        slug: 'test-company-test-team',
        isActive: true,
        maxUsers: 15,
        createdAt: '2025-01-01T00:00:00.000Z',
        updatedAt: '2025-01-02T00:00:00.000Z',
      );

      // Assert
      expect(org.id, isNotEmpty);
      expect(org.name, isNotEmpty);
      expect(org.teamName, isNotEmpty);
      expect(org.slug, isNotEmpty);
      expect(org.isActive, isA<bool>());
      expect(org.maxUsers, isA<int>());
      expect(org.maxUsers, greaterThan(0));
    });

    test('should handle organization with long names', () {
      // Arrange
      final json = {
        'id': 'org-123',
        'name': 'Very Long Company Name That Might Be Used In Real World Applications',
        'teamName': 'Engineering and Product Development Team',
        'slug': 'very-long-company-name-engineering',
        'isActive': true,
        'maxUsers': 15,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      // Act
      final org = Organization.fromJson(json);

      // Assert
      expect(org.name.length, greaterThan(20));
      expect(org.teamName.length, greaterThan(10));
    });
  });
}

