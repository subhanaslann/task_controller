import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/paginated_list_state.dart';
import '../utils/debounce.dart';

/// TekTech PaginatedListNotifier
/// 
/// Generic StateNotifier for paginated lists with search/filter
/// - Infinite scroll support
/// - Debounced search
/// - Pull-to-refresh
/// - Error handling
abstract class PaginatedListNotifier<T> extends StateNotifier<PaginatedListState<T>> {
  PaginatedListNotifier() : super(const PaginatedListState());

  final _searchDebouncer = Debouncer(duration: const Duration(milliseconds: 300));

  /// Fetch items - must be implemented by subclasses
  Future<List<T>> fetchItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
  });

  /// Load initial data
  Future<void> loadInitial({
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoadingInitial: true,
      error: null,
    );

    try {
      final items = await fetchItems(
        page: 0,
        pageSize: 20,
        searchQuery: searchQuery ?? state.searchQuery,
        filters: filters ?? state.filters,
      );

      state = state.copyWith(
        items: items,
        isLoadingInitial: false,
        currentPage: 0,
        hasMore: items.length >= 20,
        searchQuery: searchQuery ?? state.searchQuery,
        filters: filters ?? state.filters,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        error: e.toString(),
      );
    }
  }

  /// Load more items (for infinite scroll)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newItems = await fetchItems(
        page: nextPage,
        pageSize: 20,
        searchQuery: state.searchQuery,
        filters: state.filters,
      );

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newItems.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh (pull-to-refresh)
  Future<void> refresh() async {
    if (state.isLoadingInitial || state.isLoadingMore) return;

    state = state.copyWith(isRefreshing: true);

    try {
      final items = await fetchItems(
        page: 0,
        pageSize: 20,
        searchQuery: state.searchQuery,
        filters: state.filters,
      );

      state = state.copyWith(
        items: items,
        isRefreshing: false,
        currentPage: 0,
        hasMore: items.length >= 20,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// Search with debounce
  void search(String query) {
    _searchDebouncer(() {
      loadInitial(searchQuery: query);
    });
  }

  /// Update filters
  void updateFilters(Map<String, dynamic> filters) {
    loadInitial(filters: filters);
  }

  /// Clear filters
  void clearFilters() {
    loadInitial(filters: {});
  }

  /// Clear search
  void clearSearch() {
    loadInitial(searchQuery: '');
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}
