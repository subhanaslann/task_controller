import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('GoRouter Navigation Tests', () {
    testWidgets('should navigate to login route', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act
      router.go('/login');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to home route', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const Scaffold(body: Text('Tasks')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act
      router.go('/tasks');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tasks'), findsOneWidget);

      // Navigate back to home
      router.go('/');
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should handle context.push navigation', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/details'),
                  child: const Text('Go to Details'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/details',
            builder: (context, state) => const Scaffold(body: Text('Details')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act
      await tester.tap(find.text('Go to Details'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('should handle context.pop navigation', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/settings'),
                  child: const Text('Open Settings'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act - Navigate to settings
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);

      // Pop back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Assert - Back to home
      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('should preserve state during navigation', (tester) async {
      // Arrange
      var counter = 0;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    Text('Counter: $counter'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => counter++);
                      },
                      child: const Text('Increment'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/other'),
                      child: const Text('Navigate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/other',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act - Increment counter
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();

      expect(find.text('Counter: 1'), findsOneWidget);

      // Navigate away
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();

      // Assert - Counter preserved
      expect(find.text('Counter: 1'), findsOneWidget);
    });
  });

  group('GoRouter Deep Links', () {
    testWidgets('should handle deep link navigation', (tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/tasks/123',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/tasks/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Scaffold(body: Text('Task ID: $id'));
            },
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Task ID: 123'), findsOneWidget);
    });

    testWidgets('should handle query parameters', (tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/search?q=flutter',
        routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return Scaffold(body: Text('Search: $query'));
            },
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Search: flutter'), findsOneWidget);
    });
  });

  group('GoRouter Error Handling', () {
    testWidgets('should handle unknown routes', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
        ],
        errorBuilder: (context, state) =>
            const Scaffold(body: Text('404 - Page Not Found')),
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      // Act - Navigate to unknown route
      router.go('/unknown-route');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('404 - Page Not Found'), findsOneWidget);
    });
  });
}
