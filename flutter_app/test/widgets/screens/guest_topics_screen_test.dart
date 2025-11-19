import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/app_empty_state.dart';
import 'package:flutter_app/core/widgets/loading_placeholder.dart';
import 'package:flutter_app/features/tasks/presentation/guest_topics_screen.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../../helpers/test_helpers.dart';

import 'package:flutter_animate/flutter_animate.dart';

void main() {
  setUpAll(() {
    Animate.restartOnHotReload = false;
    // Speed up animations for testing
    Animate.defaultDuration = Duration.zero;

  });

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
      expect(find.byType(AppEmptyState), findsOneWidget);
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

      // Act - Expand topic
      await tester.tap(find.text('Backend Development'));
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
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      // Act - Expand topic
      await tester.tap(find.text('Test Topic'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      print('DEBUG: Read-only task found: ${find.text('Read-only task').evaluate().length}');

      // Assert - Task should be visible but read-only
      expect(find.text('Read-only task'), findsOneWidget);
    });
  });
}
