import 'package:flutter/foundation.dart';

/// TekTech Paginated List State
/// 
/// Generic state management for paginated lists
/// - Infinite scroll support
/// - Loading states (initial, more, refresh)
/// - Error handling
/// - Search and filter support
class PaginatedListState<T> {
  final List<T> items;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String searchQuery;
  final Map<String, dynamic>? filters;

  const PaginatedListState({
    this.items = const [],
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.searchQuery = '',
    this.filters,
  });

  PaginatedListState<T> copyWith({
    List<T>? items,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) {
    return PaginatedListState<T>(
      items: items ?? this.items,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }

  bool get isLoading => isLoadingInitial || isLoadingMore || isRefreshing;
  bool get isEmpty => items.isEmpty && !isLoading;
  bool get hasError => error != null;
  bool get hasData => items.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedListState<T> &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          isLoadingInitial == other.isLoadingInitial &&
          isLoadingMore == other.isLoadingMore &&
          isRefreshing == other.isRefreshing &&
          hasMore == other.hasMore &&
          currentPage == other.currentPage &&
          error == other.error &&
          searchQuery == other.searchQuery &&
          mapEquals(filters, other.filters);

  @override
  int get hashCode => Object.hash(
        items,
        isLoadingInitial,
        isLoadingMore,
        isRefreshing,
        hasMore,
        currentPage,
        error,
        searchQuery,
        filters,
      );
}

/// Helper class for pagination parameters
class PaginationParams {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final bool sortAscending;

  const PaginationParams({
    this.page = 0,
    this.pageSize = 20,
    this.searchQuery,
    this.filters,
    this.sortBy,
    this.sortAscending = true,
  });

  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool? sortAscending,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortBy != null) 'order': sortAscending ? 'asc' : 'desc',
      if (filters != null) ...filters!,
    };
  }
}
