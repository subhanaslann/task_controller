package com.example.minitasktracker.data

sealed class Result<out T> {
  data class Success<T>(val data: T) : Result<T>()
  data class Error(val exception: AppException) : Result<Nothing>()
}

sealed class AppException(override val message: String) : Exception(message) {
  data class NetworkError(override val message: String = "Network error occurred") : AppException(message)
  data class ServerError(val code: String, override val message: String) : AppException(message)
  data class UnauthorizedError(override val message: String = "Unauthorized") : AppException(message)
  data class ValidationError(override val message: String = "Validation failed") : AppException(message)
  data class UnknownError(override val message: String = "Unknown error occurred") : AppException(message)
}

fun <T> Result<T>.getOrNull(): T? = when (this) {
  is Result.Success -> data
  is Result.Error -> null
}

fun <T> Result<T>.getOrThrow(): T = when (this) {
  is Result.Success -> data
  is Result.Error -> throw exception
}
