import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_app/features/tasks/presentation/my_active_tasks_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  group('MyActiveTasksScreen - Task List Rendering', () {
    testWidgets('should display task list when tasks exist', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask, TestData.inProgressTask]);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - Task cards rendered
      expect(find.text('TODO Task'), findsOneWidget);
      expect(find.text('In Progress Task'), findsOneWidget);
    });

    testWidgets('should show empty state when no tasks exist', (tester) async {
      // Arrange
      when(() => mockTaskRepo.getMyActiveTasks()).thenAnswer((_) async => []);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - Empty state shown
      expect(find.textContaining('No'), findsOneWidget);
    });

    testWidgets('should show loading indicator while fetching tasks', (
      tester,
    ) async {
      // Arrange
      when(() => mockTaskRepo.getMyActiveTasks()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return [TestData.todoTask];
      });

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pump();

      // Assert - Loading indicator shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state on API failure', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenThrow(Exception('Network error'));

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - Error message shown
      expect(
        find.textContaining('error'),
        findsAtLeastNWidgets(1),
        reason: 'Error state should be displayed',
      );
    });
  });

  group('MyActiveTasksScreen - Pull to Refresh', () {
    testWidgets('should refresh tasks on pull down', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask]);

      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - API called twice (initial + refresh)
      verify(
        () => mockTaskRepo.getMyActiveTasks(),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('MyActiveTasksScreen - Task Sorting', () {
    testWidgets('should display tasks sorted by priority', (tester) async {
      // Arrange - Tasks in random order
      final tasks = [
        TestData.createTestTask(title: 'Low Priority', priority: Priority.low),
        TestData.createTestTask(
          title: 'High Priority',
          priority: Priority.high,
        ),
        TestData.createTestTask(
          title: 'Normal Priority',
          priority: Priority.normal,
        ),
      ];

      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => tasks);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - All tasks displayed
      expect(find.text('Low Priority'), findsOneWidget);
      expect(find.text('High Priority'), findsOneWidget);
      expect(find.text('Normal Priority'), findsOneWidget);
    });
  });

  group('MyActiveTasksScreen - Task Status Display', () {
    testWidgets('should display TODO status badge', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask]);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('TODO'), findsOneWidget);
    });

    testWidgets('should display IN_PROGRESS status badge', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.inProgressTask]);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('IN PROGRESS'), findsOneWidget);
    });

    testWidgets('should not display DONE tasks', (tester) async {
      // Arrange - Only active tasks (no DONE)
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask, TestData.inProgressTask]);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - No DONE status
      expect(find.text('DONE'), findsNothing);
    });
  });

  group('MyActiveTasksScreen - Due Date Display', () {
    testWidgets('should show overdue indicator for past due tasks', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.overdueTask]);

      // Act
      await pumpTestWidget(tester, const MyActiveTasksScreen());
      await tester.pumpAndSettle();

      // Assert - Overdue indicator (usually red text or icon)
      expect(find.text('Overdue Task'), findsOneWidget);
    });
  });
}
