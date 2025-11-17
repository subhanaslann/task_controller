import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
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

      // Assert
      expect(find.textContaining('No'), findsOneWidget);
    });

    testWidgets('should show loading state while fetching', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          teamActiveTopicsProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return [];
          }),
        ],
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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

      when(
        () => mockTaskRepo.getTeamActiveTasks(),
      ).thenAnswer((_) async => [guestTask]);

      // Act
      await pumpTestWidget(
        tester,
        const TeamActiveTasksScreen(),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestData.guestUser),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Task displayed without note
      expect(find.text('Guest Visible Task'), findsOneWidget);
    });

    testWidgets('should pull to refresh for all users', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getTeamActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask]);

      await pumpTestWidget(tester, const TeamActiveTasksScreen());
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockTaskRepo.getTeamActiveTasks(),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
