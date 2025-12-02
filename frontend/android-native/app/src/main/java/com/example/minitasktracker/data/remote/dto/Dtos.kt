package com.example.minitasktracker.data.remote.dto

import kotlinx.serialization.Serializable

// Auth DTOs
@Serializable
data class LoginRequest(
  val usernameOrEmail: String,
  val password: String
)

@Serializable
data class AuthResponse(
  val token: String,
  val user: UserDto
)

@Serializable
data class UserDto(
  val id: String,
  val name: String,
  val username: String,
  val email: String,
  val role: String,
  val active: Boolean,
  val visibleTopicIds: List<String> = emptyList()
)

// Topic DTOs
@Serializable
data class TopicDto(
  val id: String,
  val title: String,
  val description: String? = null,
  val isActive: Boolean,
  val createdAt: String,
  val updatedAt: String,
  val _count: TaskCountDto? = null,
  val tasks: List<TaskDto> = emptyList()
)

@Serializable
data class TaskCountDto(
  val tasks: Int
)

@Serializable
data class TopicsResponse(
  val topics: List<TopicDto>
)

@Serializable
data class TopicResponse(
  val topic: TopicDto
)

// Task DTOs
@Serializable
data class TaskDto(
  val id: String,
  val topicId: String? = null,
  val title: String,
  val note: String? = null,
  val assigneeId: String? = null,
  val status: String,
  val priority: String,
  val dueDate: String? = null,
  val createdAt: String,
  val updatedAt: String,
  val completedAt: String? = null,
  val topic: TopicRefDto? = null,
  val assignee: AssigneeDto? = null
)

@Serializable
data class TopicRefDto(
  val id: String,
  val title: String
)

@Serializable
data class AssigneeDto(
  val id: String,
  val name: String,
  val username: String? = null
)

@Serializable
data class TasksResponse(
  val tasks: List<TaskDto>
)

@Serializable
data class UpdateTaskStatusRequest(
  val status: String
)

// Error response from server
@Serializable
data class ErrorResponse(
  val error: ErrorDetail
)

@Serializable
data class ErrorDetail(
  val code: String,
  val message: String
)
