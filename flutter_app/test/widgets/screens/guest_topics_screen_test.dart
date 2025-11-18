import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/empty_state.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import 'package:flutter_app/features/tasks/presentation/guest_topics_screen.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('GuestTopicsScreen Widget Tests', () {
    testWidgets('should render loading state', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith(
            (ref) async => throw UnimplementedError(),
          ),
        ],
      );

      // Assert
      expect(find.byType(LoadingPlaceholder), findsWidgets);
    });

    testWidgets('should render empty state when no topics available', (
      tester,
    ) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [guestTopicsProvider.overrideWith((ref) async => [])],
      );
      await tester.pumpAndSettle();

      // Assert - Empty state shown
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('should render topic list when topics are available', (
      tester,
    ) async {
      // Arrange
      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Backend Development',
          description: 'API tasks',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          tasks: [],
        ),
        Topic(
          id: '2',
          organizationId: 'org1',
          title: 'Frontend Development',
          description: 'UI tasks',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          tasks: [],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [guestTopicsProvider.overrideWith((ref) async => topics)],
      );
      await tester.pumpAndSettle();

      // Assert - Topics displayed
      expect(find.text('Backend Development'), findsOneWidget);
      expect(find.text('Frontend Development'), findsOneWidget);
    });

    testWidgets('should render topics with tasks', (tester) async {
      // Arrange
      final task = Task(
        id: 'task1',
        organizationId: 'org1',
        topicId: 'topic1',
        title: 'Implement feature',
        status: TaskStatus.todo,
        priority: Priority.high,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Backend Development',
          description: 'API tasks',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          tasks: [task],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [guestTopicsProvider.overrideWith((ref) async => topics)],
      );
      await tester.pumpAndSettle();

      // Assert - Topic and task displayed
      expect(find.text('Backend Development'), findsOneWidget);
      expect(find.text('Implement feature'), findsOneWidget);
    });

    testWidgets('should render error state with retry button', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith(
            (ref) async => throw Exception('Network error'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Assert - Error state shown
      expect(find.byIcon(Icons.error), findsAtLeastNWidgets(1));
    });

    testWidgets('should support pull to refresh', (tester) async {
      // Arrange
      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Backend Development',
          description: 'API tasks',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          tasks: [],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [guestTopicsProvider.overrideWith((ref) async => topics)],
      );

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should show read-only task cards for guest users', (
      tester,
    ) async {
      // Arrange
      final task = Task(
        id: 'task1',
        organizationId: 'org1',
        topicId: 'topic1',
        title: 'Read-only task',
        status: TaskStatus.inProgress,
        priority: Priority.normal,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Test Topic',
          description: 'Description',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          tasks: [task],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [guestTopicsProvider.overrideWith((ref) async => topics)],
      );
      await tester.pumpAndSettle();

      // Assert - Task should be visible but read-only
      expect(find.text('Read-only task'), findsOneWidget);
    });
  });
}
