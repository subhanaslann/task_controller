import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_error_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppErrorView - Basic Rendering', () {
    testWidgets('should display error message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppErrorView(
          message: 'Failed to load data',
        ),
      );

      // Assert
      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppErrorView(
          message: 'Error occurred',
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display title when provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppErrorView(
          title: 'Error',
          message: 'Something went wrong',
        ),
      );

      // Assert
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  group('AppErrorView - Retry Button', () {
    testWidgets('should display retry button when onRetry is provided', (tester) async {
      // Arrange
      var retryPressed = false;
      
      await pumpTestWidget(
        tester,
        AppErrorView(
          message: 'Network error',
          onRetry: () => retryPressed = true,
        ),
      );

      // Assert - Retry button visible
      expect(find.text('Retry'), findsOneWidget);

      // Act - Tap retry
      await tester.tap(find.text('Retry'));

      // Assert - Callback called
      expect(retryPressed, true);
    });

    testWidgets('should not display retry button when onRetry is null', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppErrorView(
          message: 'Error',
        ),
      );

      // Assert - No retry button
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('AppErrorView - Go Back Button', () {
    testWidgets('should display go back button when onGoBack is provided', (tester) async {
      // Arrange
      var goBackPressed = false;
      
      await pumpTestWidget(
        tester,
        AppErrorView(
          message: 'Page not found',
          onGoBack: () => goBackPressed = true,
        ),
      );

      // Assert - Go back button visible
      expect(find.text('Go Back'), findsOneWidget);

      // Act - Tap go back
      await tester.tap(find.text('Go Back'));

      // Assert - Callback called
      expect(goBackPressed, true);
    });

    testWidgets('should show both retry and go back when both provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppErrorView(
          message: 'Error',
          onRetry: () {},
          onGoBack: () {},
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });
  });
}

