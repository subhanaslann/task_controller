import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/task_card.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('TaskCard Widget Tests', () {
    late Task testTask;

    setUp(() {
      final now = DateTime.now();
      testTask = Task(
        id: 'task-1',
        title: 'Test Task',
        note: 'Test note description',
        topicId: 'topic-1',
        assigneeId: 'user-1',
        status: TaskStatus.todo,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 2)).toIso8601String(),
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        topic: TopicRef(id: 'topic-1', title: 'Development'),
        assignee: Assignee(id: 'user-1', name: 'Test User'),
      );
    });

    testWidgets('renders task title', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(TaskCard(task: testTask));

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('displays priority badge', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(TaskCard(task: testTask));

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('displays status badge', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(TaskCard(task: testTask));

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('To Do'), findsOneWidget);
    });

    testWidgets('displays topic badge when topic exists', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(TaskCard(task: testTask));

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Development'), findsOneWidget);
    });

    testWidgets('displays note when showNote is true', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        TaskCard(task: testTask, showNote: true),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Test note description'), findsOneWidget);
    });

    testWidgets('does not display note when showNote is false', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        TaskCard(task: testTask, showNote: false),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Test note description'), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final widget = createTestWidget(
        TaskCard(
          task: testTask,
          onTap: () => wasTapped = true,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(TaskCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('displays assignee avatar', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(TaskCard(task: testTask));

      // Act
      await tester.pumpWidget(widget);

      // Assert
      // Avatar should display first letter of assignee name "Test User" -> "T"
      expect(find.text('T'), findsWidgets);
    });

    testWidgets('displays different priority colors', (WidgetTester tester) async {
      // Test high priority
      final highPriorityTask = testTask;
      final highWidget = createTestWidget(TaskCard(task: highPriorityTask));
      
      await tester.pumpWidget(highWidget);
      expect(find.text('High'), findsOneWidget);
      
      // Test low priority
      final lowPriorityTask = Task(
        id: 'task-2',
        title: 'Low Priority Task',
        topicId: 'topic-1',
        assigneeId: 'user-1',
        status: TaskStatus.todo,
        priority: Priority.low,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final lowWidget = createTestWidget(TaskCard(task: lowPriorityTask));
      
      await tester.pumpWidget(lowWidget);
      await tester.pump();
      expect(find.text('Low'), findsOneWidget);
    });
  });
}
