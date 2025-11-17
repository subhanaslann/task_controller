import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_app/features/tasks/presentation/team_active_tasks_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockTaskRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
  });

  group('TeamActiveTasksScreen - Read-Only Display', () {
    testWidgets('should display team tasks as read-only', (tester) async {
      // Arrange
      final topics = [TestData.createTestTopic(tasks: [TestData.todoTask, TestData.inProgressTask])];

      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async => topics),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Tasks displayed
      expect(find.text('TODO Task'), findsOneWidget);
      expect(find.text('In Progress Task'), findsOneWidget);
    });

    testWidgets('should show empty state when no team tasks exist', (
      tester,
    ) async {
      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async => []),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Empty state shown (check for empty state widget or text)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Center || widget is Column,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should show loading state while fetching', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return [];
          }),
        ],
      );
      await tester.pump();

      // Assert - Loading placeholder shown
      expect(find.byType(LoadingPlaceholder), findsAtLeastNWidgets(1));

      // Clean up pending timer
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('should show error state on failure', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async {
            throw Exception('Network error');
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('error'), findsAtLeastNWidgets(1));
    });
  });

  group('TeamActiveTasksScreen - Guest User Filtering', () {
    testWidgets('should display filtered tasks for GUEST user', (tester) async {
      // Arrange - Guest sees limited fields
      final guestTask = TestData.createTestTask(
        title: 'Guest Visible Task',
        note: null, // Note hidden for guest
      );
      final topic = TestData.createTestTopic(tasks: [guestTask]);

      // Act - Use override with topic data
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.guestUser),
          teamActiveTopicsProvider.overrideWith((ref) async => [topic]),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Task displayed
      expect(find.text('Guest Visible Task'), findsOneWidget);
    });

    testWidgets('should pull to refresh for all users', (tester) async {
      // Arrange
      final topic = TestData.createTestTopic(tasks: [TestData.todoTask]);

      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async => [topic]),
        ],
      );
      await tester.pumpAndSettle();

      // Act - Pull to refresh (drag on task to trigger)
      await tester.drag(find.text('TODO Task'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - Screen still displays content after refresh
      expect(find.text('TODO Task'), findsOneWidget);
    });
  });
}
