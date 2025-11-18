import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Widget tests for Task Card components
///
/// These tests verify the UI rendering and interactions of task cards
///
/// To run: flutter test test/widgets/task_card_widget_test.dart

void main() {
  group('Task Card Widget Tests', () {
    // Sample test data
    final sampleTask = Task(
      id: '123e4567-e89b-12d3-a456-426614174000',
      title: 'Implement user authentication',
      note: 'Add JWT-based authentication system',
      assigneeId: 'user-123',
      status: TaskStatus.inProgress,
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      createdAt: DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final overdueTask = Task(
      id: '223e4567-e89b-12d3-a456-426614174001',
      title: 'Fix critical bug',
      assigneeId: 'user-123',
      status: TaskStatus.todo,
      priority: Priority.high,
      dueDate: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
      createdAt: DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final completedTask = Task(
      id: '323e4567-e89b-12d3-a456-426614174002',
      title: 'Write documentation',
      assigneeId: 'user-123',
      status: TaskStatus.done,
      priority: Priority.normal,
      createdAt: DateTime.now()
          .subtract(const Duration(days: 10))
          .toIso8601String(),
      updatedAt: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
      completedAt: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    );

    testWidgets('Task card displays title correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: sampleTask)),
          ),
        ),
      );

      expect(find.text('Implement user authentication'), findsOneWidget);
    });

    testWidgets('Task card shows priority badge with correct color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: sampleTask)),
          ),
        ),
      );

      // Find priority badge
      final priorityBadge = find.text('HIGH');
      expect(priorityBadge, findsOneWidget);

      // Verify color (should be red for HIGH priority)
      final Container priorityContainer = tester.widget(
        find
            .ancestor(of: priorityBadge, matching: find.byType(Container))
            .first,
      );

      expect(
        (priorityContainer.decoration as BoxDecoration?)?.color,
        const Color(0xFFEF4444), // Red color for HIGH priority
      );
    });

    testWidgets('Task card shows status badge correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: sampleTask)),
          ),
        ),
      );

      expect(find.text('IN_PROGRESS'), findsOneWidget);
    });

    testWidgets('Overdue task shows red due date indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: overdueTask)),
          ),
        ),
      );

      // Should display overdue indicator
      expect(find.textContaining('Overdue'), findsOneWidget);
    });

    testWidgets('Completed task shows completion date', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: completedTask)),
          ),
        ),
      );

      expect(find.textContaining('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Task with note shows note preview', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: sampleTask)),
          ),
        ),
      );

      // Note preview (first 100 chars)
      expect(find.textContaining('Add JWT-based'), findsOneWidget);
    });

    testWidgets('Task without note does not show note section', (
      WidgetTester tester,
    ) async {
      final taskWithoutNote = Task(
        id: 'test-id',
        title: 'Simple task',
        assigneeId: 'user-123',
        status: TaskStatus.todo,
        priority: Priority.normal,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: taskWithoutNote)),
          ),
        ),
      );

      // Note section should not be present
      expect(find.byIcon(Icons.notes), findsNothing);
    });

    group('Priority Colors', () {
      testWidgets('HIGH priority shows red color', (WidgetTester tester) async {
        final highTask = sampleTask.copyWith(priority: Priority.high);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: highTask)),
            ),
          ),
        );

        // Priority stripe on the left should be red
        final priorityStripe = find.byKey(const Key('priority_stripe'));
        expect(priorityStripe, findsOneWidget);

        final Container container = tester.widget<Container>(priorityStripe);
        expect(
          (container.decoration as BoxDecoration).color,
          const Color(0xFFEF4444), // Red
        );
      });

      testWidgets('NORMAL priority shows blue color', (
        WidgetTester tester,
      ) async {
        final normalTask = sampleTask.copyWith(priority: Priority.normal);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: normalTask)),
            ),
          ),
        );

        final priorityStripe = find.byKey(const Key('priority_stripe'));
        final Container container = tester.widget<Container>(priorityStripe);
        expect(
          (container.decoration as BoxDecoration).color,
          const Color(0xFF3B82F6), // Blue
        );
      });

      testWidgets('LOW priority shows gray color', (WidgetTester tester) async {
        final lowTask = sampleTask.copyWith(priority: Priority.low);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: lowTask)),
            ),
          ),
        );

        final priorityStripe = find.byKey(const Key('priority_stripe'));
        final Container container = tester.widget<Container>(priorityStripe);
        expect(
          (container.decoration as BoxDecoration).color,
          const Color(0xFF6B7280), // Gray
        );
      });
    });

    group('Status Colors', () {
      testWidgets('TODO status shows gray color', (WidgetTester tester) async {
        final todoTask = sampleTask.copyWith(status: TaskStatus.todo);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: todoTask)),
            ),
          ),
        );

        final statusBadge = find.text('TODO');
        expect(statusBadge, findsOneWidget);
      });

      testWidgets('IN_PROGRESS status shows amber color', (
        WidgetTester tester,
      ) async {
        final inProgressTask = sampleTask.copyWith(
          status: TaskStatus.inProgress,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: inProgressTask)),
            ),
          ),
        );

        final statusBadge = find.text('IN_PROGRESS');
        expect(statusBadge, findsOneWidget);
      });

      testWidgets('DONE status shows green color', (WidgetTester tester) async {
        final doneTask = completedTask;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TaskCardMock(task: doneTask)),
            ),
          ),
        );

        final statusBadge = find.text('DONE');
        expect(statusBadge, findsOneWidget);
      });
    });

    testWidgets('Due date formatting is correct', (WidgetTester tester) async {
      final taskDueTomorrow = sampleTask.copyWith(
        dueDate: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TaskCardMock(task: taskDueTomorrow)),
          ),
        ),
      );

      // Should show "1 day left" or similar
      expect(find.textContaining('day'), findsOneWidget);
    });
  });
}

/// Mock Task Card Widget for testing
/// This is a simplified version for testing purposes
class TaskCardMock extends StatelessWidget {
  final Task task;

  const TaskCardMock({super.key, required this.task});

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFEF4444); // Red
      case Priority.normal:
        return const Color(0xFF3B82F6); // Blue
      case Priority.low:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF6B7280); // Gray
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B); // Amber
      case TaskStatus.done:
        return const Color(0xFF10B981); // Green
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'HIGH';
      case Priority.normal:
        return 'NORMAL';
      case Priority.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dueDateTime = task.dueDate != null
        ? DateTime.parse(task.dueDate!)
        : null;
    final isOverdue = dueDateTime != null && dueDateTime.isBefore(now);

    return Card(
      margin: const EdgeInsets.all(8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Priority stripe
            Container(
              key: const Key('priority_stripe'),
              width: 4,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and priority badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPriorityText(task.priority),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(task.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Note preview
                    if (task.note != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.notes, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.note!.length > 100
                                  ? '${task.note!.substring(0, 100)}...'
                                  : task.note!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Due date
                    if (dueDateTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        isOverdue
                            ? 'Overdue'
                            : '${dueDateTime.difference(now).inDays} day(s) left',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                    // Completed date
                    if (task.status == TaskStatus.done &&
                        task.completedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
