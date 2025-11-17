import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/tasks/presentation/member_task_dialog.dart';
import 'package:flutter_app/core/widgets/app_button.dart';
import 'package:flutter_app/core/widgets/app_text_field.dart';
import 'package:flutter_app/core/providers/providers.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/core/utils/constants.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MemberTaskDialog Widget Tests', () {
    final testUser = User(
      id: 'user1',
      organizationId: 'org1',
      name: 'Test User',
      username: 'testuser',
      email: 'test@example.com',
      role: UserRole.member,
      active: true,
      visibleTopicIds: const [],
    );

    testWidgets('should render create task dialog', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert
      expect(find.text('Görev Ekle: Backend Development'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should render all form fields', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert
      expect(find.text('Görev Başlığı'), findsOneWidget);
      expect(find.text('Not (opsiyonel)'), findsOneWidget);
      expect(find.text('Öncelik'), findsOneWidget);
      expect(find.text('Bitiş Tarihi *'), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(2));
    });

    testWidgets('should render priority selection chips', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert
      expect(find.text('Düşük'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Yüksek'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(3));
    });

    testWidgets('should have normal priority selected by default', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert - Normal chip should be selected
      final normalChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Normal'),
      );
      expect(normalChip.selected, true);
    });

    testWidgets('should render date picker button', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert
      expect(find.text('Tarih Seç'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('should render cancel and create buttons', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Assert
      expect(find.text('İptal'), findsOneWidget);
      expect(find.text('Ekle'), findsOneWidget);
    });

    testWidgets('should validate required title field', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Act - Try to submit without title
      await tester.tap(find.text('Ekle'));
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        MemberTaskDialog(
          topicId: 'topic1',
          topicTitle: 'Backend Development',
          onTaskCreated: () {},
        ),
        overrides: [currentUserProvider.overrideWith((ref) => testUser)],
      );

      // Act
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
