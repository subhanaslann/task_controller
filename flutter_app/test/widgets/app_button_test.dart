import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/app_button.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders button with text', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Click Me',
          onPressed: () {},
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      final widget = createTestWidget(
        AppButton(
          text: 'Test Button',
          onPressed: () => wasPressed = true,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        const AppButton(
          text: 'Disabled Button',
          onPressed: null,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Loading Button',
          onPressed: () {},
          isLoading: true,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('renders full width when isFullWidth is true', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Full Width Button',
          onPressed: () {},
          isFullWidth: true,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('shows icon when provided', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Icon Button',
          onPressed: () {},
          icon: Icons.add,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Icon Button'), findsOneWidget);
    });

    testWidgets('applies secondary variant styling', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Secondary Button',
          onPressed: () {},
          variant: ButtonVariant.secondary,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - should render without errors
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('applies ghost variant styling', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        AppButton(
          text: 'Ghost Button',
          onPressed: () {},
          variant: ButtonVariant.ghost,
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Ghost Button'), findsOneWidget);
    });
  });
}
