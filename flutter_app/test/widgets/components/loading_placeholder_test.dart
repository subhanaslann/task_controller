import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LoadingPlaceholder Widget Tests', () {
    testWidgets('should render loading placeholder with shimmer effect',
        (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingPlaceholder(),
      );

      // Assert
      expect(find.byType(LoadingPlaceholder), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should animate shimmer effect', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const LoadingPlaceholder(),
      );

      // Act - Wait for animation to start
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Widget should still be there
      expect(find.byType(LoadingPlaceholder), findsOneWidget);
    });

    testWidgets('should render multiple loading placeholders in list',
        (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        ListView(
          children: const [
            LoadingPlaceholder(),
            LoadingPlaceholder(),
            LoadingPlaceholder(),
          ],
        ),
      );

      // Assert
      expect(find.byType(LoadingPlaceholder), findsNWidgets(3));
    });
  });

  group('LoadingState Widget Tests', () {
    testWidgets('should render circular progress indicator', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoadingState(),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ErrorState Widget Tests', () {
    testWidgets('should render error icon and message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        ErrorState(
          message: 'Error occurred',
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Tekrar Dene'), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is tapped',
        (tester) async {
      // Arrange
      var retryCalled = false;
      await pumpTestWidget(
        tester,
        ErrorState(
          message: 'Error occurred',
          onRetry: () {
            retryCalled = true;
          },
        ),
      );

      // Act
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pump();

      // Assert
      expect(retryCalled, true);
    });
  });
}

