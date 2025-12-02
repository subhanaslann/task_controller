package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * Section Header - For grouping content
 */
@Composable
fun SectionHeader(
  title: String,
  modifier: Modifier = Modifier,
  action: @Composable (() -> Unit)? = null
) {
  Row(
    modifier = modifier
      .fillMaxWidth()
      .padding(horizontal = Spacing.screenPadding, vertical = Spacing.spacing12),
    horizontalArrangement = Arrangement.SpaceBetween,
    verticalAlignment = Alignment.CenterVertically
  ) {
    Text(
      text = title,
      style = MaterialTheme.typography.titleMedium.copy(
        fontWeight = FontWeight.SemiBold
      ),
      color = MaterialTheme.colorScheme.onSurface
    )
    action?.invoke()
  }
}

/**
 * App Divider - Consistent divider styling
 */
@Composable
fun AppDivider(
  modifier: Modifier = Modifier
) {
  HorizontalDivider(
    modifier = modifier,
    color = MaterialTheme.colorScheme.outlineVariant
  )
}

// LoadingPlaceholder and ErrorState already exist in CommonComponents.kt
