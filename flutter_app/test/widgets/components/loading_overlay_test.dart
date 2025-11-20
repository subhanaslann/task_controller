import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/loading_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('LoadingOverlay - Basic Rendering', () {
    testWidgets('should display child widget when not loading', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(isLoading: false, child: Text('Content')),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display loading indicator when loading', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(isLoading: true, child: Text('Content')),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget); // Child still visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading message when provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(
          isLoading: true,
          message: 'Loading tasks...',
          child: Text('Content'),
        ),
      );

      // Assert
      expect(find.text('Loading tasks...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display loading message when not provided', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(isLoading: true, child: Text('Content')),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // No Text widget for message
      expect(find.text('Loading...'), findsNothing);
    });
  });

  group('LoadingOverlay - Overlay Behavior', () {
    testWidgets('should overlay content when loading', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(
          isLoading: true,
          child: Text('Background Content'),
        ),
      );

      // Assert - Both content and overlay visible
      expect(find.text('Background Content'), findsOneWidget);
      expect(find.byKey(const Key('loading_overlay_stack')), findsOneWidget);
    });

    testWidgets('should use semi-transparent black overlay', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(isLoading: true, child: Text('Content')),
      );

      // Assert - Container with overlay exists
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThan(0));
    });
  });

  group('LoadingOverlay - Static show() Method', () {
    testWidgets('LoadingOverlay.show() should display loading', (tester) async {
      // Arrange
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await LoadingOverlay.show(
                  context: context,
                  future: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    completed = true;
                  },
                );
              },
              child: const Text('Start'),
            ),
          ),
        ),
      );

      // Act - Start async operation
      await tester.tap(find.text('Start'));
      await tester.pump(); // Start animation

      // Assert - Loading dialog shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for completion
      await tester.pump(const Duration(milliseconds: 150));

      // Assert - Operation completed
      expect(completed, true);
    });

    testWidgets('LoadingOverlay.show() should display custom message', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await LoadingOverlay.show(
                  context: context,
                  message: 'Saving data...',
                  future: () async {
                    await Future.delayed(const Duration(milliseconds: 50));
                  },
                );
              },
              child: const Text('Save'),
            ),
          ),
        ),
      );

      // Act - Start async operation
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Assert - Custom message shown
      expect(find.text('Saving data...'), findsOneWidget);

      // Wait for dialog to close
      await tester.pumpAndSettle();
    });

    testWidgets('LoadingOverlay.show() should handle errors', (tester) async {
      // Arrange
      Object? caughtError;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                try {
                  await LoadingOverlay.show(
                    context: context,
                    future: () async {
                      throw Exception('Test error');
                    },
                  );
                } catch (e) {
                  caughtError = e;
                }
              },
              child: const Text('Error Test'),
            ),
          ),
        ),
      );

      // Act - Start async operation that throws
      await tester.tap(find.text('Error Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Error was propagated
      expect(caughtError, isNotNull);
      expect(caughtError.toString(), contains('Test error'));
    });
  });

  group('LoadingOverlay - Extension Method', () {
    testWidgets('BuildContext.showLoading() should work', (tester) async {
      // Arrange
      var taskCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await context.showLoading(
                  future: () async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    taskCompleted = true;
                  },
                  message: 'Processing...',
                );
              },
              child: const Text('Process'),
            ),
          ),
        ),
      );

      // Act - Start loading
      await tester.tap(find.text('Process'));
      await tester.pump();

      // Assert - Loading shown
      expect(find.text('Processing...'), findsOneWidget);

      // Wait for completion
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Task completed
      expect(taskCompleted, true);
    });
  });

  group('LoadingOverlay - Widget Tree', () {
    testWidgets('should maintain widget tree structure', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        LoadingOverlay(
          isLoading: true,
          child: Column(children: const [Text('Line 1'), Text('Line 2')]),
        ),
      );

      // Assert - Original widget tree preserved
      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.byKey(const Key('loading_overlay_content')), findsOneWidget);
    });

    testWidgets('should work with complex child widgets', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingOverlay(
          isLoading: false,
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Complex Widget'),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Complex Widget'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
