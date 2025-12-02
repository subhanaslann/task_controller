package com.example.minitasktracker.features.tasks.ui.teamactive

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.minitasktracker.core.ui.components.*
import com.example.minitasktracker.domain.model.Priority
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.Topic

@Composable
fun TeamActiveTasksScreen(
  viewModel: TeamActiveViewModel = hiltViewModel()
) {
  val uiState by viewModel.uiState.collectAsState()
  val createDialogState = viewModel.createTaskDialogState
  val editDialogState = viewModel.editTaskDialogState

  LaunchedEffect(Unit) {
    viewModel.loadTopics()
  }

  Box(
    modifier = Modifier.fillMaxSize()
  ) {
    when (val state = uiState) {
      is TeamActiveUiState.Loading -> {
        LazyColumn {
          items(3) {
            LoadingPlaceholder()
          }
        }
      }
      is TeamActiveUiState.Success -> {
        // Guest kullanıcılar için visibleTopicIds'e göre filtrele
        val visibleTopics = if (state.userRole == "GUEST") {
          val visibleIds = state.visibleTopicIds.toSet()
          state.topics.filter { visibleIds.contains(it.id) }
        } else {
          state.topics
        }
        
        if (visibleTopics.isEmpty()) {
          Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
          ) {
            EmptyState(
              title = if (state.userRole == "GUEST") "Görüntülenebilir proje yok" else "Aktif proje yok",
              message = if (state.userRole == "GUEST") 
                "Admin henüz size görünür proje atamamış" 
              else 
                "Henüz aktif proje bulunmuyor"
            )
          }
        } else {
          TopicsList(
            topics = state.topics,
            userRole = state.userRole,
            userId = state.userId,
            onAddTask = { topicId, topicTitle ->
              viewModel.showCreateTaskDialog(topicId, topicTitle)
            },
            onTaskClick = { task ->
              viewModel.showEditTaskDialog(task, state.userRole, state.userId)
            }
          )
        }
      }
      is TeamActiveUiState.Error -> {
        ErrorState(
          message = state.message,
          onRetry = { viewModel.loadTopics() }
        )
      }
    }
  }

  // Create Task Dialog
  when (val dialog = createDialogState) {
    is CreateTaskDialogState.Visible -> {
      CreateTaskDialog(
        topicTitle = dialog.topicTitle,
        onDismiss = viewModel::hideCreateTaskDialog,
        onSave = { title, note, priority, dueDate ->
          viewModel.createTask(dialog.topicId, title, note, priority, dueDate)
        }
      )
    }
    CreateTaskDialogState.Hidden -> {}
  }

  // Edit Task Dialog
  when (val dialog = editDialogState) {
    is EditTaskDialogState.Visible -> {
      EditTaskDialog(
        task = dialog.task,
        canEdit = dialog.canEdit,
        onDismiss = viewModel::hideEditTaskDialog,
        onSave = { taskId, title, note, status, priority, dueDate ->
          viewModel.updateTask(taskId, title, note, status, priority, dueDate)
        }
      )
    }
    EditTaskDialogState.Hidden -> {}
  }
}

@Composable
private fun TopicsList(
  topics: List<Topic>,
  userRole: String,
  userId: String,
  onAddTask: (String, String) -> Unit,
  onTaskClick: (Task) -> Unit
) {
  // Filtre zaten yukarıda yapıldı, direkt kullan
  val filteredTopics = topics
  
  LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(vertical = 8.dp, horizontal = 16.dp),
    verticalArrangement = Arrangement.spacedBy(12.dp)
  ) {
    items(filteredTopics) { topic ->
      TopicCard(
        topic = topic,
        userRole = userRole,
        userId = userId,
        onAddTask = { onAddTask(topic.id, topic.title) },
        onTaskClick = onTaskClick
      )
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun TopicCard(
  topic: Topic,
  userRole: String,
  userId: String,
  onAddTask: () -> Unit,
  onTaskClick: (Task) -> Unit
) {
  var expanded by remember { mutableStateOf(true) }
  
  Card(
    modifier = Modifier.fillMaxWidth(),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surface
    ),
    elevation = CardDefaults.cardElevation(
      defaultElevation = 2.dp
    )
  ) {
    Column(
      modifier = Modifier.padding(20.dp)
    ) {
      // Header
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Column(modifier = Modifier.weight(1f)) {
          Text(
            text = topic.title,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
          )
          topic.description?.let {
            Text(
              text = it,
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
              modifier = Modifier.padding(top = 4.dp)
            )
          }
          Text(
            text = "${topic.tasks.size} görev",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(top = 4.dp)
          )
        }
        
        IconButton(onClick = { expanded = !expanded }) {
          Icon(
            imageVector = if (expanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
            contentDescription = if (expanded) "Daralt" else "Genişlet"
          )
        }
      }

      // Add Task Button for Members
      if (userRole != "GUEST") {
        Spacer(modifier = Modifier.height(16.dp))
        AppButton(
          text = "Kendime Görev Ekle",
          onClick = onAddTask,
          variant = ButtonVariant.SECONDARY,
          fullWidth = true,
          icon = { 
            Icon(
              imageVector = Icons.Filled.Add,
              contentDescription = null
            )
          }
        )
      }

      // Tasks List
      AnimatedVisibility(visible = expanded) {
        Column(
          modifier = Modifier.padding(top = 16.dp),
          verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
          if (topic.tasks.isEmpty()) {
            Text(
              text = "Henüz görev yok",
              style = MaterialTheme.typography.bodySmall,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
              modifier = Modifier.padding(vertical = 8.dp)
            )
          } else {
            topic.tasks.forEach { task ->
              TaskItemInTopic(
                task = task,
                isOwnTask = task.assigneeId == userId,
                onClick = { onTaskClick(task) }
              )
            }
          }
        }
      }
    }
  }
}

@Composable
private fun TaskItemInTopic(
  task: Task,
  isOwnTask: Boolean,
  onClick: () -> Unit
) {
  Card(
    modifier = Modifier.fillMaxWidth(),
    onClick = onClick,
    colors = CardDefaults.cardColors(
      containerColor = if (isOwnTask) 
        MaterialTheme.colorScheme.primaryContainer 
      else 
        MaterialTheme.colorScheme.surfaceVariant
    ),
    elevation = CardDefaults.cardElevation(
      defaultElevation = if (isOwnTask) 3.dp else 1.dp
    )
  ) {
    Column(
      modifier = Modifier.padding(16.dp)
    ) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
      ) {
        Text(
          text = task.title,
          style = MaterialTheme.typography.titleSmall,
          fontWeight = if (isOwnTask) FontWeight.Bold else FontWeight.SemiBold,
          modifier = Modifier.weight(1f)
        )
        
        PriorityBadge(priority = task.priority)
      }
      
      task.note?.let {
        Text(
          text = it,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          modifier = Modifier.padding(top = 4.dp)
        )
      }
      
      Row(
        modifier = Modifier
          .fillMaxWidth()
          .padding(top = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(
          text = task.assigneeName ?: "Atanmamış",
          style = MaterialTheme.typography.labelSmall,
          color = MaterialTheme.colorScheme.secondary
        )
        
        StatusBadge(status = task.status)
      }
    }
  }
}

@Composable
private fun PriorityBadge(priority: Priority) {
  val color = when (priority) {
    Priority.HIGH -> MaterialTheme.colorScheme.error
    Priority.NORMAL -> MaterialTheme.colorScheme.primary
    Priority.LOW -> MaterialTheme.colorScheme.tertiary
  }
  
  val text = when (priority) {
    Priority.HIGH -> "Yüksek"
    Priority.NORMAL -> "Normal"
    Priority.LOW -> "Düşük"
  }
  
  Surface(
    color = color.copy(alpha = 0.1f),
    shape = MaterialTheme.shapes.small
  ) {
    Text(
      text = text,
      style = MaterialTheme.typography.labelSmall,
      color = color,
      modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
    )
  }
}

@Composable
private fun StatusBadge(status: com.example.minitasktracker.domain.model.TaskStatus) {
  val (text, color) = when (status) {
    com.example.minitasktracker.domain.model.TaskStatus.TODO -> "Yapılacak" to MaterialTheme.colorScheme.tertiary
    com.example.minitasktracker.domain.model.TaskStatus.IN_PROGRESS -> "Devam Ediyor" to MaterialTheme.colorScheme.primary
    com.example.minitasktracker.domain.model.TaskStatus.DONE -> "Tamamlandı" to MaterialTheme.colorScheme.secondary
  }
  
  Surface(
    color = color.copy(alpha = 0.1f),
    shape = MaterialTheme.shapes.small
  ) {
    Text(
      text = text,
      style = MaterialTheme.typography.labelSmall,
      color = color,
      modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
    )
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CreateTaskDialog(
  topicTitle: String,
  onDismiss: () -> Unit,
  onSave: (String, String?, Priority, String) -> Unit
) {
  var title by remember { mutableStateOf("") }
  var note by remember { mutableStateOf("") }
  var priority by remember { mutableStateOf(Priority.NORMAL) }
  var showDatePicker by remember { mutableStateOf(false) }
  var selectedDateMillis by remember { mutableStateOf<Long?>(null) }
  val datePickerState = rememberDatePickerState()

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { 
      Text(
        text = "Görev Ekle: $topicTitle",
        style = MaterialTheme.typography.headlineSmall,
        fontWeight = FontWeight.Bold
      ) 
    },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(16.dp)
      ) {
        OutlinedTextField(
          value = title,
          onValueChange = { title = it },
          label = { Text("Görev Başlığı") },
          modifier = Modifier.fillMaxWidth(),
          singleLine = false,
          maxLines = 3
        )
        
        OutlinedTextField(
          value = note,
          onValueChange = { note = it },
          label = { Text("Not (opsiyonel)") },
          modifier = Modifier.fillMaxWidth(),
          minLines = 3,
          maxLines = 5
        )
        
        // Priority Selector
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Öncelik",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold
          )
          Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
          ) {
            FilterChip(
              selected = priority == Priority.LOW,
              onClick = { priority = Priority.LOW },
              label = { Text("Düşük") }
            )
            FilterChip(
              selected = priority == Priority.NORMAL,
              onClick = { priority = Priority.NORMAL },
              label = { Text("Normal") }
            )
            FilterChip(
              selected = priority == Priority.HIGH,
              onClick = { priority = Priority.HIGH },
              label = { Text("Yüksek") }
            )
          }
        }
        
        // Date Picker Button
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Bitiş Tarihi *",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.error
          )
          OutlinedButton(
            onClick = { showDatePicker = true },
            modifier = Modifier.fillMaxWidth()
          ) {
            Text(
              text = if (selectedDateMillis != null) {
                java.text.SimpleDateFormat("dd MMM yyyy", java.util.Locale("tr", "TR"))
                  .format(java.util.Date(selectedDateMillis!!))
              } else {
                "Tarih Seç"
              },
              style = MaterialTheme.typography.bodyLarge
            )
          }
        }
      }
    },
    confirmButton = {
      Button(
        onClick = { 
          selectedDateMillis?.let { millis ->
            val dateFormatter = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
            val formattedDate = dateFormatter.format(java.util.Date(millis))
            onSave(
              title, 
              note.takeIf { it.isNotEmpty() },
              priority,
              "${formattedDate}T00:00:00Z"
            )
          }
        },
        enabled = title.isNotEmpty() && selectedDateMillis != null,
        modifier = Modifier.height(48.dp)
      ) {
        Text(
          text = "Kaydet",
          style = MaterialTheme.typography.titleSmall,
          fontWeight = FontWeight.SemiBold
        )
      }
    },
    dismissButton = {
      TextButton(
        onClick = onDismiss,
        modifier = Modifier.height(48.dp)
      ) {
        Text(
          text = "İptal",
          style = MaterialTheme.typography.titleSmall
        )
      }
    }
  )
  
  // Date Picker Dialog
  if (showDatePicker) {
    DatePickerDialog(
      onDismissRequest = { showDatePicker = false },
      confirmButton = {
        TextButton(
          onClick = {
            selectedDateMillis = datePickerState.selectedDateMillis
            showDatePicker = false
          }
        ) {
          Text("Tamam")
        }
      },
      dismissButton = {
        TextButton(onClick = { showDatePicker = false }) {
          Text("İptal")
        }
      }
    ) {
      DatePicker(
        state = datePickerState,
        title = { Text("Bitiş Tarihi Seç") },
        headline = { Text("Tarih seçin") }
      )
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EditTaskDialog(
  task: Task,
  canEdit: Boolean,
  onDismiss: () -> Unit,
  onSave: (String, String?, String?, com.example.minitasktracker.domain.model.TaskStatus?, Priority?, String?) -> Unit
) {
  var title by remember { mutableStateOf(task.title) }
  var note by remember { mutableStateOf(task.note ?: "") }
  var status by remember { mutableStateOf(task.status) }
  var priority by remember { mutableStateOf(task.priority) }
  var showDatePicker by remember { mutableStateOf(false) }
  
  // Parse existing due date
  val initialDateMillis = remember {
    task.dueDate?.let {
      try {
        val parser = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault())
        parser.parse(it.take(19))?.time
      } catch (e: Exception) {
        null
      }
    }
  }
  var selectedDateMillis by remember { mutableStateOf(initialDateMillis) }
  val datePickerState = rememberDatePickerState(initialSelectedDateMillis = initialDateMillis)

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { 
      Text(
        text = if (canEdit) "Görevi Düzenle" else "Görev Detayı",
        style = MaterialTheme.typography.headlineSmall,
        fontWeight = FontWeight.Bold
      ) 
    },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(16.dp)
      ) {
        OutlinedTextField(
          value = title,
          onValueChange = { title = it },
          label = { Text("Görev Başlığı") },
          modifier = Modifier.fillMaxWidth(),
          enabled = canEdit,
          singleLine = false,
          maxLines = 3
        )
        
        OutlinedTextField(
          value = note,
          onValueChange = { note = it },
          label = { Text("Not") },
          modifier = Modifier.fillMaxWidth(),
          minLines = 3,
          maxLines = 5,
          enabled = canEdit
        )
        
        // Status Selector
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Durum",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold
          )
          Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
          ) {
            FilterChip(
              selected = status == com.example.minitasktracker.domain.model.TaskStatus.TODO,
              onClick = { if (canEdit) status = com.example.minitasktracker.domain.model.TaskStatus.TODO },
              label = { Text("Yapılacak") },
              enabled = canEdit
            )
            FilterChip(
              selected = status == com.example.minitasktracker.domain.model.TaskStatus.IN_PROGRESS,
              onClick = { if (canEdit) status = com.example.minitasktracker.domain.model.TaskStatus.IN_PROGRESS },
              label = { Text("Devam Ediyor") },
              enabled = canEdit
            )
            FilterChip(
              selected = status == com.example.minitasktracker.domain.model.TaskStatus.DONE,
              onClick = { if (canEdit) status = com.example.minitasktracker.domain.model.TaskStatus.DONE },
              label = { Text("Tamamlandı") },
              enabled = canEdit
            )
          }
        }
        
        // Priority Selector
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Öncelik",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold
          )
          Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
          ) {
            FilterChip(
              selected = priority == Priority.LOW,
              onClick = { if (canEdit) priority = Priority.LOW },
              label = { Text("Düşük") },
              enabled = canEdit
            )
            FilterChip(
              selected = priority == Priority.NORMAL,
              onClick = { if (canEdit) priority = Priority.NORMAL },
              label = { Text("Normal") },
              enabled = canEdit
            )
            FilterChip(
              selected = priority == Priority.HIGH,
              onClick = { if (canEdit) priority = Priority.HIGH },
              label = { Text("Yüksek") },
              enabled = canEdit
            )
          }
        }
        
        // Date Picker Button
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Bitiş Tarihi *",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
            color = if (canEdit) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant
          )
          OutlinedButton(
            onClick = { if (canEdit) showDatePicker = true },
            modifier = Modifier.fillMaxWidth(),
            enabled = canEdit
          ) {
            Text(
              text = if (selectedDateMillis != null) {
                java.text.SimpleDateFormat("dd MMM yyyy", java.util.Locale("tr", "TR"))
                  .format(java.util.Date(selectedDateMillis!!))
              } else {
                "Tarih Seç"
              },
              style = MaterialTheme.typography.bodyLarge
            )
          }
        }
        
        // Atanan kişi (read-only)
        task.assigneeName?.let {
          OutlinedTextField(
            value = it,
            onValueChange = {},
            label = { Text("Atanan Kişi") },
            modifier = Modifier.fillMaxWidth(),
            enabled = false
          )
        }
      }
    },
    confirmButton = {
      if (canEdit) {
        Button(
          onClick = { 
            val dueDateChanged = selectedDateMillis != initialDateMillis
            val newDueDate = if (dueDateChanged && selectedDateMillis != null) {
              val dateFormatter = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
              val formattedDate = dateFormatter.format(java.util.Date(selectedDateMillis!!))
              "${formattedDate}T00:00:00Z"
            } else null
            
            onSave(
              task.id,
              if (title != task.title) title else null,
              if (note != task.note) note.takeIf { it.isNotEmpty() } else null,
              if (status != task.status) status else null,
              if (priority != task.priority) priority else null,
              newDueDate
            ) 
          },
          enabled = title.isNotEmpty() && selectedDateMillis != null,
          modifier = Modifier.height(48.dp)
        ) {
          Text(
            text = "Kaydet",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold
          )
        }
      }
    },
    dismissButton = {
      TextButton(
        onClick = onDismiss,
        modifier = Modifier.height(48.dp)
      ) {
        Text(
          text = if (canEdit) "İptal" else "Kapat",
          style = MaterialTheme.typography.titleSmall
        )
      }
    }
  )
  
  // Date Picker Dialog
  if (showDatePicker && canEdit) {
    DatePickerDialog(
      onDismissRequest = { showDatePicker = false },
      confirmButton = {
        TextButton(
          onClick = {
            selectedDateMillis = datePickerState.selectedDateMillis
            showDatePicker = false
          }
        ) {
          Text("Tamam")
        }
      },
      dismissButton = {
        TextButton(onClick = { showDatePicker = false }) {
          Text("İptal")
        }
      }
    ) {
      DatePicker(
        state = datePickerState,
        title = { Text("Bitiş Tarihi Seç") },
        headline = { Text("Tarih seçin") }
      )
    }
  }
}
