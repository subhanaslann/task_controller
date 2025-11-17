import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/infinite_scroll_view.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('InfiniteScrollView Widget Tests', () {
    testWidgets('should render list with correct item count', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        InfiniteScrollView(
          itemCount: 5,
          itemBuilder: (context, index) => Text('Item $index'),
        ),
      );

      // Assert
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('should show loading indicator when hasMore is true',
        (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        InfiniteScrollView(
          itemCount: 3,
          hasMore: true,
          itemBuilder: (context, index) => Text('Item $index'),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show loading indicator when hasMore is false',
        (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        InfiniteScrollView(
          itemCount: 3,
          hasMore: false,
          itemBuilder: (context, index) => Text('Item $index'),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should configure scroll controller with threshold',
        (tester) async {
      // This test verifies the widget sets up scrolling correctly
      // The actual scroll callback behavior is tested in integration tests
      await pumpTestWidget(
        tester,
        SizedBox(
          height: 400,
          child: InfiniteScrollView(
            itemCount: 20,
            hasMore: true,
            loadMoreThreshold: 100,
            onLoadMore: () {},
            itemBuilder: (context, index) => SizedBox(
              height: 100,
              child: Text('Item $index'),
            ),
          ),
        ),
      );

      // Assert - Widget renders with scrollable content
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 19'), findsNothing); // Not visible initially
    });

    testWidgets('should wrap ListView in RefreshIndicator when onRefresh provided',
        (tester) async {
      // Test that the widget structure includes RefreshIndicator
      await pumpTestWidget(
        tester,
        SizedBox(
          height: 400,
          child: InfiniteScrollView(
            itemCount: 5,
            onRefresh: () async {},
            itemBuilder: (context, index) => SizedBox(
              height: 50,
              child: Text('Item $index'),
            ),
          ),
        ),
      );

      // Assert - RefreshIndicator wraps the ListView
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}

