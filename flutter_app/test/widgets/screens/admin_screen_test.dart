import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/features/admin/presentation/admin_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

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
        ],
      );

      // Act - Tap Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Assert - Tab switched (TabController should update)
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller?.index, 1); // Tasks is second tab (index 1)
    });

    testWidgets('should have AppBar with title', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
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
        ],
      );
      await tester.pumpAndSettle();

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
        ],
      );

      // Act - Switch to Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Assert - Tasks content rendered
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should render Topics tab content on switch', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AdminScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.teamManagerUser),
        ],
      );

      // Act - Switch to Topics tab
      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();

      // Assert
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
        ],
      );

      // Act - Switch to Organization tab
      await tester.tap(find.text('Organization'));
      await tester.pumpAndSettle();

      // Assert
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
        ],
      );

      // Assert - Screen renders successfully
      expect(find.byType(AdminScreen), findsOneWidget);
    });

    // Note: Access denial for MEMBER/GUEST should be tested at navigation level
  });
}
