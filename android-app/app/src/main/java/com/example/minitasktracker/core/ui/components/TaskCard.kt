package com.example.minitasktracker.core.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CalendarToday
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.*
import com.example.minitasktracker.domain.model.Priority
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.TaskStatus
import java.text.SimpleDateFormat
import java.util.*
import java.util.Calendar

/**
 * TekTech TaskCard Component
 * 
 * Professional task card with:
 * - Left priority color stripe (4dp)
 * - Topic badge
 * - Status and priority badges
 * - Due date indicator
 * - Assignee avatar with initials
 * - Smooth status change animation
 * 
 * @param task Task data
 * @param onStatusChange Optional status change handler (makes status interactive)
 * @param onClick Optional click handler for the entire card
 * @param showNote Show/hide note (guest filtering)
 */
@Composable
fun TaskCard(
  task: Task,
  onStatusChange: ((TaskStatus) -> Unit)? = null,
  onClick: (() -> Unit)? = null,
  showNote: Boolean = true,
  modifier: Modifier = Modifier
) {
  // Priority color with animation
  val priorityColor by animateColorAsState(
    targetValue = when (task.priority) {
      Priority.HIGH -> Red500
      Priority.NORMAL -> Cyan500
      Priority.LOW -> Gray400
    },
    animationSpec = tween(durationMillis = Duration.stateChange),
    label = "priority_color"
  )
  
  Card(
    modifier = modifier
      .fillMaxWidth()
      .padding(horizontal = Spacing.screenPadding, vertical = Spacing.spacing8)
      .then(
        if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier
      ),
    shape = MaterialTheme.shapes.medium,
    elevation = CardDefaults.cardElevation(
      defaultElevation = Elevation.elevationLow
    ),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surface
    )
  ) {
    Row(
      modifier = Modifier.padding(Spacing.cardPadding)
    ) {
      // Left: Priority stripe (4dp width)
      Box(
        modifier = Modifier
          .width(4.dp)
          .height(64.dp)
          .clip(MaterialTheme.shapes.small)
          .background(priorityColor)
      )
      
      Spacer(modifier = Modifier.width(Spacing.spacing12))
      
      // Main content
      Column(
        modifier = Modifier.weight(1f)
      ) {
        // Top row: Topic badge + Due date + Status
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          // Left: Topic badge (if exists)
          Row(
            modifier = Modifier.weight(1f),
            horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8),
            verticalAlignment = Alignment.CenterVertically
          ) {
            task.topicTitle?.let { topic ->
              Surface(
                color = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.5f),
                shape = MaterialTheme.shapes.small
              ) {
                Text(
                  text = topic,
                  style = MaterialTheme.typography.labelSmall,
                  color = MaterialTheme.colorScheme.onSecondaryContainer,
                  modifier = Modifier.padding(horizontal = Spacing.spacing8, vertical = Spacing.spacing4),
                  maxLines = 1,
                  overflow = TextOverflow.Ellipsis
                )
              }
            }
          }
          
          // Right: Days remaining + Status
          Row(
            horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8),
            verticalAlignment = Alignment.CenterVertically
          ) {
            // Days remaining badge
            task.dueDate?.let { dueDate ->
              val daysRemaining = calculateDaysRemaining(dueDate)
              DaysRemainingBadge(daysRemaining)
            }
            
            // Status badge
            if (onStatusChange != null) {
              StatusBadgeInteractive(
                status = task.status,
                onStatusChange = onStatusChange
              )
            } else {
              StatusBadge(status = task.status)
            }
          }
        }
        
        Spacer(modifier = Modifier.height(Spacing.spacing8))
        
        // Title
        Text(
          text = task.title,
          style = MaterialTheme.typography.titleMedium.copy(
            fontWeight = FontWeight.SemiBold
          ),
          color = MaterialTheme.colorScheme.onSurface,
          maxLines = 2,
          overflow = TextOverflow.Ellipsis
        )
        
        // Note (if visible and exists)
        if (showNote && !task.note.isNullOrBlank()) {
          Spacer(modifier = Modifier.height(Spacing.spacing4))
          Text(
            text = task.note,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis
          )
        }
        
        Spacer(modifier = Modifier.height(Spacing.spacing12))
        
        // Bottom row: Priority + Due date + Assignee
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          // Left: Priority badge
          PriorityBadge(priority = task.priority)
          
          // Right: Due date + Assignee
          Row(
            horizontalArrangement = Arrangement.spacedBy(Spacing.spacing12),
            verticalAlignment = Alignment.CenterVertically
          ) {
            // Due date
            task.dueDate?.let { dueDate ->
              Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.spacing4),
                verticalAlignment = Alignment.CenterVertically
              ) {
                Icon(
                  imageVector = Icons.Outlined.CalendarToday,
                  contentDescription = null,
                  modifier = Modifier.size(Sizes.iconXs),
                  tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                  text = formatDueDate(dueDate),
                  style = MaterialTheme.typography.labelSmall,
                  color = MaterialTheme.colorScheme.onSurfaceVariant
                )
              }
            }
            
            // Assignee avatar
            task.assigneeName?.let { assignee ->
              UserAvatar(
                name = assignee,
                size = Sizes.avatarSmall
              )
            }
          }
        }
      }
    }
  }
}

/**
 * User Avatar with initials
 */
@Composable
fun UserAvatar(
  name: String,
  size: androidx.compose.ui.unit.Dp = Sizes.avatarMedium,
  modifier: Modifier = Modifier
) {
  Box(
    modifier = modifier
      .size(size)
      .clip(CircleShape)
      .background(MaterialTheme.colorScheme.primaryContainer),
    contentAlignment = Alignment.Center
  ) {
    Text(
      text = name.take(1).uppercase(),
      style = MaterialTheme.typography.labelSmall.copy(
        fontWeight = FontWeight.SemiBold
      ),
      color = MaterialTheme.colorScheme.onPrimaryContainer
    )
  }
}

/**
 * Status Badge - Shows task status (TODO/DOING/DONE)
 */
@Composable
fun StatusBadge(
  status: TaskStatus,
  modifier: Modifier = Modifier
) {
  val (label, backgroundColor, textColor) = when (status) {
    TaskStatus.TODO -> Triple(
      "Yapılacak",
      Gray200,
      Gray700
    )
    TaskStatus.IN_PROGRESS -> Triple(
      "Devam Ediyor",
      Cyan100,
      Cyan700
    )
    TaskStatus.DONE -> Triple(
      "Tamamlandı",
      Green100,
      Green700
    )
  }
  
  Surface(
    modifier = modifier,
    color = backgroundColor,
    shape = MaterialTheme.shapes.small
  ) {
    Text(
      text = label,
      style = MaterialTheme.typography.labelSmall.copy(
        fontWeight = FontWeight.Medium
      ),
      color = textColor,
      modifier = Modifier.padding(
        horizontal = Spacing.spacing8,
        vertical = Spacing.spacing4
      )
    )
  }
}

// Legacy compatibility
@Composable
fun StatusChip(status: TaskStatus) = StatusBadge(status)

/**
 * Status Badge Interactive - Clickable with dropdown menu
 */
@Composable
fun StatusBadgeInteractive(
  status: TaskStatus,
  onStatusChange: (TaskStatus) -> Unit,
  modifier: Modifier = Modifier
) {
  var expanded by remember { mutableStateOf(false) }
  
  Box(modifier = modifier) {
    Surface(
      onClick = { expanded = true },
      color = when (status) {
        TaskStatus.TODO -> Gray200
        TaskStatus.IN_PROGRESS -> Cyan100
        TaskStatus.DONE -> Green100
      },
      shape = MaterialTheme.shapes.small
    ) {
      Text(
        text = when (status) {
          TaskStatus.TODO -> "Yapılacak"
          TaskStatus.IN_PROGRESS -> "Devam Ediyor"
          TaskStatus.DONE -> "Tamamlandı"
        },
        style = MaterialTheme.typography.labelSmall.copy(
          fontWeight = FontWeight.Medium
        ),
        color = when (status) {
          TaskStatus.TODO -> Gray700
          TaskStatus.IN_PROGRESS -> Cyan700
          TaskStatus.DONE -> Green700
        },
        modifier = Modifier.padding(
          horizontal = Spacing.spacing8,
          vertical = Spacing.spacing4
        )
      )
    }
    
    DropdownMenu(
      expanded = expanded,
      onDismissRequest = { expanded = false }
    ) {
      DropdownMenuItem(
        text = { Text("Yapılacak") },
        onClick = {
          onStatusChange(TaskStatus.TODO)
          expanded = false
        }
      )
      DropdownMenuItem(
        text = { Text("Devam Ediyor") },
        onClick = {
          onStatusChange(TaskStatus.IN_PROGRESS)
          expanded = false
        }
      )
      DropdownMenuItem(
        text = { Text("Tamamlandı") },
        onClick = {
          onStatusChange(TaskStatus.DONE)
          expanded = false
        }
      )
    }
  }
}

// Legacy compatibility
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StatusChipWithDropdown(
  status: TaskStatus,
  onStatusChange: (TaskStatus) -> Unit
) = StatusBadgeInteractive(status, onStatusChange)

/**
 * Priority Badge - Shows task priority (LOW/NORMAL/HIGH)
 */
@Composable
fun PriorityBadge(
  priority: Priority,
  modifier: Modifier = Modifier
) {
  val (label, backgroundColor, textColor) = when (priority) {
    Priority.LOW -> Triple(
      "Düşük",
      Gray100,
      Gray600
    )
    Priority.NORMAL -> Triple(
      "Normal",
      Cyan100,
      Cyan700
    )
    Priority.HIGH -> Triple(
      "Yüksek",
      Red100,
      Red700
    )
  }
  
  Surface(
    modifier = modifier,
    color = backgroundColor,
    shape = MaterialTheme.shapes.small
  ) {
    Text(
      text = label,
      style = MaterialTheme.typography.labelSmall.copy(
        fontWeight = FontWeight.Medium
      ),
      color = textColor,
      modifier = Modifier.padding(
        horizontal = Spacing.spacing8,
        vertical = Spacing.spacing4
      )
    )
  }
}

// Legacy compatibility
@Composable
fun PriorityChip(priority: Priority) = PriorityBadge(priority)

/**
 * Days Remaining Badge - Shows days until due date
 */
@Composable
fun DaysRemainingBadge(
  daysRemaining: Int,
  modifier: Modifier = Modifier
) {
  val (backgroundColor, textColor, text) = when {
    daysRemaining < 0 -> Triple(
      Red100,
      Red700,
      "${-daysRemaining} g\u00fcn ge\u00e7ti"
    )
    daysRemaining == 0 -> Triple(
      Red100,
      Red700,
      "Bug\u00fcn"
    )
    daysRemaining == 1 -> Triple(
      MaterialTheme.colorScheme.errorContainer,
      MaterialTheme.colorScheme.onErrorContainer,
      "1 g\u00fcn kald\u0131"
    )
    daysRemaining <= 3 -> Triple(
      MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.7f),
      MaterialTheme.colorScheme.onErrorContainer,
      "$daysRemaining g\u00fcn kald\u0131"
    )
    daysRemaining <= 7 -> Triple(
      MaterialTheme.colorScheme.tertiaryContainer,
      MaterialTheme.colorScheme.onTertiaryContainer,
      "$daysRemaining g\u00fcn kald\u0131"
    )
    else -> Triple(
      MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.5f),
      MaterialTheme.colorScheme.onSecondaryContainer,
      "$daysRemaining g\u00fcn kald\u0131"
    )
  }
  
  Surface(
    modifier = modifier,
    color = backgroundColor,
    shape = MaterialTheme.shapes.small
  ) {
    Text(
      text = text,
      style = MaterialTheme.typography.labelSmall.copy(
        fontWeight = FontWeight.Bold
      ),
      color = textColor,
      modifier = Modifier.padding(
        horizontal = Spacing.spacing8,
        vertical = Spacing.spacing4
      )
    )
  }
}

private fun calculateDaysRemaining(dateString: String): Int {
  return try {
    val parser = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
    parser.timeZone = TimeZone.getTimeZone("UTC")
    val dueDate = parser.parse(dateString.take(19))
    
    if (dueDate != null) {
      val today = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
      }
      
      val dueDateCalendar = Calendar.getInstance().apply {
        time = dueDate
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
      }
      
      val diffInMillis = dueDateCalendar.timeInMillis - today.timeInMillis
      (diffInMillis / (1000 * 60 * 60 * 24)).toInt()
    } else {
      0
    }
  } catch (e: Exception) {
    0
  }
}

private fun formatDueDate(dateString: String): String {
  return try {
    val parser = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
    parser.timeZone = TimeZone.getTimeZone("UTC")
    val date = parser.parse(dateString)
    val formatter = SimpleDateFormat("dd MMM", Locale("tr", "TR"))
    date?.let { formatter.format(it) } ?: dateString
  } catch (e: Exception) {
    dateString.take(10) // Fallback: just show date part
  }
}
