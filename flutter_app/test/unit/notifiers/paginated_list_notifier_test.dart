import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/notifiers/paginated_list_notifier.dart';
import 'package:flutter_app/core/utils/paginated_list_state.dart';

// ==================== TEST IMPLEMENTATION ====================

/// Concrete test implementation of PaginatedListNotifier
class TestPaginatedListNotifier extends PaginatedListNotifier<String> {
  /// Mock fetch function for testing
  late Future<List<String>> Function({
    required int page,
    required int pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) mockFetchItems;

  @override
  Future<List<String>> fetchItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    return mockFetchItems(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      filters: filters,
    );
  }
}

// ==================== TESTS ====================

void main() {
  late TestPaginatedListNotifier notifier;

  setUp(() {
    notifier = TestPaginatedListNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  // ==================== GROUP 1: INITIALIZATION TESTS ====================
  group('Initialization Tests', () {
    test('initial state is empty', () {
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.isLoadingInitial, false);
      expect(notifier.state.isLoadingMore, false);
      expect(notifier.state.isRefreshing, false);
      expect(notifier.state.hasMore, true);
      expect(notifier.state.currentPage, 0);
      expect(notifier.state.error, isNull);
      expect(notifier.state.searchQuery, '');
      expect(notifier.state.filters, isNull);
    });

    test('initial state computed getters are correct', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isEmpty, true);
      expect(notifier.state.hasError, false);
      expect(notifier.state.hasData, false);
    });

    test('state equality works correctly', () {
      final state1 = PaginatedListState<String>(items: const ['a', 'b']);
      final state2 = PaginatedListState<String>(items: const ['a', 'b']);
      final state3 = PaginatedListState<String>(items: const ['a', 'c']);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('state copyWith preserves unmodified values', () {
      final original = PaginatedListState<String>(
        items: const ['a'],
        currentPage: 5,
        searchQuery: 'test',
      );

      final copied = original.copyWith(items: const ['b']);

      expect(copied.currentPage, 5);
      expect(copied.searchQuery, 'test');
      expect(copied.items, const ['b']);
    });

    test('state copyWith can set error to null explicitly', () {
      final original = PaginatedListState<String>(error: 'Some error');
      final copied = original.copyWith(error: null);

      expect(copied.error, isNull);
    });

    test('isLoading is true when isLoadingInitial is true', () {
      final state = PaginatedListState<String>(isLoadingInitial: true);
      expect(state.isLoading, true);
    });

    test('isLoading is true when isLoadingMore is true', () {
      final state = PaginatedListState<String>(isLoadingMore: true);
      expect(state.isLoading, true);
    });

    test('isLoading is true when isRefreshing is true', () {
      final state = PaginatedListState<String>(isRefreshing: true);
      expect(state.isLoading, true);
    });

    test('isEmpty is false when items exist', () {
      final state = PaginatedListState<String>(items: const ['a']);
      expect(state.isEmpty, false);
    });

    test('isEmpty is false when loading', () {
      final state = PaginatedListState<String>(isLoadingInitial: true);
      expect(state.isEmpty, false);
    });
  });

  // ==================== GROUP 2: LOADINITIAL TESTS ====================
  group('loadInitial Tests', () {
    test('loadInitial fetches and updates state successfully', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        expect(page, 0);
        expect(pageSize, 20);
        return List.generate(20, (i) => 'Item $i');
      };

      await notifier.loadInitial();

      expect(notifier.state.items, hasLength(20));
      expect(notifier.state.isLoadingInitial, false);
      expect(notifier.state.currentPage, 0);
      expect(notifier.state.hasMore, true); // 20 items = full page
      expect(notifier.state.error, isNull);
    });

    test('loadInitial sets hasMore to false when less than pageSize', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(15, (i) => 'Item $i'); // Less than 20
      };

      await notifier.loadInitial();

      expect(notifier.state.items, hasLength(15));
      expect(notifier.state.hasMore, false); // Less than pageSize
    });

    test('loadInitial sets hasMore to false when empty', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };

      await notifier.loadInitial();

      expect(notifier.state.items, isEmpty);
      expect(notifier.state.hasMore, false);
    });

    test('loadInitial handles error correctly', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Network error');
      };

      await notifier.loadInitial();

      expect(notifier.state.error, contains('Network error'));
      expect(notifier.state.isLoadingInitial, false);
      expect(notifier.state.items, isEmpty);
    });

    test('loadInitial does not run if already loading', () async {
      var callCount = 0;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        await Future.delayed(Duration(milliseconds: 100));
        return ['Item'];
      };

      // Start two concurrent loads
      final future1 = notifier.loadInitial();
      final future2 = notifier.loadInitial();

      await Future.wait([future1, future2]);

      // Should only call once due to isLoading guard
      expect(callCount, 1);
    });

    test('loadInitial passes searchQuery to fetchItems', () async {
      String? capturedQuery;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        return [];
      };

      await notifier.loadInitial(searchQuery: 'test query');

      expect(capturedQuery, 'test query');
      expect(notifier.state.searchQuery, 'test query');
    });

    test('loadInitial passes filters to fetchItems', () async {
      Map<String, dynamic>? capturedFilters;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      final testFilters = {'status': 'active', 'priority': 'high'};
      await notifier.loadInitial(filters: testFilters);

      expect(capturedFilters, testFilters);
      expect(notifier.state.filters, testFilters);
    });

    test('loadInitial uses existing searchQuery when not provided', () async {
      // Set initial search query
      await notifier.loadInitial(searchQuery: 'existing');

      String? capturedQuery;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        return [];
      };

      // Load again without searchQuery parameter
      await notifier.loadInitial();

      expect(capturedQuery, 'existing');
    });

    test('loadInitial uses existing filters when not provided', () async {
      // Set initial filters
      final existingFilters = {'status': 'active'};
      await notifier.loadInitial(filters: existingFilters);

      Map<String, dynamic>? capturedFilters;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      // Load again without filters parameter
      await notifier.loadInitial();

      expect(capturedFilters, existingFilters);
    });

    test('loadInitial sets isLoadingInitial during fetch', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        await Future.delayed(Duration(milliseconds: 50));
        return [];
      };

      final future = notifier.loadInitial();

      // Check state during loading
      await Future.delayed(Duration(milliseconds: 10));
      expect(notifier.state.isLoadingInitial, true);

      await future;
      expect(notifier.state.isLoadingInitial, false);
    });

    test('loadInitial clears previous error on success', () async {
      // First call fails
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Error');
      };
      await notifier.loadInitial();
      expect(notifier.state.error, isNotNull);

      // Second call succeeds
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['Item'];
      };
      await notifier.loadInitial();

      expect(notifier.state.error, isNull);
    });

    test('loadInitial preserves items on error (keeps old data)', () async {
      // First successful load
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['Old Item'];
      };
      await notifier.loadInitial();

      // Second load fails - but conceptually error path doesn't update items
      // Actually looking at code, error path doesn't set items, so they stay as-is
      // But in practice, initial load would clear items before trying... let me check code
      // Looking at loadInitial: it only sets items in the success case
      // So if error occurs, items from before should remain (not explicitly cleared)

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Error');
      };
      await notifier.loadInitial();

      expect(notifier.state.items, hasLength(1)); // Old items preserved
      expect(notifier.state.error, isNotNull);
    });
  });

  // ==================== GROUP 3: LOADMORE TESTS ====================
  group('loadMore Tests', () {
    setUp(() async {
      // Pre-load initial data for loadMore tests
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        if (page == 0) {
          return List.generate(20, (i) => 'Page0-Item$i');
        }
        return [];
      };
      await notifier.loadInitial();
    });

    test('loadMore fetches next page and appends items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        expect(page, 1);
        return List.generate(20, (i) => 'Page1-Item$i');
      };

      await notifier.loadMore();

      expect(notifier.state.items, hasLength(40)); // 20 + 20
      expect(notifier.state.currentPage, 1);
      expect(notifier.state.hasMore, true);
    });

    test('loadMore sets hasMore to false when partial page received', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(10, (i) => 'Page1-Item$i'); // Less than 20
      };

      await notifier.loadMore();

      expect(notifier.state.items, hasLength(30)); // 20 + 10
      expect(notifier.state.hasMore, false);
    });

    test('loadMore sets hasMore to false when no more items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };

      await notifier.loadMore();

      expect(notifier.state.items, hasLength(20)); // Original 20
      expect(notifier.state.hasMore, false);
    });

    test('loadMore does not run if already loading', () async {
      var callCount = 0;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        await Future.delayed(Duration(milliseconds: 100));
        return ['Item'];
      };

      // Start two concurrent loadMore calls
      final future1 = notifier.loadMore();
      final future2 = notifier.loadMore();

      await Future.wait([future1, future2]);

      // Should only call once
      expect(callCount, 1);
    });

    test('loadMore does not run if hasMore is false', () async {
      // Set hasMore to false
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return []; // Empty = hasMore false
      };
      await notifier.loadInitial();
      expect(notifier.state.hasMore, false);

      // Try to load more
      var called = false;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        called = true;
        return [];
      };

      await notifier.loadMore();

      expect(called, false); // Should not call fetchItems
    });

    test('loadMore handles error and preserves items', () async {
      final initialItemCount = notifier.state.items.length;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Network error');
      };

      await notifier.loadMore();

      expect(notifier.state.error, contains('Network error'));
      expect(notifier.state.isLoadingMore, false);
      expect(notifier.state.items, hasLength(initialItemCount)); // Items preserved
    });

    test('loadMore sets isLoadingMore during fetch', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        await Future.delayed(Duration(milliseconds: 50));
        return [];
      };

      final future = notifier.loadMore();

      await Future.delayed(Duration(milliseconds: 10));
      expect(notifier.state.isLoadingMore, true);

      await future;
      expect(notifier.state.isLoadingMore, false);
    });

    test('loadMore passes current searchQuery and filters', () async {
      String? capturedQuery;
      Map<String, dynamic>? capturedFilters;

      // Set search and filters
      final filters = {'status': 'active'};
      await notifier.loadInitial(searchQuery: 'test', filters: filters);

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        if (page == 1) {
          capturedQuery = searchQuery;
          capturedFilters = filters;
        }
        return [];
      };

      await notifier.loadMore();

      expect(capturedQuery, 'test');
      expect(capturedFilters, filters);
    });

    test('loadMore increments currentPage correctly', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Item$i');
      };

      await notifier.loadMore();
      expect(notifier.state.currentPage, 1);

      await notifier.loadMore();
      expect(notifier.state.currentPage, 2);

      await notifier.loadMore();
      expect(notifier.state.currentPage, 3);
    });

    test('loadMore clears error on successful fetch', () async {
      // First loadMore fails
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Error');
      };
      await notifier.loadMore();
      expect(notifier.state.error, isNotNull);

      // Second loadMore succeeds
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['New Item'];
      };
      await notifier.loadMore();

      expect(notifier.state.error, isNull);
    });
  });

  // ==================== GROUP 4: REFRESH TESTS ====================
  group('refresh Tests', () {
    setUp(() async {
      // Pre-load initial data
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Initial$i');
      };
      await notifier.loadInitial();
    });

    test('refresh fetches page 0 and replaces items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        expect(page, 0);
        return List.generate(20, (i) => 'Refreshed$i');
      };

      await notifier.refresh();

      expect(notifier.state.items.first, 'Refreshed0');
      expect(notifier.state.currentPage, 0);
      expect(notifier.state.isRefreshing, false);
    });

    test('refresh clears error on success', () async {
      // Set error state
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Error');
      };
      await notifier.loadMore();
      expect(notifier.state.error, isNotNull);

      // Refresh successfully
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['Item'];
      };
      await notifier.refresh();

      expect(notifier.state.error, isNull);
    });

    test('refresh handles error correctly', () async {
      final originalItems = List.from(notifier.state.items);

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Refresh error');
      };

      await notifier.refresh();

      expect(notifier.state.error, contains('Refresh error'));
      expect(notifier.state.isRefreshing, false);
      expect(notifier.state.items, originalItems); // Items preserved
    });

    test('refresh does not run if already loading initial', () async {
      var callCount = 0;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        await Future.delayed(Duration(milliseconds: 100));
        return ['Item'];
      };

      // Start loadInitial
      final future1 = notifier.loadInitial();
      // Try refresh while loading
      final future2 = notifier.refresh();

      await Future.wait([future1, future2]);

      // Should only call once (loadInitial)
      expect(callCount, 1);
    });

    test('refresh does not run if already loading more', () async {
      var callCount = 0;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        await Future.delayed(Duration(milliseconds: 100));
        return List.generate(20, (i) => 'Item$i');
      };

      // Start loadMore
      final future1 = notifier.loadMore();
      // Try refresh while loading
      final future2 = notifier.refresh();

      await Future.wait([future1, future2]);

      // Should only call once (loadMore)
      expect(callCount, 1);
    });

    test('refresh sets isRefreshing during fetch', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        await Future.delayed(Duration(milliseconds: 50));
        return [];
      };

      final future = notifier.refresh();

      await Future.delayed(Duration(milliseconds: 10));
      expect(notifier.state.isRefreshing, true);

      await future;
      expect(notifier.state.isRefreshing, false);
    });

    test('refresh preserves searchQuery and filters', () async {
      String? capturedQuery;
      Map<String, dynamic>? capturedFilters;

      // Set search and filters
      final filters = {'status': 'active'};
      await notifier.loadInitial(searchQuery: 'test', filters: filters);

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        capturedFilters = filters;
        return [];
      };

      await notifier.refresh();

      expect(capturedQuery, 'test');
      expect(capturedFilters, filters);
      expect(notifier.state.searchQuery, 'test');
      expect(notifier.state.filters, filters);
    });

    test('refresh resets hasMore based on result count', () async {
      // Full page = hasMore true
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Item$i');
      };
      await notifier.refresh();
      expect(notifier.state.hasMore, true);

      // Partial page = hasMore false
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(10, (i) => 'Item$i');
      };
      await notifier.refresh();
      expect(notifier.state.hasMore, false);
    });
  });

  // ==================== GROUP 5: SEARCH TESTS ====================
  group('search Tests', () {
    test('search triggers loadInitial with query', () async {
      String? capturedQuery;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        return [];
      };

      notifier.search('test query');

      // Wait for debounce (300ms)
      await Future.delayed(Duration(milliseconds: 350));

      expect(capturedQuery, 'test query');
      expect(notifier.state.searchQuery, 'test query');
    });

    test('search is debounced', () async {
      var callCount = 0;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        return [];
      };

      // Rapid fire searches
      notifier.search('a');
      notifier.search('ab');
      notifier.search('abc');
      notifier.search('abcd');

      // Wait for debounce
      await Future.delayed(Duration(milliseconds: 350));

      // Should only call once with last query
      expect(callCount, 1);
      expect(notifier.state.searchQuery, 'abcd');
    });

    test('search with empty string works', () async {
      String? capturedQuery;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        return [];
      };

      notifier.search('');

      await Future.delayed(Duration(milliseconds: 350));

      expect(capturedQuery, '');
      expect(notifier.state.searchQuery, '');
    });

    test('clearSearch clears search query', () async {
      // Set search first
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };

      notifier.search('test');
      await Future.delayed(Duration(milliseconds: 350));
      expect(notifier.state.searchQuery, 'test');

      // Clear search
      notifier.clearSearch();
      await Future.delayed(Duration(milliseconds: 50)); // Wait for loadInitial

      expect(notifier.state.searchQuery, '');
    });

    test('clearSearch triggers loadInitial', () async {
      var callCount = 0;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        return [];
      };

      notifier.clearSearch();
      await Future.delayed(Duration(milliseconds: 50)); // Wait for loadInitial

      expect(callCount, 1);
    });

    test('multiple rapid searches only execute last one', () async {
      final executedQueries = <String>[];

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        if (searchQuery != null) {
          executedQueries.add(searchQuery);
        }
        return [];
      };

      notifier.search('query1');
      await Future.delayed(Duration(milliseconds: 50));
      notifier.search('query2');
      await Future.delayed(Duration(milliseconds: 50));
      notifier.search('query3');

      await Future.delayed(Duration(milliseconds: 350));

      // Only last search should execute
      expect(executedQueries, ['query3']);
    });
  });

  // ==================== GROUP 6: FILTERS TESTS ====================
  group('filters Tests', () {
    test('updateFilters triggers loadInitial with new filters', () async {
      Map<String, dynamic>? capturedFilters;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      final newFilters = {'status': 'active', 'priority': 'high'};
      notifier.updateFilters(newFilters);
      await Future.delayed(Duration(milliseconds: 50)); // Wait for loadInitial

      expect(capturedFilters, newFilters);
      expect(notifier.state.filters, newFilters);
    });

    test('updateFilters replaces existing filters', () async {
      // Set initial filters
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };

      notifier.updateFilters({'old': 'value'});
      await Future.delayed(Duration(milliseconds: 50));

      // Update with new filters
      final newFilters = {'new': 'value'};
      notifier.updateFilters(newFilters);
      await Future.delayed(Duration(milliseconds: 50));

      expect(notifier.state.filters, newFilters);
      expect(notifier.state.filters, isNot(contains('old')));
    });

    test('clearFilters sets filters to empty map', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };

      // Set filters first
      notifier.updateFilters({'status': 'active'});
      await Future.delayed(Duration(milliseconds: 50));
      expect(notifier.state.filters, isNotEmpty);

      // Clear filters
      notifier.clearFilters();
      await Future.delayed(Duration(milliseconds: 50));

      expect(notifier.state.filters, isEmpty);
    });

    test('clearFilters triggers loadInitial', () async {
      var callCount = 0;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        callCount++;
        return [];
      };

      notifier.clearFilters();
      await Future.delayed(Duration(milliseconds: 50)); // Wait for loadInitial

      expect(callCount, 1);
    });

    test('filters persist across loadMore', () async {
      final testFilters = {'status': 'active'};

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Item$i');
      };

      await notifier.loadInitial(filters: testFilters);

      Map<String, dynamic>? capturedFilters;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      await notifier.loadMore();

      expect(capturedFilters, testFilters);
    });

    test('filters persist across refresh', () async {
      final testFilters = {'status': 'active'};

      await notifier.loadInitial(filters: testFilters);

      Map<String, dynamic>? capturedFilters;
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      await notifier.refresh();

      expect(capturedFilters, testFilters);
    });

    test('can combine search and filters', () async {
      String? capturedQuery;
      Map<String, dynamic>? capturedFilters;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedQuery = searchQuery;
        capturedFilters = filters;
        return [];
      };

      final testFilters = {'status': 'active'};
      await notifier.loadInitial(searchQuery: 'test', filters: testFilters);

      expect(capturedQuery, 'test');
      expect(capturedFilters, testFilters);
      expect(notifier.state.searchQuery, 'test');
      expect(notifier.state.filters, testFilters);
    });

    test('empty filters map is different from null filters', () async {
      Map<String, dynamic>? capturedFilters;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        capturedFilters = filters;
        return [];
      };

      // Start with null filters
      await notifier.loadInitial();
      expect(capturedFilters, isNull);

      // Set empty filters
      notifier.clearFilters();
      await Future.delayed(Duration(milliseconds: 50)); // Wait for loadInitial

      expect(notifier.state.filters, isNotNull);
      expect(notifier.state.filters, isEmpty);
    });
  });

  // ==================== GROUP 7: EDGE CASES AND INTEGRATION ====================
  group('Edge Cases and Integration Tests', () {
    setUp(() {
      // Provide default mock implementation
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return [];
      };
    });

    test('concurrent loadInitial and loadMore only runs loadInitial', () async {
      var loadInitialCalled = false;
      var loadMoreCalled = false;

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        if (page == 0) loadInitialCalled = true;
        if (page == 1) loadMoreCalled = true;
        await Future.delayed(Duration(milliseconds: 100));
        return List.generate(20, (i) => 'Item$i');
      };

      final future1 = notifier.loadInitial();
      await Future.delayed(Duration(milliseconds: 10));
      final future2 = notifier.loadMore(); // Should be ignored

      await Future.wait([future1, future2]);

      expect(loadInitialCalled, true);
      expect(loadMoreCalled, false);
    });

    test('state transitions through loading states correctly', () async {
      final states = <bool>[];

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        await Future.delayed(Duration(milliseconds: 50));
        return ['Item'];
      };

      states.add(notifier.state.isLoadingInitial);

      final future = notifier.loadInitial();
      await Future.delayed(Duration(milliseconds: 10));

      states.add(notifier.state.isLoadingInitial);

      await future;
      states.add(notifier.state.isLoadingInitial);

      expect(states, [false, true, false]);
    });

    test('hasMore correctly handles exactly pageSize items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Item$i'); // Exactly 20
      };

      await notifier.loadInitial();
      expect(notifier.state.hasMore, true);
    });

    test('hasMore correctly handles pageSize+1 items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(21, (i) => 'Item$i'); // More than 20
      };

      await notifier.loadInitial();
      // hasMore logic: items.length == 20 => hasMore=true
      // In this case length is 21 (more than pageSize), so hasMore = false
      // But wait - code uses `==` so if not exactly 20, hasMore = false
      // Actually 21 items means hasMore should be false (not exactly pageSize)
      expect(notifier.state.hasMore, false);
    });

    test('hasMore correctly handles pageSize-1 items', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(19, (i) => 'Item$i'); // Less than 20
      };

      await notifier.loadInitial();
      // 19 items (less than pageSize) => hasMore = false
      expect(notifier.state.hasMore, false);
    });

    test('dispose cleans up debouncer', () {
      // Dispose is called in tearDown, so just verify dispose doesn't crash
      expect(() => notifier.dispose(), returnsNormally);
    });

    test('multiple pages can be loaded sequentially', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Page$page-Item$i');
      };

      await notifier.loadInitial(); // Page 0
      await notifier.loadMore();     // Page 1
      await notifier.loadMore();     // Page 2

      expect(notifier.state.items, hasLength(60));
      expect(notifier.state.currentPage, 2);
      expect(notifier.state.items.first, 'Page0-Item0');
      expect(notifier.state.items.last, 'Page2-Item19');
    });

    test('refresh after loadMore resets to page 0', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return List.generate(20, (i) => 'Page$page-Item$i');
      };

      await notifier.loadInitial();
      await notifier.loadMore();
      expect(notifier.state.currentPage, 1);

      await notifier.refresh();
      expect(notifier.state.currentPage, 0);
      expect(notifier.state.items, hasLength(20));
    });

    test('error state is cleared by subsequent successful operations', () async {
      // Fail loadInitial
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        throw Exception('Error');
      };
      await notifier.loadInitial();
      expect(notifier.state.error, isNotNull);

      // Succeed on retry
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['Item'];
      };
      await notifier.loadInitial();
      expect(notifier.state.error, isNull);
    });

    test('items are correctly appended and not replaced in loadMore', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        if (page == 0) return ['A', 'B'];
        if (page == 1) return ['C', 'D'];
        return [];
      };

      await notifier.loadInitial();
      expect(notifier.state.items, ['A', 'B']);

      await notifier.loadMore();
      expect(notifier.state.items, ['A', 'B', 'C', 'D']);
    });

    test('items are replaced in refresh', () async {
      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['Old'];
      };
      await notifier.loadInitial();

      notifier.mockFetchItems = ({required page, required pageSize, searchQuery, filters}) async {
        return ['New'];
      };
      await notifier.refresh();

      expect(notifier.state.items, ['New']);
      expect(notifier.state.items, isNot(contains('Old')));
    });
  });
}
