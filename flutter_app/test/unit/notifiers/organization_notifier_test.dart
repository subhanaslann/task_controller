import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_app/features/admin/notifiers/organization_notifier.dart';

import '../../helpers/test_data.dart';
import '../../mocks/mock_organization_repository.dart';

void main() {
  late OrganizationNotifier notifier;
  late MockOrganizationRepository mockRepository;

  setUp(() {
    mockRepository = MockOrganizationRepository();
    notifier = OrganizationNotifier(mockRepository);
  });

  tearDown(() {
    notifier.dispose();
  });

  // ==================== GROUP 1: STATE TESTS ====================
  group('OrganizationState Tests', () {
    test('initial state is correct', () {
      expect(notifier.state.organization, isNull);
      expect(notifier.state.stats, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('copyWith updates organization', () {
      final org = TestData.testOrganization;
      final newState = OrganizationState().copyWith(organization: org);

      expect(newState.organization, equals(org));
      expect(newState.stats, isNull);
      expect(newState.isLoading, false);
      expect(newState.error, isNull);
    });

    test('copyWith updates stats', () {
      final stats = TestData.createTestOrgStats(userCount: 10);
      final newState = OrganizationState().copyWith(stats: stats);

      expect(newState.stats, equals(stats));
      expect(newState.organization, isNull);
    });

    test('copyWith updates isLoading', () {
      final newState = OrganizationState().copyWith(isLoading: true);
      expect(newState.isLoading, true);
    });

    test('copyWith updates error', () {
      final newState = OrganizationState().copyWith(error: 'Test error');
      expect(newState.error, 'Test error');
    });

    test('copyWith can set error to null explicitly', () {
      final originalState = OrganizationState(error: 'Old error');
      final newState = originalState.copyWith(error: null);
      expect(newState.error, isNull);
    });

    test('copyWith preserves unmodified values', () {
      final org = TestData.testOrganization;
      final stats = TestData.createTestOrgStats();
      final originalState = OrganizationState(
        organization: org,
        stats: stats,
        isLoading: true,
        error: 'Some error',
      );

      final newState = originalState.copyWith(isLoading: false);

      expect(newState.organization, equals(org));
      expect(newState.stats, equals(stats));
      expect(newState.isLoading, false);
      expect(newState.error, 'Some error');
    });
  });

  // ==================== GROUP 2: FETCHORGANIZATION TESTS ====================
  group('fetchOrganization Tests', () {
    test('fetchOrganization sets loading to true initially', () async {
      // Arrange - Add delay to mock so we can check loading state
      when(() => mockRepository.getOrganization()).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return TestData.testOrganization;
        },
      );

      // Act
      final future = notifier.fetchOrganization();
      await Future.delayed(Duration.zero); // Let state update

      // Assert - should be loading
      expect(notifier.state.isLoading, true);
      expect(notifier.state.error, isNull);

      await future;
    });

    test('fetchOrganization fetches and updates state successfully', () async {
      // Arrange
      final testOrg = TestData.createTestOrganization(
        name: 'TekTech',
        teamName: 'Engineering',
      );
      mockRepository.mockGetOrganization(testOrg);

      // Act
      await notifier.fetchOrganization();

      // Assert
      expect(notifier.state.organization, equals(testOrg));
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);

      verify(() => mockRepository.getOrganization()).called(1);
    });

    test('fetchOrganization handles error correctly', () async {
      // Arrange
      mockRepository.mockGetOrganizationError(Exception('Network error'));

      // Act
      await notifier.fetchOrganization();

      // Assert
      expect(notifier.state.organization, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Failed to load organization'));
      expect(notifier.state.error, contains('Network error'));
    });

    test('fetchOrganization clears previous error on success', () async {
      // Arrange - Start with an error state
      mockRepository.mockGetOrganizationError(Exception('Old error'));
      await notifier.fetchOrganization();
      expect(notifier.state.error, isNotNull);

      // Act - Succeed on retry
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();

      // Assert
      expect(notifier.state.error, isNull);
      expect(notifier.state.organization, isNotNull);
    });

    test('fetchOrganization preserves stats on fetch', () async {
      // Arrange - Set stats first
      final stats = TestData.createTestOrgStats(userCount: 5);
      mockRepository.mockGetOrganizationStats(stats);
      await notifier.fetchStats();

      // Act - Fetch organization
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();

      // Assert - Stats should still be there
      expect(notifier.state.stats, equals(stats));
      expect(notifier.state.organization, isNotNull);
    });

    test('fetchOrganization can be called multiple times', () async {
      // Arrange
      mockRepository.mockGetOrganization(TestData.testOrganization);

      // Act
      await notifier.fetchOrganization();
      await notifier.fetchOrganization();
      await notifier.fetchOrganization();

      // Assert
      verify(() => mockRepository.getOrganization()).called(3);
      expect(notifier.state.organization, isNotNull);
    });

    test('fetchOrganization sets loading to false even on error', () async {
      // Arrange
      mockRepository.mockGetOrganizationError(Exception('Error'));

      // Act
      await notifier.fetchOrganization();

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
    });
  });

  // ==================== GROUP 3: FETCHSTATS TESTS ====================
  group('fetchStats Tests', () {
    test('fetchStats fetches and updates stats successfully', () async {
      // Arrange
      final testStats = TestData.createTestOrgStats(
        userCount: 10,
        taskCount: 50,
        completedTaskCount: 25,
      );
      mockRepository.mockGetOrganizationStats(testStats);

      // Act
      await notifier.fetchStats();

      // Assert
      expect(notifier.state.stats, equals(testStats));
      expect(notifier.state.stats!.userCount, 10);
      expect(notifier.state.stats!.taskCount, 50);
      expect(notifier.state.stats!.completedTaskCount, 25);

      verify(() => mockRepository.getOrganizationStats()).called(1);
    });

    test('fetchStats handles error correctly', () async {
      // Arrange
      mockRepository.mockGetOrganizationStatsError(Exception('Stats error'));

      // Act
      await notifier.fetchStats();

      // Assert
      expect(notifier.state.stats, isNull);
      expect(notifier.state.error, contains('Failed to load statistics'));
      expect(notifier.state.error, contains('Stats error'));
    });

    test('fetchStats does not clear organization on error', () async {
      // Arrange - Set organization first
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();

      // Act - Stats fetch fails
      mockRepository.mockGetOrganizationStatsError(Exception('Stats error'));
      await notifier.fetchStats();

      // Assert - Organization should still be there
      expect(notifier.state.organization, isNotNull);
      expect(notifier.state.error, contains('Failed to load statistics'));
    });

    test('fetchStats can update existing stats', () async {
      // Arrange - Set initial stats
      final initialStats = TestData.createTestOrgStats(userCount: 5);
      mockRepository.mockGetOrganizationStats(initialStats);
      await notifier.fetchStats();
      expect(notifier.state.stats!.userCount, 5);

      // Act - Update with new stats
      final updatedStats = TestData.createTestOrgStats(userCount: 10);
      mockRepository.mockGetOrganizationStats(updatedStats);
      await notifier.fetchStats();

      // Assert
      expect(notifier.state.stats!.userCount, 10);
    });

    test('fetchStats preserves organization data', () async {
      // Arrange - Set organization
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();
      final org = notifier.state.organization;

      // Act - Fetch stats
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());
      await notifier.fetchStats();

      // Assert - Organization unchanged
      expect(notifier.state.organization, equals(org));
    });
  });

  // ==================== GROUP 4: UPDATEORGANIZATION TESTS ====================
  group('updateOrganization Tests', () {
    test('updateOrganization sets loading to true initially', () async {
      // Arrange - Add delay to mock so we can check loading state
      when(() => mockRepository.updateOrganization(
        name: any(named: 'name'),
        teamName: any(named: 'teamName'),
        maxUsers: any(named: 'maxUsers'),
      )).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return TestData.testOrganization;
        },
      );

      // Act
      final future = notifier.updateOrganization(name: 'New Name');
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.isLoading, true);
      expect(notifier.state.error, isNull);

      await future;
    });

    test('updateOrganization updates name successfully', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(name: 'Updated Name');
      mockRepository.mockUpdateOrganization(updatedOrg);

      // Act
      await notifier.updateOrganization(name: 'Updated Name');

      // Assert
      expect(notifier.state.organization, equals(updatedOrg));
      expect(notifier.state.organization!.name, 'Updated Name');
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('updateOrganization updates teamName successfully', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(teamName: 'New Team');
      mockRepository.mockUpdateOrganization(updatedOrg);

      // Act
      await notifier.updateOrganization(teamName: 'New Team');

      // Assert
      expect(notifier.state.organization!.teamName, 'New Team');
    });

    test('updateOrganization updates maxUsers successfully', () async {
      // Arrange
      final updatedOrg = TestData.createTestOrganization(maxUsers: 100);
      mockRepository.mockUpdateOrganization(updatedOrg);

      // Act
      await notifier.updateOrganization(maxUsers: 100);

      // Assert
      expect(notifier.state.organization!.maxUsers, 100);
    });

    test('updateOrganization handles error correctly', () async {
      // Arrange
      when(() => mockRepository.updateOrganization(
        name: any(named: 'name'),
        teamName: any(named: 'teamName'),
        maxUsers: any(named: 'maxUsers'),
      )).thenThrow(Exception('Update failed'));

      // Act
      await notifier.updateOrganization(name: 'New Name');

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Failed to update organization'));
      expect(notifier.state.error, contains('Update failed'));
    });

    test('updateOrganization clears previous error on success', () async {
      // Arrange - Create error state
      when(() => mockRepository.updateOrganization(
        name: any(named: 'name'),
        teamName: any(named: 'teamName'),
        maxUsers: any(named: 'maxUsers'),
      )).thenThrow(Exception('First error'));
      await notifier.updateOrganization(name: 'Name');
      expect(notifier.state.error, isNotNull);

      // Act - Succeed on retry
      mockRepository.mockUpdateOrganization(TestData.testOrganization);
      await notifier.updateOrganization(name: 'New Name');

      // Assert
      expect(notifier.state.error, isNull);
    });

    test('updateOrganization preserves stats', () async {
      // Arrange - Set stats
      final stats = TestData.createTestOrgStats();
      mockRepository.mockGetOrganizationStats(stats);
      await notifier.fetchStats();

      // Act - Update organization
      mockRepository.mockUpdateOrganization(TestData.testOrganization);
      await notifier.updateOrganization(name: 'New Name');

      // Assert - Stats preserved
      expect(notifier.state.stats, equals(stats));
    });

    test('updateOrganization sets loading to false on error', () async {
      // Arrange
      when(() => mockRepository.updateOrganization(
        name: any(named: 'name'),
        teamName: any(named: 'teamName'),
        maxUsers: any(named: 'maxUsers'),
      )).thenThrow(Exception('Error'));

      // Act
      await notifier.updateOrganization(name: 'Name');

      // Assert
      expect(notifier.state.isLoading, false);
    });
  });

  // ==================== GROUP 5: REFRESH TESTS ====================
  group('refresh Tests', () {
    test('refresh calls both fetchOrganization and fetchStats', () async {
      // Arrange
      mockRepository.mockGetOrganization(TestData.testOrganization);
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());

      // Act
      await notifier.refresh();

      // Assert
      verify(() => mockRepository.getOrganization()).called(1);
      verify(() => mockRepository.getOrganizationStats()).called(1);
      expect(notifier.state.organization, isNotNull);
      expect(notifier.state.stats, isNotNull);
    });

    test('refresh updates both organization and stats', () async {
      // Arrange
      final org = TestData.createTestOrganization(name: 'Refreshed');
      final stats = TestData.createTestOrgStats(userCount: 20);
      mockRepository.mockGetOrganization(org);
      mockRepository.mockGetOrganizationStats(stats);

      // Act
      await notifier.refresh();

      // Assert
      expect(notifier.state.organization!.name, 'Refreshed');
      expect(notifier.state.stats!.userCount, 20);
    });

    test('refresh continues to fetchStats even if fetchOrganization fails', () async {
      // Arrange
      mockRepository.mockGetOrganizationError(Exception('Org error'));
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());

      // Act
      await notifier.refresh();

      // Assert - Stats should still be fetched
      verify(() => mockRepository.getOrganization()).called(1);
      verify(() => mockRepository.getOrganizationStats()).called(1);
      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.error, contains('Failed to load organization'));
    });

    test('refresh handles both fetch failures gracefully', () async {
      // Arrange
      mockRepository.mockGetOrganizationError(Exception('Org error'));
      mockRepository.mockGetOrganizationStatsError(Exception('Stats error'));

      // Act
      await notifier.refresh();

      // Assert
      expect(notifier.state.error, isNotNull);
      // Note: Last error will be from fetchStats since it's called after
      expect(notifier.state.error, contains('Failed to load statistics'));
    });

    test('refresh can be called to update stale data', () async {
      // Arrange - Set initial data
      mockRepository.mockGetOrganization(
        TestData.createTestOrganization(name: 'Old Name'),
      );
      mockRepository.mockGetOrganizationStats(
        TestData.createTestOrgStats(userCount: 5),
      );
      await notifier.refresh();

      expect(notifier.state.organization!.name, 'Old Name');
      expect(notifier.state.stats!.userCount, 5);

      // Act - Refresh with new data
      mockRepository.mockGetOrganization(
        TestData.createTestOrganization(name: 'New Name'),
      );
      mockRepository.mockGetOrganizationStats(
        TestData.createTestOrgStats(userCount: 10),
      );
      await notifier.refresh();

      // Assert
      expect(notifier.state.organization!.name, 'New Name');
      expect(notifier.state.stats!.userCount, 10);
    });

    test('refresh clears loading state when complete', () async {
      // Arrange
      mockRepository.mockGetOrganization(TestData.testOrganization);
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());

      // Act
      await notifier.refresh();

      // Assert
      expect(notifier.state.isLoading, false);
    });
  });

  // ==================== GROUP 6: EDGE CASES ====================
  group('Edge Cases and Integration Tests', () {
    test('state remains consistent after multiple operations', () async {
      // Arrange
      mockRepository.mockGetOrganization(TestData.testOrganization);
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());
      mockRepository.mockUpdateOrganization(
        TestData.createTestOrganization(name: 'Updated'),
      );

      // Act - Multiple operations
      await notifier.fetchOrganization();
      await notifier.fetchStats();
      await notifier.updateOrganization(name: 'Updated');

      // Assert
      expect(notifier.state.organization, isNotNull);
      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('dispose does not crash', () {
      // tearDown already calls dispose, so just verify notifier exists
      expect(notifier, isNotNull);
      expect(notifier.state, isNotNull);
    });

    test('error messages are descriptive', () async {
      // Arrange
      mockRepository.mockGetOrganizationError(Exception('Connection timeout'));

      // Act
      await notifier.fetchOrganization();

      // Assert
      expect(notifier.state.error, contains('Failed to load organization'));
      expect(notifier.state.error, contains('Connection timeout'));
    });

    test('can recover from error state', () async {
      // Arrange - Error state
      mockRepository.mockGetOrganizationError(Exception('Error'));
      await notifier.fetchOrganization();
      expect(notifier.state.error, isNotNull);

      // Act - Success
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();

      // Assert - Recovered
      expect(notifier.state.error, isNull);
      expect(notifier.state.organization, isNotNull);
    });

    test('isLoading is never true after operation completes', () async {
      // Test fetchOrganization
      mockRepository.mockGetOrganization(TestData.testOrganization);
      await notifier.fetchOrganization();
      expect(notifier.state.isLoading, false);

      // Test updateOrganization
      mockRepository.mockUpdateOrganization(TestData.testOrganization);
      await notifier.updateOrganization(name: 'Name');
      expect(notifier.state.isLoading, false);

      // Test refresh
      mockRepository.mockGetOrganizationStats(TestData.createTestOrgStats());
      await notifier.refresh();
      expect(notifier.state.isLoading, false);
    });
  });
}
