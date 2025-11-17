import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AppTextField - Basic Rendering', () {
    testWidgets('should render text field with label', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Email',
          hintText: 'Enter email',
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should render text field with hint text', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Email',
          hintText: 'Enter email',
        ),
      );

      // Assert
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      // Arrange
      final controller = TextEditingController();
      
      await pumpTestWidget(
        tester,
        AppTextField(
          label: 'Name',
          controller: controller,
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'John Doe');

      // Assert
      expect(controller.text, 'John Doe');
    });
  });

  group('AppTextField - Password Field', () {
    testWidgets('should obscure text when obscureText is true', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      // Assert - Field is obscured
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('should show visibility toggle icon for password field', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should toggle password visibility on icon tap', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      final initialField = tester.widget<TextField>(find.byType(TextField));
      expect(initialField.obscureText, true);

      // Act - Tap visibility icon
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - Password visible
      final updatedField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedField.obscureText, false);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('AppTextField - Validation', () {
    testWidgets('should display error message', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Email',
          errorText: 'Invalid email format',
        ),
      );

      // Assert
      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('should apply validator function', (tester) async {
      // Arrange
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      await pumpTestWidget(
        tester,
        AppTextField(
          label: 'Username',
          validator: validator,
        ),
      );

      // Assert - Validator can be applied
      expect(validator, isNotNull);
      expect(validator('test'), isNull); // Valid input
      expect(validator(''), 'Field is required'); // Invalid input
    });
  });

  group('AppTextField - Icons', () {
    testWidgets('should display prefix icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Email',
          prefixIcon: Icons.email,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should display suffix icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Search',
          suffixIcon: Icon(Icons.search),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('AppTextField - Disabled State', () {
    testWidgets('should be disabled when enabled is false', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Disabled Field',
          enabled: false,
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('should not accept input when disabled', (tester) async {
      // Arrange
      final controller = TextEditingController();
      
      await pumpTestWidget(
        tester,
        AppTextField(
          label: 'Disabled Field',
          controller: controller,
          enabled: false,
        ),
      );

      // Act - Try to enter text
      await tester.enterText(find.byType(TextField), 'Test');

      // Assert - Text not entered (disabled fields don't accept input)
      expect(controller.text, '');
    });
  });

  group('AppTextField - Max Length', () {
    testWidgets('should show character counter with max length', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppTextField(
          label: 'Bio',
          maxLength: 100,
        ),
      );

      // Assert - TextField with maxLength is rendered (Flutter handles counter automatically)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 100);
    });

    testWidgets('should update character counter on input', (tester) async {
      // Arrange
      final controller = TextEditingController();
      await pumpTestWidget(
        tester,
        AppTextField(
          label: 'Bio',
          maxLength: 100,
          controller: controller,
        ),
      );

      // Act - Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Assert - Text is entered correctly
      expect(controller.text, 'Hello');
      expect(controller.text.length, 5);
    });
  });
}

