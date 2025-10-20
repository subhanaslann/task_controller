package com.example.minitasktracker.features.tasks.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.data.repo.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
class HomeViewModel @Inject constructor(
  val sessionManager: SessionManager,
  private val authRepository: AuthRepository
) : ViewModel() {

  private val _showAboutDialog = MutableStateFlow(false)
  val showAboutDialog: StateFlow<Boolean> = _showAboutDialog.asStateFlow()

  fun logout() {
    viewModelScope.launch {
      authRepository.logout()
      Timber.d("User logged out")
    }
  }

  fun showAboutDialog() {
    _showAboutDialog.value = true
  }

  fun dismissAboutDialog() {
    _showAboutDialog.value = false
  }
}
