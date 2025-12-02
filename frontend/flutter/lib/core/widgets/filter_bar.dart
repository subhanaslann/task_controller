import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Filter data model
class FilterItem {
  final String id;
  final String label;

  const FilterItem({required this.id, required this.label});
}

/// TekTech FilterBar Component
///
/// Search bar with filterable chips
/// - Search input with icon
/// - Chip-based filters (multi-select)
/// - Clear all action
class FilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final List<FilterItem> filters;
  final Set<String> selectedFilters;
  final ValueChanged<String> onFilterToggle;
  final VoidCallback? onClearAll;

  const FilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChange,
    this.filters = const [],
    this.selectedFilters = const {},
    required this.onFilterToggle,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: onSearchChange,
            decoration: InputDecoration(
              hintText: 'Görev ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onSearchChange(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          // Filter chips
          if (filters.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters
                          .map(
                            (filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter.label),
                                selected: selectedFilters.contains(filter.id),
                                onSelected: (_) => onFilterToggle(filter.id),
                                selectedColor: AppTheme.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppTheme.primaryColor,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color: selectedFilters.contains(filter.id)
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade700,
                                  fontWeight:
                                      selectedFilters.contains(filter.id)
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                // Clear all button
                if (selectedFilters.isNotEmpty && onClearAll != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onClearAll,
                    child: const Text('Temizle'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple search bar without filters
class SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChange;
  final String placeholder;

  const SearchBar({
    super.key,
    required this.query,
    required this.onQueryChange,
    this.placeholder = 'Ara...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onQueryChange,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onQueryChange(''),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
