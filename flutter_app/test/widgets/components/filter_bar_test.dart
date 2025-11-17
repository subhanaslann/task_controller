import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/filter_bar.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('FilterBar Widget Tests', () {
    testWidgets('should render search field', (tester) async {
      // Arrange
      var searchQuery = '';
      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: searchQuery,
          onSearchChange: (value) {
            searchQuery = value;
          },
          onFilterToggle: (_) {},
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onSearchChange when text is entered', (
      tester,
    ) async {
      // Arrange
      var searchQuery = '';
      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: searchQuery,
          onSearchChange: (value) {
            searchQuery = value;
          },
          onFilterToggle: (_) {},
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'test search');
      await tester.pump();

      // Assert
      expect(searchQuery, 'test search');
    });

    testWidgets('should render filter chips when filters are provided', (
      tester,
    ) async {
      // Arrange
      final filters = [
        const FilterItem(id: 'high', label: 'High Priority'),
        const FilterItem(id: 'low', label: 'Low Priority'),
      ];

      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: '',
          onSearchChange: (_) {},
          filters: filters,
          selectedFilters: const {},
          onFilterToggle: (_) {},
        ),
      );

      // Assert
      expect(find.byType(FilterChip), findsNWidgets(2));
      expect(find.text('High Priority'), findsOneWidget);
      expect(find.text('Low Priority'), findsOneWidget);
    });

    testWidgets('should toggle filter selection when chip is tapped', (
      tester,
    ) async {
      // Arrange
      var selectedFilters = <String>{};
      final filters = [
        const FilterItem(id: 'high', label: 'High Priority'),
        const FilterItem(id: 'low', label: 'Low Priority'),
      ];

      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: '',
          onSearchChange: (_) {},
          filters: filters,
          selectedFilters: selectedFilters,
          onFilterToggle: (filterId) {
            if (selectedFilters.contains(filterId)) {
              selectedFilters = selectedFilters.difference({filterId});
            } else {
              selectedFilters = {...selectedFilters, filterId};
            }
          },
        ),
      );

      // Act
      await tester.tap(find.text('High Priority'));
      await tester.pump();

      // Assert
      expect(selectedFilters.contains('high'), true);
    });

    testWidgets('should show clear all button when filters are selected', (
      tester,
    ) async {
      // Arrange
      final filters = [const FilterItem(id: 'high', label: 'High Priority')];

      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: '',
          onSearchChange: (_) {},
          filters: filters,
          selectedFilters: const {'high'},
          onFilterToggle: (_) {},
          onClearAll: () {},
        ),
      );

      // Assert
      expect(find.text('Temizle'), findsOneWidget);
    });

    testWidgets('should call onClearAll when clear button is tapped', (
      tester,
    ) async {
      // Arrange
      var clearCalled = false;
      final filters = [const FilterItem(id: 'high', label: 'High Priority')];

      await pumpTestWidget(
        tester,
        FilterBar(
          searchQuery: '',
          onSearchChange: (_) {},
          filters: filters,
          selectedFilters: const {'high'},
          onFilterToggle: (_) {},
          onClearAll: () {
            clearCalled = true;
          },
        ),
      );

      // Act
      await tester.tap(find.text('Temizle'));
      await tester.pump();

      // Assert
      expect(clearCalled, true);
    });
  });
}
