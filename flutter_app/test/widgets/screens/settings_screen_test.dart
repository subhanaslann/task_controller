import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/settings/presentation/settings_screen.dart';
import 'package:flutter_app/core/providers/theme_provider.dart';
import 'package:flutter_app/core/providers/locale_provider.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    final testUser = User(
      id: 'user1',
      organizationId: 'org1',
      name: 'Test User',
      username: 'testuser',
      email: 'test@example.com',
      role: UserRole.member,
      active: true,
    );

    final testOrganization = Organization(
      id: 'org1',
      name: 'Test Org',
      teamName: 'Test Team',
      slug: 'test-org',
      isActive: true,
      maxUsers: 15,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    testWidgets('should render settings screen with app bar', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const SettingsScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render theme option', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const SettingsScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          themeProvider.overrideWith((ref) => ThemeNotifier()),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Theme'), findsOneWidget);
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);
    });

    testWidgets('should render language option', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const SettingsScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
          localeProvider.overrideWith((ref) => LocaleNotifier()),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Language option displayed (appears in section header + list tile)
      expect(find.text('Language'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should render account section when user is logged in', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const SettingsScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Account'), findsWidgets);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should render logout option', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const SettingsScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          currentOrganizationProvider.overrideWith((ref) => testOrganization),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
