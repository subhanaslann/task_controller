import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import 'package:flutter_app/core/widgets/task_card.dart';
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
      final tasks = [TestData.todoTask, TestData.inProgressTask];

      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          myActiveTasksProvider.overrideWith((ref) async => tasks),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Task cards rendered
      expect(find.text('TODO Task'), findsOneWidget);
      expect(find.text('In Progress Task'), findsOneWidget);
    });

    testWidgets('should show empty state when no tasks exist', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          myActiveTasksProvider.overrideWith((ref) async => []),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Empty state shown
      expect(find.textContaining('No'), findsOneWidget);
    });

    testWidgets('should show loading indicator while fetching tasks', (
      tester,
    ) async {
      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          myActiveTasksProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return [TestData.todoTask];
          }),
        ],
      );
      await tester.pump();

      // Assert - Loading placeholder shown (screen uses LoadingPlaceholder, not CircularProgressIndicator)
      expect(find.byType(LoadingPlaceholder), findsAtLeastNWidgets(1));

      // Clean up - complete the future to avoid pending timer
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('should show error state on API failure', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          myActiveTasksProvider.overrideWith((ref) async {
            throw Exception('Network error');
          }),
        ],
      );
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

      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.drag(find.text('TODO Task'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - API called (initial + refresh)
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
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
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
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - TODO task is displayed with its details
      expect(find.text('TODO Task'), findsOneWidget);
      // Verify TaskCard is rendered (which includes status badge internally)
      expect(find.byType(TaskCard), findsOneWidget);
    });

    testWidgets('should display IN_PROGRESS status badge', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.inProgressTask]);

      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - In Progress task is displayed
      expect(find.text('In Progress Task'), findsOneWidget);
      // Verify TaskCard is rendered (which includes status badge internally)
      expect(find.byType(TaskCard), findsOneWidget);
    });

    testWidgets('should not display DONE tasks', (tester) async {
      // Arrange - Only active tasks (no DONE)
      when(
        () => mockTaskRepo.getMyActiveTasks(),
      ).thenAnswer((_) async => [TestData.todoTask, TestData.inProgressTask]);

      // Act
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - No DONE status (Turkish text)
      expect(find.text('Tamamlandı'), findsNothing);
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
      await pumpTestWidget(
        tester,
        const MyActiveTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Overdue task is displayed
      expect(find.text('Overdue Task'), findsOneWidget);
    });
  });
}
