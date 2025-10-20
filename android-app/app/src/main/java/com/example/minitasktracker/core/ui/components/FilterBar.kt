package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * TekTech FilterBar Component
 * 
 * Search bar with filterable chips
 * - Search input with icon
 * - Chip-based filters (multi-select)
 * - Clear all action
 * 
 * @param searchQuery Current search query
 * @param onSearchChange Search query change callback
 * @param filters List of available filters
 * @param selectedFilters Currently selected filter IDs
 * @param onFilterToggle Filter toggle callback
 * @param onClearAll Clear all filters callback
 */
data class Filter(
  val id: String,
  val label: String
)

@Composable
fun FilterBar(
  searchQuery: String,
  onSearchChange: (String) -> Unit,
  filters: List<Filter> = emptyList(),
  selectedFilters: Set<String> = emptySet(),
  onFilterToggle: (String) -> Unit = {},
  onClearAll: (() -> Unit)? = null,
  modifier: Modifier = Modifier
) {
  Column(
    modifier = modifier
      .fillMaxWidth()
      .padding(horizontal = Spacing.screenPadding, vertical = Spacing.spacing12)
  ) {
    // Search field
    OutlinedTextField(
      value = searchQuery,
      onValueChange = onSearchChange,
      modifier = Modifier.fillMaxWidth(),
      placeholder = { Text("Görev ara...") },
      leadingIcon = {
        Icon(
          imageVector = Icons.Default.Search,
          contentDescription = "Ara"
        )
      },
      trailingIcon = if (searchQuery.isNotEmpty()) {
        {
          IconButton(onClick = { onSearchChange("") }) {
            Icon(
              imageVector = Icons.Default.Close,
              contentDescription = "Temizle"
            )
          }
        }
      } else null,
      singleLine = true,
      shape = MaterialTheme.shapes.medium,
      colors = OutlinedTextFieldDefaults.colors(
        focusedBorderColor = MaterialTheme.colorScheme.primary,
        unfocusedBorderColor = MaterialTheme.colorScheme.outline
      )
    )
    
    // Filter chips
    if (filters.isNotEmpty()) {
      Spacer(modifier = Modifier.height(Spacing.spacing12))
      
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        LazyRow(
          modifier = Modifier.weight(1f),
          horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
        ) {
          items(filters) { filter ->
            FilterChip(
              selected = filter.id in selectedFilters,
              onClick = { onFilterToggle(filter.id) },
              label = { Text(filter.label) },
              leadingIcon = if (filter.id in selectedFilters) {
                {
                  Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                  )
                }
              } else null
            )
          }
        }
        
        // Clear all button
        if (selectedFilters.isNotEmpty() && onClearAll != null) {
          TextButton(onClick = onClearAll) {
            Text("Temizle")
          }
        }
      }
    }
  }
}

/**
 * Simple search bar without filters
 */
@Composable
fun SearchBar(
  query: String,
  onQueryChange: (String) -> Unit,
  placeholder: String = "Ara...",
  modifier: Modifier = Modifier
) {
  OutlinedTextField(
    value = query,
    onValueChange = onQueryChange,
    modifier = modifier.fillMaxWidth(),
    placeholder = { Text(placeholder) },
    leadingIcon = {
      Icon(
        imageVector = Icons.Default.Search,
        contentDescription = "Ara"
      )
    },
    trailingIcon = if (query.isNotEmpty()) {
      {
        IconButton(onClick = { onQueryChange("") }) {
          Icon(
            imageVector = Icons.Default.Close,
            contentDescription = "Temizle"
          )
        }
      }
    } else null,
    singleLine = true,
    shape = MaterialTheme.shapes.medium
  )
}
