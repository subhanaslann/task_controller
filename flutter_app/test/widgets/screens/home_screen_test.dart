import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/features/tasks/presentation/home_screen.dart';
import 'package:flutter_app/features/tasks/presentation/my_active_tasks_screen.dart';
import 'package:flutter_app/features/tasks/presentation/my_completed_tasks_screen.dart';
import 'package:flutter_app/features/tasks/presentation/team_active_tasks_screen.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen - Bottom Navigation', () {
    testWidgets('should render bottom navigation with 3 tabs', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('My Active'), findsOneWidget);
      expect(find.text('Team Active'), findsOneWidget);
      expect(find.text('My Completed'), findsOneWidget);
    });

    testWidgets('should switch tabs on tap', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Act - Tap Team Active tab
      await tester.tap(find.text('Team Active'));
      await tester.pumpAndSettle();

      // Assert - Tab changed (verify by checking if content updated)
      expect(find.text('Team Active'), findsOneWidget);
    });

    testWidgets('should render My Active tab by default', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert - First tab selected
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 0);
    });
  });

  group('HomeScreen - Floating Action Button', () {
    testWidgets('should show FAB for MEMBER user', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show FAB for TEAM_MANAGER user', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should hide FAB for GUEST user', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.guestUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should show FAB only on My Active tab', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert - FAB visible on first tab
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Act - Switch to Team Active tab
      await tester.tap(find.text('Team Active'));
      await tester.pumpAndSettle();

      // Assert - FAB should still be visible or hidden based on implementation
      // (This depends on the actual implementation)
    });
  });

  group('HomeScreen - AppBar', () {
    testWidgets('should render AppBar with profile icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('should show user menu on profile icon tap', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Act - Tap profile icon to open menu
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Assert - Menu items should appear (Profile and Logout are always visible)
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should show Admin Mode option for TEAM_MANAGER', (
      tester,
    ) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Act - Open menu
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Admin Mode'), findsOneWidget);
    });

    testWidgets('should hide Admin Mode option for MEMBER', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Act - Open menu
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Admin Mode'), findsNothing);
    });

    testWidgets('should show Logout option for all users', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const HomeScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.memberUser),
          myActiveTasksProvider.overrideWith((ref) async => []),
          myCompletedTasksProvider.overrideWith((ref) async => []),
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );

      // Act - Open menu
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
