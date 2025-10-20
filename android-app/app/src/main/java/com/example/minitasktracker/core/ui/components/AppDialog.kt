package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Radius
import com.example.minitasktracker.core.ui.theme.Sizes
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * TekTech AppDialog Component
 * 
 * Modern dialog with consistent styling
 * - Confirm dialog (yes/no actions)
 * - Alert dialog (single action)
 * - Custom content dialog
 * 
 * @param onDismiss Dialog dismiss callback
 * @param title Dialog title
 * @param message Optional message text
 * @param icon Optional icon
 * @param confirmText Confirm button text
 * @param onConfirm Confirm action
 * @param dismissText Optional dismiss button text
 * @param confirmButtonVariant Confirm button style
 */
@Composable
fun AppDialog(
  onDismiss: () -> Unit,
  title: String,
  message: String? = null,
  icon: ImageVector? = null,
  confirmText: String = "Tamam",
  onConfirm: () -> Unit,
  dismissText: String? = "İptal",
  confirmButtonVariant: ButtonVariant = ButtonVariant.PRIMARY
) {
  AlertDialog(
    onDismissRequest = onDismiss,
    icon = icon?.let {
      {
        Icon(
          imageVector = it,
          contentDescription = null,
          modifier = Modifier.size(Sizes.iconLg),
          tint = when (confirmButtonVariant) {
            ButtonVariant.DESTRUCTIVE -> MaterialTheme.colorScheme.error
            else -> MaterialTheme.colorScheme.primary
          }
        )
      }
    },
    title = {
      Text(
        text = title,
        style = MaterialTheme.typography.titleLarge,
        textAlign = TextAlign.Center,
        modifier = Modifier.fillMaxWidth()
      )
    },
    text = message?.let {
      {
        Text(
          text = it,
          style = MaterialTheme.typography.bodyMedium,
          textAlign = TextAlign.Center,
          modifier = Modifier.fillMaxWidth()
        )
      }
    },
    confirmButton = {
      AppButton(
        text = confirmText,
        onClick = {
          onConfirm()
          onDismiss()
        },
        variant = confirmButtonVariant,
        size = ButtonSize.MEDIUM
      )
    },
    dismissButton = dismissText?.let {
      {
        AppButton(
          text = it,
          onClick = onDismiss,
          variant = ButtonVariant.GHOST,
          size = ButtonSize.MEDIUM
        )
      }
    },
    shape = MaterialTheme.shapes.extraLarge
  )
}

/**
 * Confirmation Dialog - For destructive actions
 */
@Composable
fun ConfirmDialog(
  onDismiss: () -> Unit,
  title: String,
  message: String,
  onConfirm: () -> Unit,
  confirmText: String = "Onayla",
  dismissText: String = "İptal"
) {
  AppDialog(
    onDismiss = onDismiss,
    title = title,
    message = message,
    icon = Icons.Outlined.Warning,
    confirmText = confirmText,
    onConfirm = onConfirm,
    dismissText = dismissText,
    confirmButtonVariant = ButtonVariant.DESTRUCTIVE
  )
}

/**
 * Alert Dialog - Single action, informational
 */
@Composable
fun AlertDialog(
  onDismiss: () -> Unit,
  title: String,
  message: String,
  buttonText: String = "Tamam"
) {
  AppDialog(
    onDismiss = onDismiss,
    title = title,
    message = message,
    confirmText = buttonText,
    onConfirm = {},
    dismissText = null
  )
}

/**
 * Custom Content Dialog - For complex content
 */
@Composable
fun CustomDialog(
  onDismiss: () -> Unit,
  title: String,
  content: @Composable ColumnScope.() -> Unit,
  confirmText: String = "Tamam",
  onConfirm: () -> Unit,
  dismissText: String? = "İptal"
) {
  AlertDialog(
    onDismissRequest = onDismiss,
    title = {
      Text(
        text = title,
        style = MaterialTheme.typography.titleLarge
      )
    },
    text = {
      Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(Spacing.spacing16)
      ) {
        content()
      }
    },
    confirmButton = {
      AppButton(
        text = confirmText,
        onClick = {
          onConfirm()
          onDismiss()
        },
        variant = ButtonVariant.PRIMARY
      )
    },
    dismissButton = dismissText?.let {
      {
        AppButton(
          text = it,
          onClick = onDismiss,
          variant = ButtonVariant.GHOST
        )
      }
    },
    shape = MaterialTheme.shapes.extraLarge
  )
}
