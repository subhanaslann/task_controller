package com.example.minitasktracker.features.tasks.ui.teamactive

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.data.repo.TaskTrackerRepository
import com.example.minitasktracker.domain.model.Priority
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.Topic
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

sealed class TeamActiveUiState {
  data object Loading : TeamActiveUiState()
  data class Success(
    val topics: List<Topic>,
    val userRole: String,
    val userId: String,
    val visibleTopicIds: List<String> = emptyList()
  ) : TeamActiveUiState()
  data class Error(val message: String) : TeamActiveUiState()
}

sealed class CreateTaskDialogState {
  data object Hidden : CreateTaskDialogState()
  data class Visible(val topicId: String, val topicTitle: String) : CreateTaskDialogState()
}

sealed class EditTaskDialogState {
  data object Hidden : EditTaskDialogState()
  data class Visible(val task: Task, val canEdit: Boolean) : EditTaskDialogState()
}

@HiltViewModel
class TeamActiveViewModel @Inject constructor(
  private val taskRepository: TaskTrackerRepository,
  private val sessionManager: SessionManager
) : ViewModel() {

  private val _uiState = MutableStateFlow<TeamActiveUiState>(TeamActiveUiState.Loading)
  val uiState: StateFlow<TeamActiveUiState> = _uiState.asStateFlow()

  private val _isRefreshing = MutableStateFlow(false)
  val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

  var createTaskDialogState by mutableStateOf<CreateTaskDialogState>(CreateTaskDialogState.Hidden)
    private set

  var editTaskDialogState by mutableStateOf<EditTaskDialogState>(EditTaskDialogState.Hidden)
    private set

  init {
    loadTopics()
  }

  fun loadTopics() {
    viewModelScope.launch {
      _uiState.value = TeamActiveUiState.Loading
      
      val session = sessionManager.userSession.first()
      val userRole = session?.userRole ?: "GUEST"
      val userId = session?.userId ?: ""
      val visibleTopicIds = session?.visibleTopicIds ?: emptyList()
      
      when (val result = taskRepository.getActiveTopics()) {
        is Result.Success -> {
          Timber.d("Loaded ${result.data.size} active topics")
          _uiState.value = TeamActiveUiState.Success(
            topics = result.data,
            userRole = userRole,
            userId = userId,
            visibleTopicIds = visibleTopicIds
          )
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Failed to load topics: $errorMessage")
          _uiState.value = TeamActiveUiState.Error(errorMessage)
        }
      }
    }
  }

  fun refresh() {
    viewModelScope.launch {
      _isRefreshing.value = true
      
      val session = sessionManager.userSession.first()
      val userRole = session?.userRole ?: "GUEST"
      val userId = session?.userId ?: ""
      val visibleTopicIds = session?.visibleTopicIds ?: emptyList()
      
      when (val result = taskRepository.getActiveTopics()) {
        is Result.Success -> {
          Timber.d("Refreshed ${result.data.size} active topics")
          _uiState.value = TeamActiveUiState.Success(
            topics = result.data,
            userRole = userRole,
            userId = userId,
            visibleTopicIds = visibleTopicIds
          )
        }
        is Result.Error -> {
          Timber.e("Failed to refresh topics")
        }
      }
      
      _isRefreshing.value = false
    }
  }

  fun refreshTasks() {
    refresh()
  }

  fun showCreateTaskDialog(topicId: String, topicTitle: String) {
    createTaskDialogState = CreateTaskDialogState.Visible(topicId, topicTitle)
  }

  fun hideCreateTaskDialog() {
    createTaskDialogState = CreateTaskDialogState.Hidden
  }

  fun createTask(
    topicId: String,
    title: String,
    note: String?,
    priority: Priority,
    dueDate: String
  ) {
    viewModelScope.launch {
      when (taskRepository.createMemberTask(topicId, title, note, priority, dueDate)) {
        is Result.Success -> {
          Timber.d("Task created successfully")
          hideCreateTaskDialog()
          loadTopics()
        }
        is Result.Error -> {
          Timber.e("Failed to create task")
          // Handle error
        }
      }
    }
  }

  fun showEditTaskDialog(task: Task, userRole: String, userId: String) {
    val canEdit = userRole == "ADMIN" || task.assigneeId == userId
    editTaskDialogState = EditTaskDialogState.Visible(task, canEdit)
  }

  fun hideEditTaskDialog() {
    editTaskDialogState = EditTaskDialogState.Hidden
  }

  fun updateTask(
    taskId: String,
    title: String?,
    note: String?,
    status: com.example.minitasktracker.domain.model.TaskStatus?,
    priority: Priority?,
    dueDate: String?
  ) {
    viewModelScope.launch {
      when (taskRepository.updateMemberTask(taskId, title, note, status, priority, dueDate)) {
        is Result.Success -> {
          Timber.d("Task updated successfully")
          hideEditTaskDialog()
          loadTopics()
        }
        is Result.Error -> {
          Timber.e("Failed to update task")
          // Handle error
        }
      }
    }
  }

  private fun mapErrorToMessage(exception: AppException): String {
    return when (exception) {
      is AppException.NetworkError -> "İnternet bağlantınızı kontrol edin"
      is AppException.UnauthorizedError -> "Oturum süreniz dolmuş, lütfen tekrar giriş yapın"
      is AppException.ValidationError -> exception.message
      is AppException.ServerError -> "Sunucu hatası"
      is AppException.UnknownError -> "Beklenmeyen bir hata oluştu"
    }
  }
}
