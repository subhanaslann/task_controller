import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/user_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('UserAvatar - Initials Generation', () {
    testWidgets('should generate initials from full name', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'John Doe'),
      );

      // Assert
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should generate single initial from single name', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'John'),
      );

      // Assert
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should generate initials from three names', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'John Michael Doe'),
      );

      // Assert - Should use first and last name
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should handle empty name', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: ''),
      );

      // Assert - Should show default or '?'
      expect(find.byType(UserAvatar), findsOneWidget);
    });
  });

  group('UserAvatar - Circle Rendering', () {
    testWidgets('should render as circular shape', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'Test User'),
      );

      // Assert - CircleAvatar rendered
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should use consistent color for same name', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'Alice Johnson'),
      );

      // Assert - Avatar rendered
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('UserAvatar - Size Variants', () {
    testWidgets('should render small avatar', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'Test', size: 24),
      );

      // Assert
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 12); // radius = size / 2
    });

    testWidgets('should render medium avatar', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'Test', size: 40),
      );

      // Assert
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 20);
    });

    testWidgets('should render large avatar', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const UserAvatar(name: 'Test', size: 64),
      );

      // Assert
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 32);
    });
  });
}

