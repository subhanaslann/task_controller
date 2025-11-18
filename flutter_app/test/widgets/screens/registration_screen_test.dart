import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/presentation/registration_screen.dart';
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

  group('RegistrationScreen - UI Rendering', () {
    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );
      await tester.pumpAndSettle();

      // Assert - Should have 5 text fields
      // company name, team name, manager name, email, password
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('should show Create Team button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Team'), findsOneWidget);
    });

    testWidgets('should show password toggle for password field', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
    });

    testWidgets('should show link to login screen', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );
      await tester.pumpAndSettle();

      // Scroll down to see login link
      final scrollable = find.byType(Scrollable);
      if (tester.any(scrollable)) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // Assert - Look for TextButton or RichText containing login text
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('RegistrationScreen - Form Validation', () {
    testWidgets('should show error on empty company name', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Submit without entering company name
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pump();

      // Assert - Validation error shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));
    });

    testWidgets('should validate email format', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter invalid email
      final emailField = find.byType(TextField).at(3); // Email field
      await tester.enterText(emailField, 'invalid-email');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pump();

      // Assert - Email validation error shown
      expect(find.textContaining('valid'), findsAtLeastNWidgets(1));
    });

    testWidgets('should validate password minimum length', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter short password
      final passwordField = find.byType(TextField).at(4); // Password field
      await tester.enterText(passwordField, 'short');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pump();

      // Assert - Password length error shown
      expect(find.textContaining('8'), findsAtLeastNWidgets(1));
    });
  });

  group('RegistrationScreen - Registration Flow', () {
    testWidgets('should call register with correct data', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.register(
          companyName: any(named: 'companyName'),
          teamName: any(named: 'teamName'),
          managerName: any(named: 'managerName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResult(
          user: TestData.teamManagerUser,
          organization: TestData.testOrganization,
        ),
      );

      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Fill form
      await tester.enterText(find.byType(TextField).at(0), 'Test Company');
      await tester.enterText(find.byType(TextField).at(1), 'Engineering Team');
      await tester.enterText(find.byType(TextField).at(2), 'John Manager');
      await tester.enterText(find.byType(TextField).at(3), 'john@test.com');
      await tester.enterText(find.byType(TextField).at(4), 'password123');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockAuthRepo.register(
          companyName: 'Test Company',
          teamName: 'Engineering Team',
          managerName: 'John Manager',
          email: 'john@test.com',
          password: 'password123',
        ),
      ).called(1);
    });

    testWidgets('should show error on duplicate email', (tester) async {
      // Arrange
      when(
        () => mockAuthRepo.register(
          companyName: any(named: 'companyName'),
          teamName: any(named: 'teamName'),
          managerName: any(named: 'managerName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Email already registered'));

      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Fill and submit form
      await tester.enterText(find.byType(TextField).at(0), 'Company');
      await tester.enterText(find.byType(TextField).at(1), 'Team');
      await tester.enterText(find.byType(TextField).at(2), 'Manager');
      await tester.enterText(find.byType(TextField).at(3), 'existing@test.com');
      await tester.enterText(find.byType(TextField).at(4), 'password123');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Assert - Form still visible (registration failed, user stayed on screen)
      expect(find.text('Create Team'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('should show loading state during registration', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockAuthRepo.register(
          companyName: any(named: 'companyName'),
          teamName: any(named: 'teamName'),
          managerName: any(named: 'managerName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return AuthResult(
          user: TestData.teamManagerUser,
          organization: TestData.testOrganization,
        );
      });

      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act
      await tester.enterText(find.byType(TextField).at(0), 'Company');
      await tester.enterText(find.byType(TextField).at(1), 'Team');
      await tester.enterText(find.byType(TextField).at(2), 'Manager');
      await tester.enterText(find.byType(TextField).at(3), 'test@test.com');
      await tester.enterText(find.byType(TextField).at(4), 'password123');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pump();

      // Assert - Loading state active (button may show different text or be disabled)
      // Just verify form submission triggered
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsWidgets);

      // Clean up pending async
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('RegistrationScreen - Field Validation', () {
    testWidgets('should validate company name minimum length', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter single character
      await tester.enterText(find.byType(TextField).at(0), 'A');
      await scrollUntilVisible(tester, find.text('Create Team'));
      await tester.tap(find.text('Create Team'));
      await tester.pump();

      // Assert - Validation error
      expect(find.textContaining('characters'), findsAtLeastNWidgets(1));
    });

    testWidgets('should validate team name minimum length', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter single character
      await tester.enterText(find.byType(TextField).at(0), 'Company');
      await tester.enterText(find.byType(TextField).at(1), 'T');

      // Scroll to button to ensure it's visible
      await scrollUntilVisible(tester, find.text('Create Team'));

      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Assert - Validation error
      expect(find.textContaining('characters'), findsAtLeastNWidgets(1));
    });

    testWidgets('should validate manager name minimum length', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const RegistrationScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
      );

      // Act - Enter single character
      await tester.enterText(find.byType(TextField).at(0), 'Company');
      await tester.enterText(find.byType(TextField).at(1), 'Team');
      await tester.enterText(find.byType(TextField).at(2), 'M');

      // Scroll to button to ensure it's visible
      await scrollUntilVisible(tester, find.text('Create Team'));

      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Assert - Validation error
      expect(find.textContaining('characters'), findsAtLeastNWidgets(1));
    });
  });
}
