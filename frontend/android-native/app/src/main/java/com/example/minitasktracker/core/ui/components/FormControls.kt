package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Sizes
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * TekTech AppCheckbox Component
 * 
 * Consistent checkbox with label
 * - WCAG AA minimum touch target
 * - Semantic accessibility
 * 
 * @param checked Whether checkbox is checked
 * @param onCheckedChange Checked state change callback
 * @param label Checkbox label text
 * @param enabled Whether checkbox is enabled
 */
@Composable
fun AppCheckbox(
  checked: Boolean,
  onCheckedChange: (Boolean) -> Unit,
  label: String,
  modifier: Modifier = Modifier,
  enabled: Boolean = true
) {
  Row(
    modifier = modifier
      .semantics { role = Role.Checkbox }
      .defaultMinSize(minHeight = Sizes.minTouchTarget),
    verticalAlignment = Alignment.CenterVertically,
    horizontalArrangement = Arrangement.spacedBy(Spacing.spacing12)
  ) {
    Checkbox(
      checked = checked,
      onCheckedChange = onCheckedChange,
      enabled = enabled,
      colors = CheckboxDefaults.colors(
        checkedColor = MaterialTheme.colorScheme.primary,
        uncheckedColor = MaterialTheme.colorScheme.outline
      )
    )
    Text(
      text = label,
      style = MaterialTheme.typography.bodyMedium,
      color = if (enabled) {
        MaterialTheme.colorScheme.onSurface
      } else {
        MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
      }
    )
  }
}

/**
 * TekTech AppSwitch Component
 * 
 * Consistent switch with label
 * - WCAG AA minimum touch target
 * - Semantic accessibility
 * 
 * @param checked Whether switch is checked
 * @param onCheckedChange Checked state change callback
 * @param label Switch label text
 * @param enabled Whether switch is enabled
 */
@Composable
fun AppSwitch(
  checked: Boolean,
  onCheckedChange: (Boolean) -> Unit,
  label: String,
  modifier: Modifier = Modifier,
  enabled: Boolean = true,
  description: String? = null
) {
  Row(
    modifier = modifier
      .fillMaxWidth()
      .semantics { role = Role.Switch }
      .defaultMinSize(minHeight = Sizes.minTouchTarget)
      .padding(horizontal = Spacing.screenPadding, vertical = Spacing.spacing8),
    horizontalArrangement = Arrangement.SpaceBetween,
    verticalAlignment = Alignment.CenterVertically
  ) {
    Column(
      modifier = Modifier.weight(1f),
      verticalArrangement = Arrangement.spacedBy(Spacing.spacing4)
    ) {
      Text(
        text = label,
        style = MaterialTheme.typography.bodyLarge,
        color = if (enabled) {
          MaterialTheme.colorScheme.onSurface
        } else {
          MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
        }
      )
      description?.let {
        Text(
          text = it,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant
        )
      }
    }
    
    Spacer(modifier = Modifier.width(Spacing.spacing16))
    
    Switch(
      checked = checked,
      onCheckedChange = onCheckedChange,
      enabled = enabled,
      colors = SwitchDefaults.colors(
        checkedThumbColor = MaterialTheme.colorScheme.primary,
        checkedTrackColor = MaterialTheme.colorScheme.primaryContainer,
        uncheckedThumbColor = MaterialTheme.colorScheme.outline,
        uncheckedTrackColor = MaterialTheme.colorScheme.surfaceVariant
      )
    )
  }
}
