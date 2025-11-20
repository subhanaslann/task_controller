import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/admin/presentation/organization_tab.dart';
import 'package:flutter_app/features/admin/notifiers/organization_notifier.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/data/models/organization_stats.dart';
import 'package:flutter_app/data/repositories/organization_repository.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../../helpers/test_helpers.dart';

// Mock OrganizationNotifier for testing
class MockOrganizationNotifier extends OrganizationNotifier {
  MockOrganizationNotifier() : super(FakeOrganizationRepository());

  @override
  void setState(OrganizationState newState) {
    state = newState;
  }

  @override
  Future<void> refresh() async {
    // Do nothing
  }
}

class FakeOrganizationRepository implements OrganizationRepository {
  @override
  Future<Organization> getOrganization() async => throw UnimplementedError();

  @override
  Future<OrganizationStats> getOrganizationStats() async =>
      throw UnimplementedError();

  @override
  Future<Organization> updateOrganization({
    String? name,
    String? teamName,
    int? maxUsers,
  }) async => throw UnimplementedError();
}

void main() {
  group('OrganizationTab Widget Tests', () {
    final testUser = User(
      id: 'user1',
      organizationId: 'org1',
      name: 'Test Admin',
      username: 'testadmin',
      email: 'admin@example.com',
      role: UserRole.admin,
      active: true,
    );

    final testOrganization = Organization(
      id: 'org1',
      name: 'Test Organization',
      teamName: 'Test Team',
      slug: 'test-org',
      isActive: true,
      maxUsers: 15,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final testStats = OrganizationStats(
      userCount: 10,
      activeUserCount: 8,
      taskCount: 50,
      activeTaskCount: 30,
      completedTaskCount: 20,
      topicCount: 5,
      activeTopicCount: 4,
    );

    testWidgets('should render organization details section', (tester) async {
      // Arrange
      final orgState = OrganizationState(
        organization: testOrganization,
        stats: testStats,
        isLoading: false,
      );

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Organization Details'), findsOneWidget);
      expect(find.text('Test Organization'), findsOneWidget);
      expect(find.text('Test Team'), findsOneWidget);
      expect(find.text('test-org'), findsOneWidget);
    });

    testWidgets('should render statistics section', (tester) async {
      // Arrange
      final orgState = OrganizationState(
        organization: testOrganization,
        stats: testStats,
        isLoading: false,
      );

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.textContaining('10'), findsWidgets); // user count
      expect(find.textContaining('50'), findsWidgets); // task count
    });

    testWidgets('should show loading state', (tester) async {
      // Arrange
      final orgState = OrganizationState(isLoading: true);

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (tester) async {
      // Arrange
      final orgState = OrganizationState(
        error: 'Failed to load organization',
        isLoading: false,
      );

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );

      // Assert
      expect(find.text('Failed to load organization'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show edit button for admin users', (tester) async {
      // Arrange
      final orgState = OrganizationState(
        organization: testOrganization,
        stats: testStats,
        isLoading: false,
      );

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should display maxUsers field for admin', (tester) async {
      // Arrange
      final orgState = OrganizationState(
        organization: testOrganization,
        stats: testStats,
        isLoading: false,
      );

      await pumpTestWidget(
        tester,
        const OrganizationTab(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
          organizationRepositoryProvider.overrideWithValue(
            FakeOrganizationRepository(),
          ),
          organizationNotifierProvider.overrideWith((ref) {
            final notifier = MockOrganizationNotifier();
            notifier.setState(orgState);
            return notifier;
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Debug
      debugPrint('Finding Max Users...');
      final maxUsersFinder = find.text('Max Users');
      debugPrint('Found Max Users count: ${maxUsersFinder.evaluate().length}');

      if (maxUsersFinder.evaluate().isEmpty) {
        // debugPrint('Widget Tree:');
        // debugPrint(tester.binding.rootElement.toStringDeep());
      }

      // Scroll to make sure it's visible
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Max Users'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });
  });
}
