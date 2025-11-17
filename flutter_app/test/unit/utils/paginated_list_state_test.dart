import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/paginated_list_state.dart';

void main() {
  group('PaginatedListState Tests', () {
    test('should create initial state with default values', () {
      // Arrange & Act
      const state = PaginatedListState<int>();

      // Assert
      expect(state.items, isEmpty);
      expect(state.isLoadingInitial, false);
      expect(state.isLoadingMore, false);
      expect(state.isRefreshing, false);
      expect(state.hasMore, true);
      expect(state.currentPage, 0);
      expect(state.error, null);
      expect(state.searchQuery, '');
      expect(state.filters, null);
    });

    test('should create state with custom values', () {
      // Arrange & Act
      const state = PaginatedListState<int>(
        items: [1, 2, 3],
        isLoadingInitial: true,
        currentPage: 1,
        hasMore: false,
      );

      // Assert
      expect(state.items, [1, 2, 3]);
      expect(state.isLoadingInitial, true);
      expect(state.currentPage, 1);
      expect(state.hasMore, false);
    });

    test('should copy state with updated values', () {
      // Arrange
      const state = PaginatedListState<int>(items: [1, 2, 3]);

      // Act
      final newState = state.copyWith(
        items: [1, 2, 3, 4, 5],
        currentPage: 1,
      );

      // Assert
      expect(newState.items, [1, 2, 3, 4, 5]);
      expect(newState.currentPage, 1);
      expect(newState.hasMore, true); // Unchanged
    });

    test('should report isLoading correctly', () {
      // Arrange & Act & Assert
      expect(const PaginatedListState<int>().isLoading, false);
      expect(
        const PaginatedListState<int>(isLoadingInitial: true).isLoading,
        true,
      );
      expect(
        const PaginatedListState<int>(isLoadingMore: true).isLoading,
        true,
      );
      expect(
        const PaginatedListState<int>(isRefreshing: true).isLoading,
        true,
      );
    });

    test('should report isEmpty correctly', () {
      // Arrange & Act & Assert
      expect(const PaginatedListState<int>().isEmpty, true);
      expect(
        const PaginatedListState<int>(items: [1, 2, 3]).isEmpty,
        false,
      );
      expect(
        const PaginatedListState<int>(isLoadingInitial: true).isEmpty,
        false,
      );
    });

    test('should report hasError correctly', () {
      // Arrange & Act & Assert
      expect(const PaginatedListState<int>().hasError, false);
      expect(
        const PaginatedListState<int>(error: 'Error').hasError,
        true,
      );
    });

    test('should report hasData correctly', () {
      // Arrange & Act & Assert
      expect(const PaginatedListState<int>().hasData, false);
      expect(
        const PaginatedListState<int>(items: [1, 2, 3]).hasData,
        true,
      );
    });

    test('should copy state and clear error', () {
      // Arrange
      const state = PaginatedListState<int>(error: 'Error occurred');

      // Act
      final newState = state.copyWith(error: null);

      // Assert
      expect(state.error, 'Error occurred');
      expect(newState.error, null);
    });
  });

  group('PaginationParams Tests', () {
    test('should create default pagination params', () {
      // Arrange & Act
      const params = PaginationParams();

      // Assert
      expect(params.page, 0);
      expect(params.pageSize, 20);
      expect(params.searchQuery, null);
      expect(params.filters, null);
      expect(params.sortBy, null);
      expect(params.sortAscending, true);
    });

    test('should create pagination params with custom values', () {
      // Arrange & Act
      const params = PaginationParams(
        page: 2,
        pageSize: 50,
        searchQuery: 'test',
        sortBy: 'name',
        sortAscending: false,
      );

      // Assert
      expect(params.page, 2);
      expect(params.pageSize, 50);
      expect(params.searchQuery, 'test');
      expect(params.sortBy, 'name');
      expect(params.sortAscending, false);
    });

    test('should copy params with updated values', () {
      // Arrange
      const params = PaginationParams(page: 0);

      // Act
      final newParams = params.copyWith(page: 1);

      // Assert
      expect(params.page, 0);
      expect(newParams.page, 1);
    });

    test('should convert to query params', () {
      // Arrange
      const params = PaginationParams(
        page: 1,
        pageSize: 25,
        searchQuery: 'test',
        sortBy: 'name',
        sortAscending: true,
      );

      // Act
      final queryParams = params.toQueryParams();

      // Assert
      expect(queryParams['page'], '1');
      expect(queryParams['pageSize'], '25');
      expect(queryParams['search'], 'test');
      expect(queryParams['sortBy'], 'name');
      expect(queryParams['order'], 'asc');
    });

    test('should exclude optional params when null', () {
      // Arrange
      const params = PaginationParams(page: 0, pageSize: 20);

      // Act
      final queryParams = params.toQueryParams();

      // Assert
      expect(queryParams.containsKey('search'), false);
      expect(queryParams.containsKey('sortBy'), false);
    });
  });
}

