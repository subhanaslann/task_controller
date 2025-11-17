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

      // Assert - Find Container with red color
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('HIGH'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color?.value, 0xFFEF4444); // Red
    });

    testWidgets('NORMAL priority should use blue color', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.normal),
      );

      // Assert - Find Container with blue color
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('NORMAL'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color?.value, 0xFF3B82F6); // Blue
    });

    testWidgets('LOW priority should use gray color', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const PriorityBadge(priority: Priority.low),
      );

      // Assert - Find Container with gray color
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('LOW'),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color?.value, 0xFF6B7280); // Gray
    });
  });
}

