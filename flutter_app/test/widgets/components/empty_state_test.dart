import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/empty_state.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should render icon, title, and message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const EmptyState(
          icon: Icons.inbox,
          title: 'No Items',
          message: 'There are no items to display',
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('There are no items to display'), findsOneWidget);
    });

    testWidgets('should render with action button when provided', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        EmptyState(
          icon: Icons.inbox,
          title: 'No Items',
          message: 'There are no items to display',
          action: ElevatedButton(
            onPressed: () {},
            child: const Text('Add Item'),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should not render action button when not provided', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const EmptyState(
          icon: Icons.inbox,
          title: 'No Items',
          message: 'There are no items to display',
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should render with different icons', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const EmptyState(
          icon: Icons.search_off,
          title: 'No Results',
          message: 'No search results found',
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
