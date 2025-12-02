package com.example.minitasktracker.domain.model

data class Topic(
  val id: String,
  val title: String,
  val description: String?,
  val isActive: Boolean,
  val createdAt: String,
  val updatedAt: String,
  val taskCount: Int = 0,
  val tasks: List<Task> = emptyList()
)
