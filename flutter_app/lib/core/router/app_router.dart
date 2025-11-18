import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/tasks/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/tasks/presentation/guest_topics_screen.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';

/// TekTech App Router - GoRouter Configuration
///
/// Implements declarative routing with:
/// - Auth guards (redirect to login if not authenticated)
/// - Role-based access (admin routes protected)
/// - Deep linking support
/// - Page transitions

/// Route names for type-safe navigation
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String admin = '/admin';
  static const String guestTopics = '/topics';
}

/// GoRouter provider - accessible via ref.read(goRouterProvider)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    // Redirect logic - Auth guard
    redirect: (BuildContext context, GoRouterState state) async {
      // Get auth state from provider
      final isLoggedInAsync = ref.read(isLoggedInProvider);

      return isLoggedInAsync.when(
        data: (isLoggedIn) {
          final isOnLoginPage = state.matchedLocation == AppRoutes.login;
          final isOnRegisterPage = state.matchedLocation == AppRoutes.register;
          final isOnGuestPage = state.matchedLocation == AppRoutes.guestTopics;

          // If not logged in and trying to access protected route
          if (!isLoggedIn && !isOnLoginPage && !isOnRegisterPage && !isOnGuestPage) {
            return AppRoutes.login;
          }

          // If logged in and on auth page, redirect to home
          if (isLoggedIn && (isOnLoginPage || isOnRegisterPage)) {
            return AppRoutes.home;
          }

          // No redirect needed
          return null;
        },
        loading: () => null, // Don't redirect while loading
        error: (_, __) => AppRoutes.login, // Redirect to login on error
      );
    },

    routes: [
      // ========== PUBLIC ROUTES (NO AUTH REQUIRED) ==========

      /// Login Screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),

      /// Registration Screen
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const RegistrationScreen(),
        ),
      ),

      /// Guest Topics Screen (public view)
      GoRoute(
        path: AppRoutes.guestTopics,
        name: 'guest_topics',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const GuestTopicsScreen(),
        ),
      ),

      // ========== PROTECTED ROUTES (AUTH REQUIRED) ==========

      /// Home Screen (Main app)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      /// Settings Screen
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),

      /// Admin Screen (requires admin role)
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AdminScreen(),
        ),
        redirect: (context, state) async {
          // Additional check for admin role
          final currentUser = ref.read(currentUserProvider);

          if (currentUser == null) {
            return AppRoutes.login;
          }

          // Check if user has admin role
          final isAdmin = currentUser.role == UserRole.admin;

          if (!isAdmin) {
            // Non-admin users redirected to home
            return AppRoutes.home;
          }

          return null; // Allow access
        },
      ),
    ],

    // Error page (404)
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '404',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.home),
              label: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Build page with default fade transition
Page<dynamic> _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade + Slide transition
      const begin = Offset(0.0, 0.03); // Slight upward slide
      const end = Offset.zero;
      const curve = Curves.easeOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      final offsetAnimation = animation.drive(tween);
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      );

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Extension for easy navigation
extension GoRouterExtension on BuildContext {
  /// Navigate to login
  void goToLogin() => go(AppRoutes.login);

  /// Navigate to register
  void goToRegister() => go(AppRoutes.register);

  /// Navigate to home
  void goToHome() => go(AppRoutes.home);

  /// Navigate to settings
  void goToSettings() => go(AppRoutes.settings);

  /// Navigate to admin
  void goToAdmin() => go(AppRoutes.admin);

  /// Navigate to guest topics
  void goToGuestTopics() => go(AppRoutes.guestTopics);
}
