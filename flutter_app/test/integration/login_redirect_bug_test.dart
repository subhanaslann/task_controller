import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_app/core/router/app_router.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/features/auth/presentation/login_screen.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {
  bool _isLoggedIn = false;

  @override
  Future<bool> isLoggedIn() async => _isLoggedIn;

  @override
  Future<AuthResult> login(String usernameOrEmail, String password) async {
    _isLoggedIn = true;
    return AuthResult(
      user: User(
        id: '1',
        organizationId: 'org1',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        role: UserRole.member,
        active: true,
      ),
      organization: Organization(
        id: 'org1',
        name: 'Test Org',
        teamName: 'Test Team',
        slug: 'test-org',
        isActive: true,
        maxUsers: 10,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}

void main() {
  group('Login Redirect Bug', () {
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
    });

    testWidgets('Login should redirect to Home but stays on Login if provider is stale', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(goRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify we start at Login Screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // 2. Fill login form
      // Find TextFormFields inside AppTextFields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsAtLeastNWidgets(2));

      await tester.enterText(textFields.at(0), 'testuser');
      await tester.enterText(textFields.at(1), 'password');
      await tester.pump();

      // 3. Tap login button
      // The button might have different text depending on locale, let's find by icon or generic button
      final buttonFinder = find.byType(ElevatedButton);
      await tester.tap(buttonFinder);
      
      await tester.pump(); // Start animation
      await tester.pumpAndSettle(); // Wait for navigation

      // 4. Verify navigation
      // With the fix, we should be at Home, so LoginScreen should be gone.
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
