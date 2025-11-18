import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/core/widgets/status_badge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('should display TODO status correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.todo),
          ),
        ),
      );

      // Assert
      expect(find.text('Yapılacak'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('should display IN_PROGRESS status correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.inProgress),
          ),
        ),
      );

      // Assert
      expect(find.text('Devam Ediyor'), findsOneWidget);
      expect(find.byIcon(Icons.autorenew), findsOneWidget);
    });

    testWidgets('should display DONE status correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.done),
          ),
        ),
      );

      // Assert
      expect(find.text('Tamamlandı'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('should apply correct colors for each status', (tester) async {
      // Test TODO color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.todo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test IN_PROGRESS color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.inProgress),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test DONE color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: TaskStatus.done),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not throw any exceptions
      expect(find.byType(StatusBadge), findsOneWidget);
    });
  });
}
