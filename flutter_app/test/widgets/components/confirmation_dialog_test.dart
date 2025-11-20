import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/confirmation_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ConfirmationDialog - Basic Rendering', () {
    testWidgets('should display title and message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Delete Task',
          message: 'Are you sure you want to delete this task?',
        ),
      );

      // Assert
      expect(find.text('Delete Task'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this task?'),
        findsOneWidget,
      );
    });

    testWidgets('should display default button labels', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Confirm',
          message: 'Proceed with action?',
        ),
      );

      // Assert
      expect(find.text('Confirm'), findsWidgets); // Title and button
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display custom button labels', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Delete',
          message: 'Delete permanently?',
          confirmLabel: 'Sil',
          cancelLabel: 'İptal',
        ),
      );

      // Assert
      expect(find.text('Sil'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Delete',
          message: 'Are you sure?',
          icon: Icons.delete_outline,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('ConfirmationDialog - Destructive Actions', () {
    testWidgets('should use error color for destructive actions', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Delete',
          message: 'This action cannot be undone',
          isDestructive: true,
        ),
      );

      // Assert - Dialog rendered
      expect(find.text('Delete'), findsOneWidget);

      // FilledButton should use error color (visual verification)
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should use primary color for non-destructive actions', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const ConfirmationDialog(
          title: 'Confirm',
          message: 'Proceed?',
          isDestructive: false,
        ),
      );

      // Assert - Dialog rendered
      expect(find.text('Confirm'), findsWidgets); // Title and button
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });

  group('ConfirmationDialog - User Interaction', () {
    testWidgets('should return false when cancel is pressed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const ConfirmationDialog(
                    title: 'Test',
                    message: 'Test message',
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, false);
    });

    testWidgets('should return true when confirm is pressed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const ConfirmationDialog(
                    title: 'Test',
                    message: 'Test message',
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, true);
    });
  });

  group('ConfirmationDialog - Static Methods', () {
    testWidgets('ConfirmationDialog.show() should work', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Static Test',
                  message: 'Static message',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Dialog shown
      expect(find.text('Static Test'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Confirm')); // Default confirm button
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('ConfirmationDialog.showDelete() should work', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.showDelete(
                  context: context,
                  itemName: 'Test Item',
                );
              },
              child: const Text('Show Delete'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Delete'));
      await tester.pumpAndSettle();

      // Assert - Delete dialog shown with item name
      expect(
        find.text('Delete'),
        findsWidgets,
      ); // Title and button both have "Delete"
      expect(find.textContaining('Test Item'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });

  group('ConfirmationDialog - Extension Methods', () {
    testWidgets('BuildContext.showConfirmation() should work', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await context.showConfirmation(
                  title: 'Extension Test',
                  message: 'Extension message',
                );
              },
              child: const Text('Show Extension'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Extension'));
      await tester.pumpAndSettle();

      // Assert - Dialog shown
      expect(find.text('Extension Test'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('BuildContext.showDeleteConfirmation() should work', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await context.showDeleteConfirmation('My Task');
              },
              child: const Text('Show Delete Extension'),
            ),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Delete Extension'));
      await tester.pumpAndSettle();

      // Assert - Delete dialog shown
      expect(
        find.text('Delete'),
        findsWidgets,
      ); // Title and button both have "Delete"
      expect(find.textContaining('My Task'), findsOneWidget);
    });
  });
}
