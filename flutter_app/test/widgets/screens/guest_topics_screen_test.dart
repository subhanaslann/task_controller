import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        overrides: [
          guestTopicsProvider.overrideWith((ref) => const AsyncValue.data([])),
        ],
      );

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No Topics'), findsOneWidget);
      expect(find.byIcon(Icons.topic), findsOneWidget);
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
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tasks: [],
        ),
        Topic(
          id: '2',
          organizationId: 'org1',
          title: 'Frontend Development',
          description: 'UI tasks',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tasks: [],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith((ref) => AsyncValue.data(topics)),
        ],
      );

      // Assert
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
        priority: TaskPriority.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Backend Development',
          description: 'API tasks',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tasks: [task],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith((ref) => AsyncValue.data(topics)),
        ],
      );

      // Assert
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
            (ref) => AsyncValue.error('Network error', StackTrace.current),
          ),
        ],
      );

      // Assert
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
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
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tasks: [],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith((ref) => AsyncValue.data(topics)),
        ],
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
        priority: TaskPriority.normal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final topics = [
        Topic(
          id: '1',
          organizationId: 'org1',
          title: 'Test Topic',
          description: 'Description',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tasks: [task],
        ),
      ];

      await pumpTestWidget(
        tester,
        const GuestTopicsScreen(),
        overrides: [
          guestTopicsProvider.overrideWith((ref) => AsyncValue.data(topics)),
        ],
      );

      // Assert - Task should be visible but read-only
      expect(find.text('Read-only task'), findsOneWidget);
    });
  });
}
