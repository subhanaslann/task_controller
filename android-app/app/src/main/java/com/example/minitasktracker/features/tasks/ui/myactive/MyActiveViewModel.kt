package com.example.minitasktracker.features.tasks.ui.myactive

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.repo.TaskTrackerRepository
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.TaskStatus
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

sealed class MyActiveUiState {
  data object Loading : MyActiveUiState()
  data class Success(val tasks: List<Task>) : MyActiveUiState()
  data class Error(val message: String) : MyActiveUiState()
}

@HiltViewModel
class MyActiveViewModel @Inject constructor(
  private val taskRepository: TaskTrackerRepository
) : ViewModel() {

  private val _uiState = MutableStateFlow<MyActiveUiState>(MyActiveUiState.Loading)
  val uiState: StateFlow<MyActiveUiState> = _uiState.asStateFlow()

  private val _isRefreshing = MutableStateFlow(false)
  val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

  init {
    loadTasks()
  }

  fun loadTasks() {
    viewModelScope.launch {
      _uiState.value = MyActiveUiState.Loading
      
      when (val result = taskRepository.fetchMyActiveTasks()) {
        is Result.Success -> {
          Timber.d("Loaded ${result.data.size} active tasks")
          _uiState.value = MyActiveUiState.Success(result.data)
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Failed to load tasks: $errorMessage")
          _uiState.value = MyActiveUiState.Error(errorMessage)
        }
      }
    }
  }

  fun refresh() {
    viewModelScope.launch {
      _isRefreshing.value = true
      
      when (val result = taskRepository.fetchMyActiveTasks()) {
        is Result.Success -> {
          Timber.d("Refreshed ${result.data.size} active tasks")
          _uiState.value = MyActiveUiState.Success(result.data)
        }
        is Result.Error -> {
          // Keep existing data on refresh error, just log
          Timber.e("Failed to refresh tasks")
        }
      }
      
      _isRefreshing.value = false
    }
  }

  fun refreshTasks() {
    refresh()
  }

  fun updateTaskStatus(taskId: String, newStatus: TaskStatus) {
    viewModelScope.launch {
      Timber.d("Updating task $taskId to $newStatus")
      
      when (val result = taskRepository.updateMyTaskStatus(taskId, newStatus)) {
        is Result.Success -> {
          Timber.d("Task status updated successfully")
          // Reload tasks to reflect changes
          refresh()
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Failed to update task status: $errorMessage")
          // Show error but don't change UI state - user can retry
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
