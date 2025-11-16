import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TekTech Test Helpers
/// 
/// Utilities for widget testing with Riverpod
/// - ProviderScope wrapper
/// - Material app wrapper
/// - Common test utilities

/// Create a testable widget wrapped with ProviderScope and MaterialApp
Widget createTestWidget(
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme,
      locale: locale,
      home: Scaffold(body: child),
    ),
  );
}

/// Create a ProviderContainer for testing providers without widgets
ProviderContainer createContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
}) {
  return ProviderContainer(
    overrides: overrides,
    parent: parent,
  );
}

/// Pump and settle with standard duration
Future<void> pumpAndSettle(WidgetTester tester, [Duration? duration]) {
  return tester.pumpAndSettle(duration ?? const Duration(milliseconds: 300));
}

/// Find widget by type
Finder findWidgetByType<T>() => find.byType(T);

/// Find widget by key
Finder findWidgetByKey(Key key) => find.byKey(key);

/// Find text widget
Finder findText(String text) => find.text(text);

/// Find icon
Finder findIcon(IconData icon) => find.byIcon(icon);

/// Tap a widget and settle
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enter text and settle
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Verify widget exists
void verifyWidgetExists(Finder finder, {int count = 1}) {
  expect(finder, findsNWidgets(count));
}

/// Verify widget does not exist
void verifyWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify text exists
void verifyTextExists(String text, {int count = 1}) {
  expect(find.text(text), findsNWidgets(count));
}

/// Verify text does not exist
void verifyTextNotExists(String text) {
  expect(find.text(text), findsNothing);
}
