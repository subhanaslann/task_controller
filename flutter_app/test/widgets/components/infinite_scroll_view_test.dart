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

    testWidgets('should trigger onLoadMore when scrolling near bottom',
        (tester) async {
      // Arrange
      var loadMoreCalled = false;
      await pumpTestWidget(
        tester,
        SizedBox(
          height: 400,
          child: InfiniteScrollView(
            itemCount: 20,
            hasMore: true,
            loadMoreThreshold: 100,
            onLoadMore: () {
              loadMoreCalled = true;
            },
            itemBuilder: (context, index) => SizedBox(
              height: 100,
              child: Text('Item $index'),
            ),
          ),
        ),
      );

      // Act - Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(loadMoreCalled, true);
    });

    testWidgets('should support pull to refresh', (tester) async {
      // Arrange
      var refreshCalled = false;
      await pumpTestWidget(
        tester,
        InfiniteScrollView(
          itemCount: 5,
          onRefresh: () async {
            refreshCalled = true;
          },
          itemBuilder: (context, index) => Text('Item $index'),
        ),
      );

      // Act
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(refreshCalled, true);
    });
  });
}

