import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/app_skeleton_loader.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppSkeletonLoader Widget Tests', () {
    testWidgets('should render skeleton loader with default card type', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AppSkeletonLoader());

      // Assert
      expect(find.byType(AppSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3)); // default count is 3
    });

    testWidgets('should render skeleton loader with list tile type', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppSkeletonLoader(type: SkeletonType.listTile),
      );

      // Assert
      expect(find.byType(AppSkeletonLoader), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('should render skeleton loader with task card type', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppSkeletonLoader(type: SkeletonType.taskCard),
      );

      // Assert
      expect(find.byType(AppSkeletonLoader), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('should render custom count of skeleton items', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AppSkeletonLoader(type: SkeletonType.card, count: 5),
      );

      // Assert
      expect(find.byType(Card), findsNWidgets(5));
    });
  });
}
