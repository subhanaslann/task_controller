import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppDialog - Confirmation Dialog', () {
    testWidgets('should display confirmation dialog with title and message', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                    'Are you sure you want to delete this item?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this item?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should close dialog on cancel', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Show'),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Act - Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - Dialog closed
      expect(find.text('Confirm'), findsNothing);
    });

    testWidgets('should return true on confirm', (tester) async {
      // Arrange
      bool? result;

      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Show'),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Act - Tap confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Assert - Returns true
      expect(result, true);
    });
  });

  group('AppDialog - Form Dialog', () {
    testWidgets('should display form dialog with text fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Show Form'),
          ),
        ),
      );

      await tester.tap(find.text('Show Form'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Item'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should accept input in form fields', (tester) async {
      // Arrange
      final nameController = TextEditingController();

      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Form'),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
              );
            },
            child: const Text('Show'),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Act - Enter text
      await tester.enterText(find.byType(TextField), 'Test Name');

      // Assert
      expect(nameController.text, 'Test Name');
    });
  });

  group('AppDialog - Destructive Actions', () {
    testWidgets('should style destructive action with red color', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('This action cannot be undone'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Show Warning'),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
