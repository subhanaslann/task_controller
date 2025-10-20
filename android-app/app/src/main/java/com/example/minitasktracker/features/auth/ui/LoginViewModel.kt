package com.example.minitasktracker.features.auth.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.repo.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

data class LoginUiState(
  val isLoading: Boolean = false,
  val error: String? = null,
  val isSuccess: Boolean = false
)

@HiltViewModel
class LoginViewModel @Inject constructor(
  private val authRepository: AuthRepository
) : ViewModel() {

  private val _uiState = MutableStateFlow(LoginUiState())
  val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

  fun login(usernameOrEmail: String, password: String) {
    // Validation
    if (usernameOrEmail.isBlank()) {
      _uiState.value = LoginUiState(error = "Kullanıcı adı veya e-posta gerekli")
      return
    }
    if (password.isBlank()) {
      _uiState.value = LoginUiState(error = "Şifre gerekli")
      return
    }

    viewModelScope.launch {
      _uiState.value = LoginUiState(isLoading = true)

      when (val result = authRepository.login(usernameOrEmail, password)) {
        is Result.Success -> {
          Timber.d("Login successful: ${result.data.userName}")
          _uiState.value = LoginUiState(isSuccess = true)
        }
        is Result.Error -> {
          val errorMessage = mapErrorToMessage(result.exception)
          Timber.e("Login failed: $errorMessage")
          _uiState.value = LoginUiState(error = errorMessage)
        }
      }
    }
  }

  fun clearError() {
    _uiState.value = _uiState.value.copy(error = null)
  }

  private fun mapErrorToMessage(exception: AppException): String {
    return when (exception) {
      is AppException.UnauthorizedError -> "Geçersiz bilgiler"
      is AppException.NetworkError -> "Sunucuya bağlanılamadı"
      is AppException.ValidationError -> exception.message
      is AppException.ServerError -> "Sunucu hatası: ${exception.message}"
      is AppException.UnknownError -> "Beklenmeyen bir hata oluştu"
    }
  }
}
