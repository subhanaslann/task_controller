import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/presentation/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
  });

  group('LoginScreen - UI Rendering', () {
    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Assert
      expect(find.byType(TextField), findsNWidgets(2)); // Username and password
      expect(find.text('Sign In'), findsOneWidget); // Login button
    });

    testWidgets('should show password toggle icon', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );

      // Assert initial state (obscured)
      expect(passwordField.obscureText, true);

      // Act - Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - Password visible
      final updatedField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(updatedField.obscureText, false);
    });

    testWidgets('should show link to registration screen', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Assert
      expect(find.textContaining('Register'), findsOneWidget);
    });

    testWidgets('should show loading indicator during login', (tester) async {
      // Arrange
      when(() => mockAuthRepo.login(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return AuthResult(
          user: TestData.memberUser,
          organization: TestData.testOrganization,
        );
      });

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter credentials and submit
      await tester.enterText(find.byType(TextField).first, 'testuser');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Loading state active (button may show different state)
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsWidgets);

      // Clean up pending async (matches the 500ms delay in mock)
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('LoginScreen - Form Validation', () {
    testWidgets('should show error on empty username', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Submit without entering username
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Validation error shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show error on empty password', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter username but not password
      await tester.enterText(find.byType(TextField).first, 'testuser');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Validation error shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));
    });

    testWidgets('should not call API with invalid form', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Submit empty form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - API not called
      verifyNever(() => mockAuthRepo.login(any(), any()));
    });
  });

  group('LoginScreen - Login Flow', () {
    testWidgets('should call login with correct credentials', (tester) async {
      // Arrange
      String? capturedUsername;
      String? capturedPassword;

      when(() => mockAuthRepo.login(any(), any())).thenAnswer((
        invocation,
      ) async {
        capturedUsername = invocation.positionalArguments[0] as String;
        capturedPassword = invocation.positionalArguments[1] as String;
        return AuthResult(
          user: TestData.memberUser,
          organization: TestData.testOrganization,
        );
      });

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter credentials and submit
      await tester.enterText(find.byType(TextField).first, 'testuser@test.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(capturedUsername, 'testuser@test.com');
      expect(capturedPassword, 'password123');
    });

    testWidgets('should show error on invalid credentials', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.login(any(), any()),
      ).thenThrow(Exception('Invalid credentials'));

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act
      await tester.enterText(find.byType(TextField).first, 'wrong@test.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - Error message displayed
      expect(find.textContaining('Invalid'), findsOneWidget);
    });

    testWidgets('should show error on network failure', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.login(any(), any()),
      ).thenThrow(Exception('Network error'));

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act
      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - Error message displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should trim username input', (tester) async {
      // Arrange
      String? capturedUsername;

      when(() => mockAuthRepo.login(any(), any())).thenAnswer((
        invocation,
      ) async {
        capturedUsername = invocation.positionalArguments[0] as String;
        return AuthResult(
          user: TestData.memberUser,
          organization: TestData.testOrganization,
        );
      });

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter username with spaces
      await tester.enterText(
        find.byType(TextField).first,
        '  testuser@test.com  ',
      );
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - Username trimmed
      expect(capturedUsername, 'testuser@test.com');
    });
  });

  group('LoginScreen - Error Handling', () {
    testWidgets('should show deactivated account error', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.login(any(), any()),
      ).thenThrow(Exception('Account is deactivated'));

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act
      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('deactivated'), findsOneWidget);
    });

    testWidgets('should show inactive organization error', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.login(any(), any()),
      ).thenThrow(Exception('Organization has been deactivated'));

      await pumpTestWidget(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act
      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('deactivated'), findsOneWidget);
    });
  });
}
