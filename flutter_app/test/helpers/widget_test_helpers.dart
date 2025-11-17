import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates a test widget wrapped in MaterialApp and ProviderScope
/// Returns a Widget that can be passed to tester.pumpWidget()
Widget createTestWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}
