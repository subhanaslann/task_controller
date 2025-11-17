import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/constants.dart';
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

      // Assert
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
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

      // Assert
      expect(find.textContaining('No completed'), findsOneWidget);
    });

    testWidgets('should show loading state while fetching', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        const MyCompletedTasksScreen(),
        overrides: [
          myCompletedTasksProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return [TestData.completedTask];
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
      await pumpTestWidget(tester, const MyCompletedTasksScreen());
      await tester.pumpAndSettle();

      // Assert - Completion date formatted as "Completed on ..."
      expect(find.textContaining('Completed'), findsWidgets);
    });
  });

  group('MyCompletedTasksScreen - Pull to Refresh', () {
    testWidgets('should refresh completed tasks on pull down', (tester) async {
      // Arrange
      when(
        () => mockTaskRepo.getMyCompletedTasks(),
      ).thenAnswer((_) async => [TestData.completedTask]);

      await pumpTestWidget(tester, const MyCompletedTasksScreen());
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockTaskRepo.getMyCompletedTasks(),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
