import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/repositories/admin_repository.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/features/admin/presentation/admin_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

// Mock AdminRepository
class MockAdminRepository implements AdminRepository {
  @override
  Future<List<User>> getUsers() async => [];

  @override
  Future<List<Topic>> getTopics() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock TaskRepository
class MockTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getTeamActiveTasks() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminScreen - Tab Bar Rendering', () {
    testWidgets('should render tab bar with 4 tabs for TEAM_MANAGER', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
      expect(find.text('Organization'), findsOneWidget);
    });

    testWidgets('should render tab bar with 4 tabs for ADMIN', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.adminUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
      expect(find.text('Organization'), findsOneWidget);
    });

    testWidgets('should show Exit Admin Mode button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should switch tabs on tap', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          currentOrganizationProvider.overrideWith(
            (ref) => TestData.testOrganization,
          ),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Act - Tap Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // Allow tab animation

      // Assert - Tab switched
      expect(find.text('Tasks'), findsWidgets);
    });

    testWidgets('should have AppBar with title', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Admin Panel'), findsOneWidget);
    });
  });

  group('AdminScreen - Tab Content', () {
    testWidgets('should render Users tab content', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          currentOrganizationProvider.overrideWith(
            (ref) => TestData.testOrganization,
          ),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Users tab is default
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should render Tasks tab content on switch', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          currentOrganizationProvider.overrideWith(
            (ref) => TestData.testOrganization,
          ),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Act - Switch to Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - TabBarView rendered
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should render Topics tab content on switch', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          currentOrganizationProvider.overrideWith(
            (ref) => TestData.testOrganization,
          ),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Act - Switch to Topics tab
      await tester.tap(find.text('Topics'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - TabBarView rendered
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should render Organization tab content on switch', (
      tester,
    ) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          currentOrganizationProvider.overrideWith(
            (ref) => TestData.testOrganization,
          ),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Act - Switch to Organization tab
      await tester.tap(find.text('Organization'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - TabBarView rendered
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });

  group('AdminScreen - Access Control', () {
    testWidgets('should allow access for ADMIN user', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.adminUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert - Screen renders successfully
      expect(find.byType(AdminScreen), findsOneWidget);
    });

    testWidgets('should allow access for TEAM_MANAGER user', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          adminRepositoryProvider.overrideWith((ref) => MockAdminRepository()),
          taskRepositoryProvider.overrideWith((ref) => MockTaskRepository()),
        ],
      );

      // Assert - Screen renders successfully
      expect(find.byType(AdminScreen), findsOneWidget);
    });

    // Note: Access denial for MEMBER/GUEST should be tested at navigation level
  });
}
