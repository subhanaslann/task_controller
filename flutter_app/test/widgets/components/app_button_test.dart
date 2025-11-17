import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppButton - Variants', () {
    testWidgets('should render primary button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Primary Button',
          onPressed: () {},
          variant: ButtonVariant.primary,
        ),
      );

      // Assert
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('should render secondary button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Secondary Button',
          onPressed: () {},
          variant: ButtonVariant.secondary,
        ),
      );

      // Assert
      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('should render tertiary button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Tertiary Button',
          onPressed: () {},
          variant: ButtonVariant.tertiary,
        ),
      );

      // Assert
      expect(find.text('Tertiary Button'), findsOneWidget);
    });

    testWidgets('should render destructive button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Delete',
          onPressed: () {},
          variant: ButtonVariant.destructive,
        ),
      );

      // Assert
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should render ghost button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Ghost Button',
          onPressed: () {},
          variant: ButtonVariant.ghost,
        ),
      );

      // Assert
      expect(find.text('Ghost Button'), findsOneWidget);
    });
  });

  group('AppButton - States', () {
    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppButton(
          text: 'Disabled Button',
          onPressed: null,
        ),
      );

      // Assert - Button exists but is disabled
      expect(find.text('Disabled Button'), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, null);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Loading Button',
          onPressed: () {},
          isLoading: true,
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show text when loading', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Loading Button',
          onPressed: () {},
          isLoading: true,
        ),
      );

      // Assert - Text hidden when loading
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      var wasPressed = false;
      
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Tap Me',
          onPressed: () => wasPressed = true,
        ),
      );

      // Act
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });
  });

  group('AppButton - Icon', () {
    testWidgets('should render button with icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Button with Icon',
          icon: Icons.add,
          onPressed: () {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Button with Icon'), findsOneWidget);
    });
  });

  group('AppButton - Full Width', () {
    testWidgets('should render full width button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Full Width',
          onPressed: () {},
          isFullWidth: true,
        ),
      );

      // Assert
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Full Width'), findsOneWidget);
    });
  });

  group('AppButton - Sizes', () {
    testWidgets('should render small button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Small',
          onPressed: () {},
          size: ButtonSize.small,
        ),
      );

      // Assert
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('should render medium button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Medium',
          onPressed: () {},
          size: ButtonSize.medium,
        ),
      );

      // Assert
      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('should render large button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        AppButton(
          text: 'Large',
          onPressed: () {},
          size: ButtonSize.large,
        ),
      );

      // Assert
      expect(find.text('Large'), findsOneWidget);
    });
  });
}

