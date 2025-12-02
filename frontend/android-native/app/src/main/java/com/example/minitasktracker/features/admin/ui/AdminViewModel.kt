package com.example.minitasktracker.features.admin.ui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.repo.AdminRepository
import com.example.minitasktracker.data.repo.AdminUser
import com.example.minitasktracker.domain.model.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminViewModel @Inject constructor(
  private val adminRepository: AdminRepository
) : ViewModel() {

  var usersState by mutableStateOf<UsersState>(UsersState.Loading)
    private set

  var topicsState by mutableStateOf<TopicsState>(TopicsState.Loading)
    private set

  var userDialogState by mutableStateOf<UserDialogState>(UserDialogState.Hidden)
    private set

  var topicDialogState by mutableStateOf<TopicDialogState>(TopicDialogState.Hidden)
    private set

  init {
    loadUsers()
    loadTopics()
  }

  // Users
  fun loadUsers() {
    viewModelScope.launch {
      usersState = UsersState.Loading
      when (val result = adminRepository.getUsers()) {
        is Result.Success -> usersState = UsersState.Success(result.data)
        is Result.Error -> usersState = UsersState.Error(result.exception.message)
      }
    }
  }

  fun showCreateUserDialog() {
    userDialogState = UserDialogState.Create
  }

  fun showEditUserDialog(user: AdminUser) {
    userDialogState = UserDialogState.Edit(user)
  }

  fun hideUserDialog() {
    userDialogState = UserDialogState.Hidden
  }

  fun createUser(name: String, username: String, email: String, password: String, role: String, active: Boolean, visibleTopicIds: List<String>?) {
    viewModelScope.launch {
      when (adminRepository.createUser(name, username, email, password, role, active, visibleTopicIds)) {
        is Result.Success -> {
          hideUserDialog()
          loadUsers()
        }
        is Result.Error -> { /* Handle error */ }
      }
    }
  }

  fun updateUser(userId: String, name: String?, role: String?, active: Boolean?, password: String?, visibleTopicIds: List<String>?) {
    viewModelScope.launch {
      when (adminRepository.updateUser(userId, name, role, active, password, visibleTopicIds)) {
        is Result.Success -> {
          hideUserDialog()
          loadUsers()
        }
        is Result.Error -> { /* Handle error */ }
      }
    }
  }

  fun deleteUser(userId: String) {
    viewModelScope.launch {
      when (adminRepository.deleteUser(userId)) {
        is Result.Success -> loadUsers()
        is Result.Error -> { /* Handle error */ }
      }
    }
  }

  // Topics
  fun loadTopics() {
    viewModelScope.launch {
      topicsState = TopicsState.Loading
      when (val result = adminRepository.getTopics()) {
        is Result.Success -> topicsState = TopicsState.Success(result.data)
        is Result.Error -> topicsState = TopicsState.Error(result.exception.message)
      }
    }
  }

  fun showCreateTopicDialog() {
    topicDialogState = TopicDialogState.Create
  }

  fun showEditTopicDialog(topic: Topic) {
    topicDialogState = TopicDialogState.Edit(topic)
  }

  fun hideTopicDialog() {
    topicDialogState = TopicDialogState.Hidden
  }

  fun createTopic(title: String, description: String?, isActive: Boolean) {
    viewModelScope.launch {
      when (adminRepository.createTopic(title, description, isActive)) {
        is Result.Success -> {
          hideTopicDialog()
          loadTopics()
        }
        is Result.Error -> { /* Handle error */ }
      }
    }
  }

  fun updateTopic(topicId: String, title: String?, description: String?, isActive: Boolean?) {
    viewModelScope.launch {
      when (adminRepository.updateTopic(topicId, title, description, isActive)) {
        is Result.Success -> {
          hideTopicDialog()
          loadTopics()
        }
        is Result.Error -> { /* Handle error */ }
      }
    }
  }

  fun deleteTopic(topicId: String) {
    viewModelScope.launch {
      when (adminRepository.deleteTopic(topicId)) {
        is Result.Success -> loadTopics()
        is Result.Error -> { /* Handle error */ }
      }
    }
  }
}

sealed interface UsersState {
  data object Loading : UsersState
  data class Success(val users: List<AdminUser>) : UsersState
  data class Error(val message: String) : UsersState
}

sealed interface TopicsState {
  data object Loading : TopicsState
  data class Success(val topics: List<Topic>) : TopicsState
  data class Error(val message: String) : TopicsState
}

sealed interface UserDialogState {
  data object Hidden : UserDialogState
  data object Create : UserDialogState
  data class Edit(val user: AdminUser) : UserDialogState
}

sealed interface TopicDialogState {
  data object Hidden : TopicDialogState
  data object Create : TopicDialogState
  data class Edit(val topic: Topic) : TopicDialogState
}
