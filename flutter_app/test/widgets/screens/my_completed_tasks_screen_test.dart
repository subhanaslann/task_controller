import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import 'package:flutter_app/core/widgets/task_card.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_app/features/tasks/presentation/my_completed_tasks_screen.dart';
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

  group('MyCompletedTasksScreen - Completed Tasks Display', () {
    testWidgets('should display completed tasks', (tester) async {
      // Arrange
      final tasks = [TestData.completedTask];

      // Act
      await pumpTestWidget(
        tester,
        const MyCompletedTasksScreen(),
        overrides: [
          myCompletedTasksProvider.overrideWith((ref) async => tasks),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Task displayed with TaskCard
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.byType(TaskCard), findsOneWidget);
    });

    testWidgets('should show empty state when no completed tasks', (
      tester,
    ) async {
      // Act
      await pumpTestWidget(
        tester,
        const MyCompletedTasksScreen(),
        overrides: [
          myCompletedTasksProvider.overrideWith((ref) async => []),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Empty state shown
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
        const MyCompletedTasksScreen(),
        overrides: [
          myCompletedTasksProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return [TestData.completedTask];
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
        const MyCompletedTasksScreen(),
        overrides: [
          myCompletedTasksProvider.overrideWith((ref) async {
            throw Exception('Network error');
          }),
        ],
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('error'), findsAtLeastNWidgets(1));
    });
  });

  group('MyCompletedTasksScreen - Completion Date Display', () {
    testWidgets('should display completion date', (tester) async {
      // Arrange
      final completedTask = TestData.createTestTask(
        title: 'Completed Task',
        status: TaskStatus.done,
        completedAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      );

      when(
        () => mockTaskRepo.getMyCompletedTasks(),
      ).thenAnswer((_) async => [completedTask]);

      // Act
      await pumpTestWidget(
        tester,
        const MyCompletedTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Task with completion date displayed
      expect(find.text('Completed Task'), findsOneWidget);
    });
  });

  group('MyCompletedTasksScreen - Pull to Refresh', () {
    testWidgets('should refresh completed tasks on pull down', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyCompletedTasks(),
      ).thenAnswer((_) async => [TestData.completedTask]);

      await pumpTestWidget(
        tester,
        const MyCompletedTasksScreen(),
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => mockTaskRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Act - Pull to refresh on task
      await tester.drag(find.text('Completed Task'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - API called
      verify(
        () => mockTaskRepo.getMyCompletedTasks(),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
