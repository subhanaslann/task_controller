import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/data/models/organization_stats.dart';
import 'package:flutter_app/data/repositories/organization_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockApiService extends Mock implements ApiService {}

class FakeUpdateOrganizationRequest extends Fake implements UpdateOrganizationRequest {}

void main() {
  late OrganizationRepository repository;
  late MockApiService mockApiService;

  setUpAll(() {
    registerFallbackValue(FakeUpdateOrganizationRequest());
  });

  setUp(() {
    mockApiService = MockApiService();
    repository = OrganizationRepository(mockApiService);
  });

  group('OrganizationRepository - Get Organization', () {
    test('getOrganization should return organization from JWT token', () async {
      // Arrange
      final testOrg = TestData.testOrganization;
      final mockResponse = OrganizationResponse(organization: testOrg);
      
      when(() => mockApiService.getOrganization())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getOrganization();

      // Assert
      expect(result.id, testOrg.id);
      expect(result.name, testOrg.name);
      expect(result.teamName, testOrg.teamName);
      expect(result.slug, testOrg.slug);
      expect(result.isActive, testOrg.isActive);
      expect(result.maxUsers, testOrg.maxUsers);
      verify(() => mockApiService.getOrganization()).called(1);
    });

    test('getOrganization should throw on unauthorized', () async {
      // Arrange
      when(() => mockApiService.getOrganization())
          .thenThrow(Exception('Unauthorized'));

      // Act & Assert
      expect(() => repository.getOrganization(), throwsException);
    });

    test('getOrganization should throw on inactive organization', () async {
      // Arrange
      when(() => mockApiService.getOrganization())
          .thenThrow(Exception('Organization is inactive'));

      // Act & Assert
      expect(() => repository.getOrganization(), throwsException);
    });

    test('getOrganization should throw on network error', () async {
      // Arrange
      when(() => mockApiService.getOrganization())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => repository.getOrganization(), throwsException);
    });
  });

  group('OrganizationRepository - Update Organization', () {
    test('updateOrganization should update name only', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(
        name: 'Updated Company Name',
      );
      final mockResponse = OrganizationResponse(organization: updatedOrg);
      
      when(() => mockApiService.updateOrganization(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.updateOrganization(
        name: 'Updated Company Name',
      );

      // Assert
      expect(result.name, 'Updated Company Name');
      verify(() => mockApiService.updateOrganization(any())).called(1);
    });

    test('updateOrganization should update team name only', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(
        teamName: 'Updated Team Name',
      );
      final mockResponse = OrganizationResponse(organization: updatedOrg);
      
      when(() => mockApiService.updateOrganization(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.updateOrganization(
        teamName: 'Updated Team Name',
      );

      // Assert
      expect(result.teamName, 'Updated Team Name');
      verify(() => mockApiService.updateOrganization(any())).called(1);
    });

    test('updateOrganization should update maxUsers (admin only)', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(
        maxUsers: 20,
      );
      final mockResponse = OrganizationResponse(organization: updatedOrg);
      
      when(() => mockApiService.updateOrganization(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.updateOrganization(
        maxUsers: 20,
      );

      // Assert
      expect(result.maxUsers, 20);
      verify(() => mockApiService.updateOrganization(any())).called(1);
    });

    test('updateOrganization should update multiple fields', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(
        name: 'New Company',
        teamName: 'New Team',
        maxUsers: 25,
      );
      final mockResponse = OrganizationResponse(organization: updatedOrg);
      
      when(() => mockApiService.updateOrganization(any()))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.updateOrganization(
        name: 'New Company',
        teamName: 'New Team',
        maxUsers: 25,
      );

      // Assert
      expect(result.name, 'New Company');
      expect(result.teamName, 'New Team');
      expect(result.maxUsers, 25);
    });

    test('updateOrganization should throw on forbidden (member trying to update)', () async {
      // Arrange
      when(() => mockApiService.updateOrganization(any()))
          .thenThrow(Exception('Forbidden'));

      // Act & Assert
      expect(
        () => repository.updateOrganization(name: 'New Name'),
        throwsException,
      );
    });

    test('updateOrganization should throw on validation error', () async {
      // Arrange
      when(() => mockApiService.updateOrganization(any()))
          .thenThrow(Exception('Validation error'));

      // Act & Assert
      expect(
        () => repository.updateOrganization(maxUsers: -1), // Invalid value
        throwsException,
      );
    });
  });

  group('OrganizationRepository - Get Statistics', () {
    test('getOrganizationStats should return all statistics', () async {
      // Arrange
      final testStats = TestData.createTestOrgStats(
        userCount: 10,
        activeUserCount: 8,
        taskCount: 50,
        activeTaskCount: 30,
        completedTaskCount: 20,
        topicCount: 5,
        activeTopicCount: 4,
      );
      final mockResponse = OrganizationStatsResponse(stats: testStats);
      
      when(() => mockApiService.getOrganizationStats())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getOrganizationStats();

      // Assert
      expect(result.userCount, 10);
      expect(result.activeUserCount, 8);
      expect(result.taskCount, 50);
      expect(result.activeTaskCount, 30);
      expect(result.completedTaskCount, 20);
      expect(result.topicCount, 5);
      expect(result.activeTopicCount, 4);
      verify(() => mockApiService.getOrganizationStats()).called(1);
    });

    test('getOrganizationStats should validate logical relationships', () async {
      // Arrange
      final testStats = TestData.createTestOrgStats(
        userCount: 15,
        activeUserCount: 12,
        taskCount: 100,
        activeTaskCount: 60,
        completedTaskCount: 40,
      );
      final mockResponse = OrganizationStatsResponse(stats: testStats);
      
      when(() => mockApiService.getOrganizationStats())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getOrganizationStats();

      // Assert - Logical relationships
      expect(result.userCount >= result.activeUserCount, true);
      expect(result.taskCount >= result.activeTaskCount, true);
      expect(result.taskCount >= result.completedTaskCount, true);
      expect(
        result.taskCount >= result.activeTaskCount + result.completedTaskCount,
        true,
      );
    });

    test('getOrganizationStats should handle zero counts', () async {
      // Arrange
      final testStats = TestData.createTestOrgStats(
        userCount: 1,
        activeUserCount: 1,
        taskCount: 0,
        activeTaskCount: 0,
        completedTaskCount: 0,
        topicCount: 0,
        activeTopicCount: 0,
      );
      final mockResponse = OrganizationStatsResponse(stats: testStats);
      
      when(() => mockApiService.getOrganizationStats())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getOrganizationStats();

      // Assert
      expect(result.taskCount, 0);
      expect(result.topicCount, 0);
      expect(result.userCount, 1); // At least one user (the logged-in user)
    });

    test('getOrganizationStats should throw on unauthorized', () async {
      // Arrange
      when(() => mockApiService.getOrganizationStats())
          .thenThrow(Exception('Unauthorized'));

      // Act & Assert
      expect(() => repository.getOrganizationStats(), throwsException);
    });

    test('getOrganizationStats should throw on network error', () async {
      // Arrange
      when(() => mockApiService.getOrganizationStats())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => repository.getOrganizationStats(), throwsException);
    });
  });
}

