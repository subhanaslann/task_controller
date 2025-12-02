package com.example.minitasktracker.features.admin.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.minitasktracker.core.ui.components.*
import com.example.minitasktracker.data.repo.AdminUser
import com.example.minitasktracker.domain.model.Topic

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun AdminScreen(
  onBack: () -> Unit,
  viewModel: AdminViewModel = hiltViewModel()
) {
  var selectedTab by remember { mutableIntStateOf(0) }

  Scaffold(
    topBar = {
      TopAppBar(
        title = { Text("Admin Paneli") },
        navigationIcon = {
          IconButton(onClick = onBack) {
            Icon(Icons.Filled.ArrowBack, contentDescription = "Geri")
          }
        }
      )
    }
  ) { paddingValues ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(paddingValues)
    ) {
      TabRow(selectedTabIndex = selectedTab) {
        Tab(
          selected = selectedTab == 0,
          onClick = { selectedTab = 0 },
          text = { Text("Kullanıcılar") }
        )
        Tab(
          selected = selectedTab == 1,
          onClick = { selectedTab = 1 },
          text = { Text("Konu Başlıkları") }
        )
      }

      when (selectedTab) {
        0 -> UserManagementTab(viewModel)
        1 -> TopicManagementTab(viewModel)
      }
    }
  }
}

@Composable
private fun UserManagementTab(viewModel: AdminViewModel) {
  val usersState = viewModel.usersState
  val dialogState = viewModel.userDialogState

  Box(modifier = Modifier.fillMaxSize()) {
    when (usersState) {
      is UsersState.Loading -> {
        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
      }
      is UsersState.Error -> {
        ErrorMessage(message = usersState.message)
      }
      is UsersState.Success -> {
        UsersList(
          users = usersState.users,
          onEdit = viewModel::showEditUserDialog,
          onDelete = viewModel::deleteUser
        )
      }
    }

    // FAB
    FloatingActionButton(
      onClick = viewModel::showCreateUserDialog,
      modifier = Modifier
        .align(Alignment.BottomEnd)
        .padding(16.dp)
    ) {
      Icon(Icons.Filled.Add, contentDescription = "Kullanıcı Ekle")
    }
  }

  // Dialog
  when (dialogState) {
    is UserDialogState.Create -> {
      val availableTopics = when (val state = viewModel.topicsState) {
        is TopicsState.Success -> state.topics
        else -> emptyList()
      }
      UserDialog(
        title = "Yeni Kullanıcı",
        availableTopics = availableTopics,
        onDismiss = viewModel::hideUserDialog,
        onSave = { name, username, email, password, role, active, visibleTopicIds ->
          viewModel.createUser(name, username, email, password, role, active, visibleTopicIds)
        }
      )
    }
    is UserDialogState.Edit -> {
      val availableTopics = when (val state = viewModel.topicsState) {
        is TopicsState.Success -> state.topics
        else -> emptyList()
      }
      UserEditDialog(
        user = dialogState.user,
        availableTopics = availableTopics,
        onDismiss = viewModel::hideUserDialog,
        onSave = { userId, name, role, active, password, visibleTopicIds ->
          viewModel.updateUser(userId, name, role, active, password, visibleTopicIds)
        }
      )
    }
    UserDialogState.Hidden -> {}
  }
}

@Composable
private fun TopicManagementTab(viewModel: AdminViewModel) {
  val topicsState = viewModel.topicsState
  val dialogState = viewModel.topicDialogState

  Box(modifier = Modifier.fillMaxSize()) {
    when (topicsState) {
      is TopicsState.Loading -> {
        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
      }
      is TopicsState.Error -> {
        ErrorMessage(message = topicsState.message)
      }
      is TopicsState.Success -> {
        TopicsList(
          topics = topicsState.topics,
          onEdit = viewModel::showEditTopicDialog,
          onDelete = viewModel::deleteTopic
        )
      }
    }

    // FAB
    FloatingActionButton(
      onClick = viewModel::showCreateTopicDialog,
      modifier = Modifier
        .align(Alignment.BottomEnd)
        .padding(16.dp)
    ) {
      Icon(Icons.Filled.Add, contentDescription = "Konu Başlığı Ekle")
    }
  }

  // Dialog
  when (dialogState) {
    is TopicDialogState.Create -> {
      TopicDialog(
        title = "Yeni Konu Başlığı",
        onDismiss = viewModel::hideTopicDialog,
        onSave = { title, description, isActive ->
          viewModel.createTopic(title, description, isActive)
        }
      )
    }
    is TopicDialogState.Edit -> {
      TopicEditDialog(
        topic = dialogState.topic,
        onDismiss = viewModel::hideTopicDialog,
        onSave = { topicId, title, description, isActive ->
          viewModel.updateTopic(topicId, title, description, isActive)
        }
      )
    }
    TopicDialogState.Hidden -> {}
  }
}

@Composable
private fun UsersList(
  users: List<AdminUser>,
  onEdit: (AdminUser) -> Unit,
  onDelete: (String) -> Unit
) {
  LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(16.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
  ) {
    items(users) { user ->
      UserItem(user = user, onEdit = { onEdit(user) }, onDelete = { onDelete(user.id) })
    }
  }
}

@Composable
private fun UserItem(
  user: AdminUser,
  onEdit: () -> Unit,
  onDelete: () -> Unit
) {
  Card(
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(
      modifier = Modifier.padding(16.dp)
    ) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Column(modifier = Modifier.weight(1f)) {
          Text(
            text = user.name,
            style = MaterialTheme.typography.titleMedium
          )
          Text(
            text = "@${user.username}",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.secondary
          )
          Text(
            text = user.email,
            style = MaterialTheme.typography.bodySmall
          )
        }
        
        Column(horizontalAlignment = Alignment.End) {
          Text(
            text = user.role,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.primary
          )
          Text(
            text = if (user.active) "Aktif" else "Pasif",
            style = MaterialTheme.typography.labelSmall,
            color = if (user.active) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
          )
        }
      }
      
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End)
      ) {
        AppButton(
          text = "Düzenle",
          onClick = onEdit,
          variant = ButtonVariant.TERTIARY,
          size = ButtonSize.SMALL
        )
        AppButton(
          text = "Sil",
          onClick = onDelete,
          variant = ButtonVariant.DESTRUCTIVE,
          size = ButtonSize.SMALL
        )
      }
    }
  }
}

@Composable
private fun TopicsList(
  topics: List<Topic>,
  onEdit: (Topic) -> Unit,
  onDelete: (String) -> Unit
) {
  LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(16.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
  ) {
    items(topics) { topic ->
      TopicItem(topic = topic, onEdit = { onEdit(topic) }, onDelete = { onDelete(topic.id) })
    }
  }
}

@Composable
private fun TopicItem(
  topic: Topic,
  onEdit: () -> Unit,
  onDelete: () -> Unit
) {
  Card(
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(
      modifier = Modifier.padding(16.dp)
    ) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Column(modifier = Modifier.weight(1f)) {
          Text(
            text = topic.title,
            style = MaterialTheme.typography.titleMedium
          )
          topic.description?.let {
            Text(
              text = it,
              style = MaterialTheme.typography.bodySmall,
              color = MaterialTheme.colorScheme.secondary
            )
          }
          Text(
            text = "${topic.taskCount} görev",
            style = MaterialTheme.typography.bodySmall
          )
        }
        
        Column(horizontalAlignment = Alignment.End) {
          Text(
            text = if (topic.isActive) "Aktif" else "Pasif",
            style = MaterialTheme.typography.labelSmall,
            color = if (topic.isActive) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
          )
        }
      }
      
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End)
      ) {
        AppButton(
          text = "Düzenle",
          onClick = onEdit,
          variant = ButtonVariant.TERTIARY,
          size = ButtonSize.SMALL
        )
        AppButton(
          text = "Sil",
          onClick = onDelete,
          variant = ButtonVariant.DESTRUCTIVE,
          size = ButtonSize.SMALL
        )
      }
    }
  }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun UserDialog(
  title: String,
  availableTopics: List<Topic>,
  onDismiss: () -> Unit,
  onSave: (String, String, String, String, String, Boolean, List<String>?) -> Unit
) {
  var name by remember { mutableStateOf("") }
  var username by remember { mutableStateOf("") }
  var email by remember { mutableStateOf("") }
  var password by remember { mutableStateOf("") }
  var role by remember { mutableStateOf("MEMBER") }
  var active by remember { mutableStateOf(true) }
  var selectedTopicIds by remember { mutableStateOf<Set<String>>(emptySet()) }

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { Text(title) },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        AppTextField(
          value = name,
          onValueChange = { name = it },
          label = "Ad Soyad",
          modifier = Modifier.fillMaxWidth()
        )
        AppTextField(
          value = username,
          onValueChange = { username = it },
          label = "Kullanıcı Adı",
          modifier = Modifier.fillMaxWidth()
        )
        AppTextField(
          value = email,
          onValueChange = { email = it },
          label = "E-posta",
          modifier = Modifier.fillMaxWidth()
        )
        AppTextField(
          value = password,
          onValueChange = { password = it },
          label = "Şifre",
          isPassword = true,
          modifier = Modifier.fillMaxWidth()
        )
        
        // Role selector
        Text("Rol:", style = MaterialTheme.typography.labelMedium)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
          FilterChip(
            selected = role == "MEMBER",
            onClick = { role = "MEMBER" },
            label = { Text("Member") }
          )
          FilterChip(
            selected = role == "GUEST",
            onClick = { role = "GUEST" },
            label = { Text("Guest") }
          )
        }
        
        AppCheckbox(
          checked = active,
          onCheckedChange = { active = it },
          label = "Aktif"
        )
        
        // Guest kullanıcılar için topic seçici
        if (role == "GUEST" && availableTopics.isNotEmpty()) {
          Spacer(modifier = Modifier.height(8.dp))
          
          Text(
            text = "Görünür Konu Başlıkları:",
            style = MaterialTheme.typography.labelMedium
          )
          
          FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
          ) {
            availableTopics.filter { it.isActive }.forEach { topic ->
              FilterChip(
                selected = selectedTopicIds.contains(topic.id),
                onClick = {
                  selectedTopicIds = if (selectedTopicIds.contains(topic.id)) {
                    selectedTopicIds - topic.id
                  } else {
                    selectedTopicIds + topic.id
                  }
                },
                label = { Text(topic.title) }
              )
            }
          }
        }
      }
    },
    confirmButton = {
      AppButton(
        text = "Kaydet",
        onClick = { 
          val topicIds = if (role == "GUEST" && selectedTopicIds.isNotEmpty()) {
            selectedTopicIds.toList()
          } else null
          onSave(name, username, email, password, role, active, topicIds)
        },
        variant = ButtonVariant.PRIMARY,
        size = ButtonSize.SMALL
      )
    },
    dismissButton = {
      AppButton(
        text = "İptal",
        onClick = onDismiss,
        variant = ButtonVariant.GHOST,
        size = ButtonSize.SMALL
      )
    }
  )
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun UserEditDialog(
  user: AdminUser,
  availableTopics: List<Topic>,
  onDismiss: () -> Unit,
  onSave: (String, String?, String?, Boolean?, String?, List<String>?) -> Unit
) {
  var name by remember { mutableStateOf(user.name) }
  var role by remember { mutableStateOf(user.role) }
  var active by remember { mutableStateOf(user.active) }
  var password by remember { mutableStateOf("") }
  var selectedTopicIds by remember { mutableStateOf(user.visibleTopicIds.toSet()) }

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { Text("Kullanıcıyı Düzenle") },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        AppTextField(
          value = name,
          onValueChange = { name = it },
          label = "Ad Soyad",
          modifier = Modifier.fillMaxWidth()
        )
        
        Text("Rol:", style = MaterialTheme.typography.labelMedium)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
          FilterChip(
            selected = role == "MEMBER",
            onClick = { role = "MEMBER" },
            label = { Text("Member") }
          )
          FilterChip(
            selected = role == "GUEST",
            onClick = { role = "GUEST" },
            label = { Text("Guest") }
          )
        }
        
        AppCheckbox(
          checked = active,
          onCheckedChange = { active = it },
          label = "Aktif"
        )
        
        AppTextField(
          value = password,
          onValueChange = { password = it },
          label = "Yeni Şifre (opsiyonel)",
          isPassword = true,
          modifier = Modifier.fillMaxWidth()
        )
        
        // Guest kullanıcılar için topic seçici
        if (role == "GUEST" && availableTopics.isNotEmpty()) {
          Spacer(modifier = Modifier.height(8.dp))
          
          Text(
            text = "Görünür Konu Başlıkları:",
            style = MaterialTheme.typography.labelMedium
          )
          
          FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
          ) {
            availableTopics.filter { it.isActive }.forEach { topic ->
              FilterChip(
                selected = selectedTopicIds.contains(topic.id),
                onClick = {
                  selectedTopicIds = if (selectedTopicIds.contains(topic.id)) {
                    selectedTopicIds - topic.id
                  } else {
                    selectedTopicIds + topic.id
                  }
                },
                label = { Text(topic.title) }
              )
            }
          }
        }
      }
    },
    confirmButton = {
      AppButton(
        text = "Kaydet",
        onClick = { 
          val topicIdsChanged = selectedTopicIds.toList() != user.visibleTopicIds
          onSave(
            user.id, 
            if (name != user.name) name else null,
            if (role != user.role) role else null,
            if (active != user.active) active else null,
            if (password.isNotEmpty()) password else null,
            if (topicIdsChanged && role == "GUEST") selectedTopicIds.toList() else null
          ) 
        },
        variant = ButtonVariant.PRIMARY,
        size = ButtonSize.SMALL
      )
    },
    dismissButton = {
      AppButton(
        text = "İptal",
        onClick = onDismiss,
        variant = ButtonVariant.GHOST,
        size = ButtonSize.SMALL
      )
    }
  )
}

@Composable
private fun TopicDialog(
  title: String,
  onDismiss: () -> Unit,
  onSave: (String, String?, Boolean) -> Unit
) {
  var topicTitle by remember { mutableStateOf("") }
  var description by remember { mutableStateOf("") }
  var isActive by remember { mutableStateOf(true) }

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { Text(title) },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        AppTextField(
          value = topicTitle,
          onValueChange = { topicTitle = it },
          label = "Başlık",
          modifier = Modifier.fillMaxWidth()
        )
        AppTextArea(
          value = description,
          onValueChange = { description = it },
          label = "Açıklama (opsiyonel)",
          modifier = Modifier.fillMaxWidth(),
          minLines = 3
        )
        AppCheckbox(
          checked = isActive,
          onCheckedChange = { isActive = it },
          label = "Aktif"
        )
      }
    },
    confirmButton = {
      AppButton(
        text = "Kaydet",
        onClick = { 
          onSave(topicTitle, description.takeIf { it.isNotEmpty() }, isActive) 
        },
        variant = ButtonVariant.PRIMARY,
        size = ButtonSize.SMALL
      )
    },
    dismissButton = {
      AppButton(
        text = "İptal",
        onClick = onDismiss,
        variant = ButtonVariant.GHOST,
        size = ButtonSize.SMALL
      )
    }
  )
}

@Composable
private fun TopicEditDialog(
  topic: Topic,
  onDismiss: () -> Unit,
  onSave: (String, String?, String?, Boolean?) -> Unit
) {
  var topicTitle by remember { mutableStateOf(topic.title) }
  var description by remember { mutableStateOf(topic.description ?: "") }
  var isActive by remember { mutableStateOf(topic.isActive) }

  AlertDialog(
    onDismissRequest = onDismiss,
    title = { Text("Konu Başlığını Düzenle") },
    text = {
      Column(
        verticalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        AppTextField(
          value = topicTitle,
          onValueChange = { topicTitle = it },
          label = "Başlık",
          modifier = Modifier.fillMaxWidth()
        )
        AppTextArea(
          value = description,
          onValueChange = { description = it },
          label = "Açıklama (opsiyonel)",
          modifier = Modifier.fillMaxWidth(),
          minLines = 3
        )
        AppCheckbox(
          checked = isActive,
          onCheckedChange = { isActive = it },
          label = "Aktif"
        )
      }
    },
    confirmButton = {
      AppButton(
        text = "Kaydet",
        onClick = { 
          onSave(
            topic.id,
            if (topicTitle != topic.title) topicTitle else null,
            if (description != topic.description) description else null,
            if (isActive != topic.isActive) isActive else null
          )
        },
        variant = ButtonVariant.PRIMARY,
        size = ButtonSize.SMALL
      )
    },
    dismissButton = {
      AppButton(
        text = "İptal",
        onClick = onDismiss,
        variant = ButtonVariant.GHOST,
        size = ButtonSize.SMALL
      )
    }
  )
}

@Composable
private fun ErrorMessage(message: String) {
  Box(
    modifier = Modifier.fillMaxSize(),
    contentAlignment = Alignment.Center
  ) {
    Text(
      text = "Hata: $message",
      color = MaterialTheme.colorScheme.error
    )
  }
}
