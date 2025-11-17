import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_empty_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppEmptyState - Basic Rendering', () {
    testWidgets('should display icon, title, and message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.task_alt,
          title: 'No Tasks',
          message: 'You don\'t have any tasks yet',
        ),
      );

      // Assert
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(find.text('No Tasks'), findsOneWidget);
      expect(find.text('You don\'t have any tasks yet'), findsOneWidget);
    });

    testWidgets('should display without message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Empty',
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
    });
  });

  group('AppEmptyState - Action Button', () {
    testWidgets('should display action button when provided', (tester) async {
      // Arrange
      var buttonPressed = false;
      
      await pumpTestWidget(
        tester,
        AppEmptyState(
          icon: Icons.add,
          title: 'No Items',
          message: 'Create your first item',
          actionLabel: 'Create Item',
          onAction: () => buttonPressed = true,
        ),
      );

      // Assert - Button visible
      expect(find.text('Create Item'), findsOneWidget);

      // Act - Tap button
      await tester.tap(find.text('Create Item'));

      // Assert - Callback called
      expect(buttonPressed, true);
    });

    testWidgets('should not display action button when not provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'No Items',
        ),
      );

      // Assert - No action button
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('AppEmptyState - Variants', () {
    testWidgets('should display "No Tasks" variant', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.task_alt,
          title: 'No Active Tasks',
          message: 'Tap + to create one',
        ),
      );

      // Assert
      expect(find.text('No Active Tasks'), findsOneWidget);
    });

    testWidgets('should display "No Users" variant', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.people,
          title: 'No Users',
          message: 'Create your first user',
        ),
      );

      // Assert
      expect(find.text('No Users'), findsOneWidget);
    });

    testWidgets('should display "No Search Results" variant', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppEmptyState(
          icon: Icons.search_off,
          title: 'No Results',
          message: 'Try a different search term',
        ),
      );

      // Assert
      expect(find.text('No Results'), findsOneWidget);
    });
  });
}

