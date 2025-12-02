package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.*

/**
 * TekTech Snackbar Types
 */
enum class SnackbarType {
  SUCCESS,
  ERROR,
  WARNING,
  INFO
}

/**
 * TekTech AppSnackbar
 * 
 * Consistent notification/toast component
 * - Success (green)
 * - Error (red)
 * - Warning (amber)
 * - Info (cyan)
 * 
 * @param message Snackbar message
 * @param type Snackbar type (success/error/warning/info)
 * @param actionLabel Optional action button text
 * @param onActionClick Optional action callback
 * @param onDismiss Dismiss callback
 */
@Composable
fun AppSnackbar(
  message: String,
  type: SnackbarType = SnackbarType.INFO,
  actionLabel: String? = null,
  onActionClick: (() -> Unit)? = null,
  onDismiss: () -> Unit
) {
  val (icon, containerColor, contentColor) = when (type) {
    SnackbarType.SUCCESS -> Triple(
      Icons.Default.CheckCircle,
      Green600,
      White
    )
    SnackbarType.ERROR -> Triple(
      Icons.Default.Error,
      Red600,
      White
    )
    SnackbarType.WARNING -> Triple(
      Icons.Default.Warning,
      Amber600,
      White
    )
    SnackbarType.INFO -> Triple(
      Icons.Default.Info,
      Cyan600,
      White
    )
  }
  
  Snackbar(
    modifier = Modifier.padding(Spacing.spacing16),
    action = if (actionLabel != null && onActionClick != null) {
      {
        TextButton(onClick = onActionClick) {
          Text(
            text = actionLabel,
            color = contentColor
          )
        }
      }
    } else {
      {
        IconButton(onClick = onDismiss) {
          Icon(
            imageVector = Icons.Default.Close,
            contentDescription = "Dismiss",
            tint = contentColor
          )
        }
      }
    },
    containerColor = containerColor,
    contentColor = contentColor,
    shape = MaterialTheme.shapes.medium
  ) {
    Row(
      verticalAlignment = Alignment.CenterVertically,
      horizontalArrangement = Arrangement.spacedBy(Spacing.spacing12)
    ) {
      Icon(
        imageVector = icon,
        contentDescription = null,
        modifier = Modifier.size(Sizes.iconSm)
      )
      Text(
        text = message,
        style = MaterialTheme.typography.bodyMedium
      )
    }
  }
}

/**
 * Helper function to show success snackbar
 */
@Composable
fun SuccessSnackbar(
  message: String,
  onDismiss: () -> Unit
) {
  AppSnackbar(
    message = message,
    type = SnackbarType.SUCCESS,
    onDismiss = onDismiss
  )
}

/**
 * Helper function to show error snackbar
 */
@Composable
fun ErrorSnackbar(
  message: String,
  actionLabel: String? = "Tekrar Dene",
  onActionClick: (() -> Unit)? = null,
  onDismiss: () -> Unit
) {
  AppSnackbar(
    message = message,
    type = SnackbarType.ERROR,
    actionLabel = actionLabel,
    onActionClick = onActionClick,
    onDismiss = onDismiss
  )
}
