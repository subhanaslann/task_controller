package com.example.minitasktracker.data.remote.dto

import kotlinx.serialization.Serializable

// User management DTOs
@Serializable
data class CreateUserRequest(
  val name: String,
  val username: String,
  val email: String,
  val password: String,
  val role: String,
  val active: Boolean = true,
  val visibleTopicIds: List<String>? = null
)

@Serializable
data class UpdateUserRequest(
  val name: String? = null,
  val role: String? = null,
  val active: Boolean? = null,
  val password: String? = null,
  val visibleTopicIds: List<String>? = null
)

@Serializable
data class UserResponse(
  val user: UserDetailDto
)

@Serializable
data class UsersResponse(
  val users: List<UserDetailDto>
)

@Serializable
data class UserDetailDto(
  val id: String,
  val name: String,
  val username: String,
  val email: String,
  val role: String,
  val active: Boolean,
  val visibleTopicIds: List<String> = emptyList(),
  val createdAt: String,
  val updatedAt: String
)

// Task management DTOs
@Serializable
data class CreateTaskRequest(
  val topicId: String? = null,
  val title: String,
  val note: String? = null,
  val assigneeId: String? = null,
  val status: String? = "TODO",
  val priority: String? = "NORMAL",
  val dueDate: String? = null
)

@Serializable
data class UpdateTaskRequest(
  val title: String? = null,
  val note: String? = null,
  val status: String? = null,
  val priority: String? = null,
  val dueDate: String? = null
)

// Member task creation (self-assign)
@Serializable
data class CreateMemberTaskRequest(
  val topicId: String,
  val title: String,
  val note: String? = null,
  val priority: String? = "NORMAL",
  val dueDate: String? = null
)

@Serializable
data class TaskResponse(
  val task: TaskDto
)

@Serializable
data class DeleteResponse(
  val success: Boolean,
  val message: String? = null
)

// Topic management DTOs
@Serializable
data class CreateTopicRequest(
  val title: String,
  val description: String? = null,
  val isActive: Boolean = true
)

@Serializable
data class UpdateTopicRequest(
  val title: String? = null,
  val description: String? = null,
  val isActive: Boolean? = null
)
