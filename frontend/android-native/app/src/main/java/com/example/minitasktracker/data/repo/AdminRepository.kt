package com.example.minitasktracker.data.repo

import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.remote.api.AdminApi
import com.example.minitasktracker.data.remote.dto.*
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.TaskStatus
import com.example.minitasktracker.domain.model.Priority
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

data class AdminUser(
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

@Singleton
class AdminRepository @Inject constructor(
  private val adminApi: AdminApi,
  private val json: Json
) {

  // User Management
  suspend fun getUsers(): Result<List<AdminUser>> {
    return try {
      val response = adminApi.getUsers()
      Timber.d("Fetched ${response.users.size} users")
      Result.Success(response.users.map { it.toDomain() })
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun createUser(
    name: String,
    username: String,
    email: String,
    password: String,
    role: String,
    active: Boolean = true,
    visibleTopicIds: List<String>? = null
  ): Result<AdminUser> {
    return try {
      val request = CreateUserRequest(name, username, email, password, role, active, visibleTopicIds)
      val response = adminApi.createUser(request)
      Timber.d("Created user: ${response.user.username}")
      Result.Success(response.user.toDomain())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun updateUser(
    userId: String,
    name: String? = null,
    role: String? = null,
    active: Boolean? = null,
    password: String? = null,
    visibleTopicIds: List<String>? = null
  ): Result<AdminUser> {
    return try {
      val request = UpdateUserRequest(name, role, active, password, visibleTopicIds)
      val response = adminApi.updateUser(userId, request)
      Timber.d("Updated user: $userId")
      Result.Success(response.user.toDomain())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  // Task Management
  suspend fun getAllTasks(): Result<List<Task>> {
    return try {
      val response = adminApi.getAllTasks()
      Timber.d("Fetched ${response.tasks.size} tasks (admin)")
      Result.Success(response.tasks.map { it.toDomainModel() })
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun createTask(
    topicId: String? = null,
    title: String,
    note: String? = null,
    assigneeId: String? = null,
    status: String = "TODO",
    priority: String = "NORMAL",
    dueDate: String? = null
  ): Result<Task> {
    return try {
      val request = CreateTaskRequest(topicId, title, note, assigneeId, status, priority, dueDate)
      val response = adminApi.createTask(request)
      Timber.d("Created task: ${response.task.title}")
      Result.Success(response.task.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun updateTask(
    taskId: String,
    title: String? = null,
    note: String? = null,
    status: String? = null,
    priority: String? = null,
    dueDate: String? = null
  ): Result<Task> {
    return try {
      val request = UpdateTaskRequest(title, note, status, priority, dueDate)
      val response = adminApi.updateTask(taskId, request)
      Timber.d("Updated task: $taskId")
      Result.Success(response.task.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun deleteTask(taskId: String): Result<Boolean> {
    return try {
      val response = adminApi.deleteTask(taskId)
      Timber.d("Deleted task: $taskId")
      Result.Success(response.success)
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun deleteUser(userId: String): Result<Boolean> {
    return try {
      val response = adminApi.deleteUser(userId)
      Timber.d("Deleted user: $userId")
      Result.Success(response.success)
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  // Topic Management
  suspend fun getTopics(): Result<List<com.example.minitasktracker.domain.model.Topic>> {
    return try {
      val response = adminApi.getTopics()
      Timber.d("Fetched ${response.topics.size} topics")
      Result.Success(response.topics.map { it.toDomainModel() })
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun createTopic(
    title: String,
    description: String? = null,
    isActive: Boolean = true
  ): Result<com.example.minitasktracker.domain.model.Topic> {
    return try {
      val request = CreateTopicRequest(title, description, isActive)
      val response = adminApi.createTopic(request)
      Timber.d("Created topic: ${response.topic.title}")
      Result.Success(response.topic.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun updateTopic(
    topicId: String,
    title: String? = null,
    description: String? = null,
    isActive: Boolean? = null
  ): Result<com.example.minitasktracker.domain.model.Topic> {
    return try {
      val request = UpdateTopicRequest(title, description, isActive)
      val response = adminApi.updateTopic(topicId, request)
      Timber.d("Updated topic: $topicId")
      Result.Success(response.topic.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  suspend fun deleteTopic(topicId: String): Result<Boolean> {
    return try {
      val response = adminApi.deleteTopic(topicId)
      Timber.d("Deleted topic: $topicId")
      Result.Success(response.success)
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError())
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error"))
    }
  }

  private fun parseHttpError(exception: HttpException): AppException {
    return try {
      val errorBody = exception.response()?.errorBody()?.string()
      if (errorBody != null) {
        val errorResponse = json.decodeFromString<ErrorResponse>(errorBody)
        when (exception.code()) {
          401 -> AppException.UnauthorizedError(errorResponse.error.message)
          403 -> AppException.UnauthorizedError("Bu işlem için yetkiniz yok")
          400 -> AppException.ValidationError(errorResponse.error.message)
          409 -> AppException.ServerError(errorResponse.error.code, errorResponse.error.message)
          else -> AppException.ServerError(errorResponse.error.code, errorResponse.error.message)
        }
      } else {
        AppException.ServerError("HTTP_${exception.code()}", "Sunucu hatası")
      }
    } catch (e: Exception) {
      AppException.ServerError("PARSE_ERROR", "Hata ayrıştırılamadı")
    }
  }

  private fun UserDetailDto.toDomain(): AdminUser {
    return AdminUser(id, name, username, email, role, active, visibleTopicIds, createdAt, updatedAt)
  }

  private fun TaskDto.toDomainModel(): Task {
    return Task(
      id = id,
      topicId = topicId,
      topicTitle = topic?.title,
      title = title,
      note = note,
      assigneeId = assigneeId,
      assigneeName = assignee?.name,
      status = TaskStatus.valueOf(status),
      priority = Priority.valueOf(priority),
      dueDate = dueDate,
      createdAt = createdAt,
      updatedAt = updatedAt,
      completedAt = completedAt
    )
  }

  private fun TopicDto.toDomainModel(): com.example.minitasktracker.domain.model.Topic {
    return com.example.minitasktracker.domain.model.Topic(
      id = id,
      title = title,
      description = description,
      isActive = isActive,
      createdAt = createdAt,
      updatedAt = updatedAt,
      taskCount = _count?.tasks ?: 0,
      tasks = tasks.map { it.toDomainModel() }
    )
  }
}
