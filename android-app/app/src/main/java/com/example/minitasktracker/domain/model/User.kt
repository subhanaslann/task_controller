package com.example.minitasktracker.domain.model

data class User(
  val id: String,
  val name: String,
  val username: String,
  val email: String,
  val role: Role,
  val active: Boolean
)
