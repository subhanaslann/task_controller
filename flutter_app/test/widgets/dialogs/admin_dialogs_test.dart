import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/admin/presentation/admin_dialogs.dart';
import 'package:flutter_app/core/widgets/app_text_field.dart';
import 'package:flutter_app/data/models/topic.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UserCreateDialog Widget Tests', () {
    testWidgets('should render user creation dialog', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        UserCreateDialog(
          topics: [],
          onSave: (name, username, email, password, role, visibleTopicIds) {},
        ),
      );

      // Assert
      expect(find.text('Create User'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        UserCreateDialog(
          topics: [],
          onSave: (name, username, email, password, role, visibleTopicIds) {},
        ),
      );

      // Assert
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(4));
    });

    testWidgets('should render role selection chips', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        UserCreateDialog(
          topics: [],
          onSave: (name, username, email, password, role, visibleTopicIds) {},
        ),
      );

      // Assert
      expect(find.text('Member'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(2));
    });

    testWidgets('should show topic selector when GUEST role is selected', (
      tester,
    ) async {
      // Arrange
      final topics = [
        Topic(
          id: 'topic1',
          organizationId: 'org1',
          title: 'Backend Development',
          description: null,
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      await pumpTestWidget(
        tester,
        UserCreateDialog(
          topics: topics,
          onSave: (name, username, email, password, role, visibleTopicIds) {},
        ),
      );

      // Act - Select Guest role
      await tester.tap(find.text('Guest'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Allowed Topics:'), findsOneWidget);
      expect(find.text('Backend Development'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        UserCreateDialog(
          topics: [],
          onSave: (name, username, email, password, role, visibleTopicIds) {},
        ),
      );

      // Act - Try to save without filling fields
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert - Should show validation errors
      expect(find.text('Required'), findsWidgets);
    });
  });

  group('TopicCreateDialog Widget Tests', () {
    testWidgets('should render topic creation dialog', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TopicCreateDialog(onSave: (title, description) {}),
      );

      // Assert
      expect(find.text('Create Topic'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TopicCreateDialog(onSave: (title, description) {}),
      );

      // Assert
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(2));
    });


    testWidgets('should validate required title field', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        TopicCreateDialog(onSave: (title, description) {}),
      );

      // Act - Try to save without title
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('TopicEditDialog Widget Tests', () {
    final testTopic = Topic(
      id: 'topic1',
      organizationId: 'org1',
      title: 'Backend Development',
      description: 'API tasks',
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    testWidgets('should render topic edit dialog', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TopicEditDialog(
          topic: testTopic,
          onSave: (topicId, title, description, isActive) {},
        ),
      );

      // Assert
      expect(find.text('Edit Topic'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should pre-fill form with topic data', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TopicEditDialog(
          topic: testTopic,
          onSave: (topicId, title, description, isActive) {},
        ),
      );

      // Assert
      expect(find.text('Backend Development'), findsOneWidget);
      expect(find.text('API tasks'), findsOneWidget);
    });
  });

  group('TaskCreateDialog Widget Tests', () {
    testWidgets('should render task creation dialog', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TaskCreateDialog(
          topics: [],
          users: [],
          onSave:
              (title, topicId, note, assigneeId, status, priority, dueDate) {},
        ),
      );

      // Assert
      expect(find.text('Create Task'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TaskCreateDialog(
          topics: [],
          users: [],
          onSave:
              (title, topicId, note, assigneeId, status, priority, dueDate) {},
        ),
      );

      // Assert
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Priority:'), findsOneWidget);
      expect(find.text('Status:'), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(2));
    });

    testWidgets('should render priority selection chips', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TaskCreateDialog(
          topics: [],
          users: [],
          onSave:
              (title, topicId, note, assigneeId, status, priority, dueDate) {},
        ),
      );

      // Assert
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('NORMAL'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('should render status selection chips', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        TaskCreateDialog(
          topics: [],
          users: [],
          onSave:
              (title, topicId, note, assigneeId, status, priority, dueDate) {},
        ),
      );

      // Assert
      expect(find.text('TODO'), findsOneWidget);
      expect(find.text('IN_PROGRESS'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
    });

    testWidgets('should validate required title field', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        TaskCreateDialog(
          topics: [],
          users: [],
          onSave:
              (title, topicId, note, assigneeId, status, priority, dueDate) {},
        ),
      );

      // Act - Try to save without title
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
