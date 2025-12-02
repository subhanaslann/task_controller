package com.example.minitasktracker.features.tasks.ui.completed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.repo.TaskTrackerRepository
import com.example.minitasktracker.domain.model.Task
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

sealed class CompletedUiState {
  data object Loading : CompletedUiState()
  data class Success(val tasks: List<Task>) : CompletedUiState()
  data class Error(val message: String) : CompletedUiState()
}

@HiltViewModel
class CompletedViewModel @Inject constructor(
  private val taskRepository: TaskTrackerRepository
) : ViewModel() {

  private val _uiState = MutableStateFlow<CompletedUiState>(CompletedUiState.Loading)
  val uiState: StateFlow<CompletedUiState> = _uiState.asStateFlow()

  private val _isRefreshing = MutableStateFlow(false)
  val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

  init {
    loadTasks()
  }

  fun loadTasks() {
    viewModelScope.launch {
      _uiState.value = CompletedUiState.Loading
      
      when (val result = taskRepository.fetchMyDoneTasks()) {
        is Result.Success -> {
          Timber.d("Loaded ${result.data.size} completed tasks")
          _uiState.value = CompletedUiState.Success(result.data)
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Failed to load completed tasks: $errorMessage")
          _uiState.value = CompletedUiState.Error(errorMessage)
        }
      }
    }
  }

  fun refreshTasks() {
    viewModelScope.launch {
      _isRefreshing.value = true
      
      when (val result = taskRepository.fetchMyDoneTasks()) {
        is Result.Success -> {
          Timber.d("Refreshed ${result.data.size} completed tasks")
          _uiState.value = CompletedUiState.Success(result.data)
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Failed to refresh completed tasks: $errorMessage")
          _uiState.value = CompletedUiState.Error(errorMessage)
        }
      }
      
      _isRefreshing.value = false
    }
  }

  fun refresh() {
    viewModelScope.launch {
      _isRefreshing.value = true
      
      when (val result = taskRepository.fetchMyDoneTasks()) {
        is Result.Success -> {
          Timber.d("Refreshed ${result.data.size} completed tasks")
          _uiState.value = CompletedUiState.Success(result.data)
        }
        is Result.Error -> {
          Timber.e("Failed to refresh completed tasks")
        }
      }
      
      _isRefreshing.value = false
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
