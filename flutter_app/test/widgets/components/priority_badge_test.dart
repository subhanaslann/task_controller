import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/core/widgets/priority_badge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('PriorityBadge - Priority Levels', () {
    testWidgets('should display HIGH priority badge', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.high),
      );

      // Assert
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('should display NORMAL priority badge', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.normal),
      );

      // Assert
      expect(find.text('NORMAL'), findsOneWidget);
    });

    testWidgets('should display LOW priority badge', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.low),
      );

      // Assert
      expect(find.text('LOW'), findsOneWidget);
    });
  });

  group('PriorityBadge - Colors', () {
    testWidgets('HIGH priority should use red color', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.high),
      );

      // Assert - Find Icon with red color
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color?.value, 0xFFEF4444); // Red
    });

    testWidgets('NORMAL priority should use blue color', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.normal),
      );

      // Assert - Find Icon with blue color
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color?.value, 0xFF3B82F6); // Blue
    });

    testWidgets('LOW priority should use gray color', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.low),
      );

      // Assert - Find Icon with gray color
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color?.value, 0xFF6B7280); // Gray
    });
  });
}

