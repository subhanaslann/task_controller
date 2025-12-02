package com.example.minitasktracker.domain.model

enum class TaskStatus {
  TODO,
  IN_PROGRESS,
  DONE
}

enum class Priority {
  LOW,
  NORMAL,
  HIGH
}

data class Task(
  val id: String,
  val topicId: String?,
  val topicTitle: String?,
  val title: String,
  val note: String?,
  val assigneeId: String?,
  val assigneeName: String?,
  val status: TaskStatus,
  val priority: Priority,
  val dueDate: String?,
  val createdAt: String,
  val updatedAt: String,
  val completedAt: String?
)
