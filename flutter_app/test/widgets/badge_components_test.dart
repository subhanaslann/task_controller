import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/status_badge.dart';
import 'package:flutter_app/core/widgets/priority_badge.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('displays correct text for TODO status', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const StatusBadge(status: TaskStatus.todo),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('To Do'), findsOneWidget);
    });

    testWidgets('displays correct text for IN_PROGRESS status', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const StatusBadge(status: TaskStatus.inProgress),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('displays correct text for DONE status', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const StatusBadge(status: TaskStatus.done),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('displays icon when showIcon is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const StatusBadge(status: TaskStatus.todo, showIcon: true),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('does not display icon when showIcon is false', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const StatusBadge(status: TaskStatus.todo, showIcon: false),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });
  });

  group('PriorityBadge Widget Tests', () {
    testWidgets('displays correct text for LOW priority', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const PriorityBadge(priority: Priority.low),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Low'), findsOneWidget);
    });

    testWidgets('displays correct text for NORMAL priority', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const PriorityBadge(priority: Priority.normal),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('displays correct text for HIGH priority', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const PriorityBadge(priority: Priority.high),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('displays icon when showIcon is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const PriorityBadge(priority: Priority.high, showIcon: true),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('uses custom fontSize when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = createTestWidget(
        const PriorityBadge(priority: Priority.high, fontSize: 20),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - widget should render without errors
      expect(find.byType(PriorityBadge), findsOneWidget);
    });
  });
}
