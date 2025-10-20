package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Inbox
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Sizes
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * TekTech EmptyState Component
 * 
 * Professional empty state with icon, title, message and optional action
 * Used when lists/screens have no data to display
 * 
 * @param icon Large icon (default: Inbox)
 * @param title Short descriptive title
 * @param message Optional explanation (1-2 sentences)
 * @param actionText Optional action button text
 * @param onActionClick Action button click handler
 */
@Composable
fun EmptyState(
  icon: ImageVector = Icons.Outlined.Inbox,
  title: String,
  message: String? = null,
  actionText: String? = null,
  onActionClick: (() -> Unit)? = null,
  modifier: Modifier = Modifier
) {
  Column(
    modifier = modifier
      .fillMaxWidth()
      .padding(Spacing.spacing32),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.Center
  ) {
    // Large icon
    Icon(
      imageVector = icon,
      contentDescription = null,
      modifier = Modifier.size(Sizes.iconXl * 1.5f),
      tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.38f)
    )
    
    Spacer(modifier = Modifier.height(Spacing.spacing24))
    
    // Title
    Text(
      text = title,
      style = MaterialTheme.typography.titleLarge,
      color = MaterialTheme.colorScheme.onSurface,
      textAlign = TextAlign.Center
    )
    
    // Optional message
    message?.let {
      Spacer(modifier = Modifier.height(Spacing.spacing8))
      Text(
        text = it,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        textAlign = TextAlign.Center,
        modifier = Modifier.widthIn(max = 280.dp)
      )
    }
    
    // Optional action button
    if (actionText != null && onActionClick != null) {
      Spacer(modifier = Modifier.height(Spacing.spacing24))
      AppButton(
        text = actionText,
        onClick = onActionClick,
        variant = ButtonVariant.PRIMARY
      )
    }
  }
}

/**
 * EmptyState variants for common scenarios
 */
@Composable
fun NoTasksEmptyState(
  onCreateClick: () -> Unit,
  modifier: Modifier = Modifier
) {
  EmptyState(
    icon = Icons.Outlined.Inbox,
    title = "Henüz görev yok",
    message = "Yeni bir görev oluşturarak başlayın",
    actionText = "Görev Oluştur",
    onActionClick = onCreateClick,
    modifier = modifier
  )
}

@Composable
fun NoCompletedTasksEmptyState(
  modifier: Modifier = Modifier
) {
  EmptyState(
    icon = Icons.Outlined.Inbox,
    title = "Tamamlanmış görev yok",
    message = "Tamamladığınız görevler burada görünecek",
    modifier = modifier
  )
}

@Composable
fun NoSearchResultsEmptyState(
  searchQuery: String,
  modifier: Modifier = Modifier
) {
  EmptyState(
    icon = Icons.Outlined.Inbox,
    title = "Sonuç bulunamadı",
    message = "\"$searchQuery\" için sonuç bulunamadı",
    modifier = modifier
  )
}
