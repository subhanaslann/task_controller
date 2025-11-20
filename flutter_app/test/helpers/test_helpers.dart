import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

/// Pump a widget wrapped in MaterialApp and ProviderScope for testing
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: widget),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
      ),
    ),
  );
}

/// Pump a widget with navigation support
Future<void> pumpTestWidgetWithNavigation(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  RouteSettings? settings,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: widget),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home')),
          '/login': (context) => const Scaffold(body: Text('Login')),
          '/admin': (context) => const Scaffold(body: Text('Admin')),
        },
      ),
    ),
  );
}

/// Wait for all animations and frames to complete
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(timeout);
}

/// Enter text into a TextField
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Tap a widget and wait for animations
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Find a widget by key
Finder findByKey(String key) => find.byKey(Key(key));

/// Find a widget by type
Finder findByType<T>() => find.byType(T);

/// Find text
Finder findText(String text) => find.text(text);

/// Verify widget exists
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verify widget doesn't exist
void expectWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify widget count
void expectWidgetCount(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Mock delay for async operations
Future<void> mockDelay([
  Duration duration = const Duration(milliseconds: 100),
]) {
  return Future.delayed(duration);
}

/// Scroll until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
  double scrollDelta = -300.0,
  int maxScrolls = 10,
}) async {
  scrollable ??= find.byType(Scrollable).first;

  for (int i = 0; i < maxScrolls; i++) {
    if (tester.any(finder)) {
      // Widget found, try to make it visible
      try {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        return;
      } catch (e) {
        // If ensureVisible fails, try manual scroll
      }
    }

    // Scroll down
    await tester.drag(scrollable, Offset(0, scrollDelta));
    await tester.pumpAndSettle();

    if (tester.any(finder)) {
      return;
    }
  }
}
