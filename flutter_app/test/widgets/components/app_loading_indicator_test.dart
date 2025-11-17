import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_loading_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppLoadingIndicator - Rendering', () {
    testWidgets('should display circular progress indicator', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppLoadingIndicator(),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display with message when provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppLoadingIndicator(message: 'Loading tasks...'),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading tasks...'), findsOneWidget);
    });

    testWidgets('should center content by default', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppLoadingIndicator(),
      );

      // Assert - Center widget exists
      expect(find.byType(Center), findsOneWidget);
    });
  });
}

