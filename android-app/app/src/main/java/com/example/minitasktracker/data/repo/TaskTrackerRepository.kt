package com.example.minitasktracker.data.repo

import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.remote.api.TaskApi
import com.example.minitasktracker.data.remote.dto.ErrorResponse
import com.example.minitasktracker.data.remote.dto.UpdateTaskStatusRequest
import com.example.minitasktracker.domain.model.*
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TaskTrackerRepository @Inject constructor(
  private val taskApi: TaskApi,
  private val json: Json
) {

  suspend fun fetchMyActiveTasks(): Result<List<Task>> {
    return executeTaskRequest("my_active") {
      taskApi.getTasks("my_active")
    }
  }

  suspend fun fetchTeamActiveTasks(): Result<List<Task>> {
    return executeTaskRequest("team_active") {
      taskApi.getTasks("team_active")
    }
  }

  suspend fun fetchMyDoneTasks(): Result<List<Task>> {
    return executeTaskRequest("my_done") {
      taskApi.getTasks("my_done")
    }
  }

  suspend fun updateMyTaskStatus(taskId: String, status: TaskStatus): Result<Task> {
    return try {
      val response = taskApi.updateTaskStatus(
        taskId,
        UpdateTaskStatusRequest(status.name)
      )
      Timber.d("Task status updated: $taskId -> $status")
      Result.Success(response.toDomainModel())
      
    } catch (e: HttpException) {
      Timber.e(e, "Update task status HTTP error: ${e.code()}")
      Result.Error(parseHttpError(e))
      
    } catch (e: IOException) {
      Timber.e(e, "Update task status network error")
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
      
    } catch (e: Exception) {
      Timber.e(e, "Update task status unknown error")
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun getActiveTopics(): Result<List<com.example.minitasktracker.domain.model.Topic>> {
    return try {
      val response = taskApi.getActiveTopics()
      Timber.d("Fetched ${response.topics.size} active topics")
      Result.Success(response.topics.map { it.toDomainTopicModel() })
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun createMemberTask(
    topicId: String,
    title: String,
    note: String?,
    priority: Priority,
    dueDate: String?
  ): Result<Task> {
    return try {
      val request = com.example.minitasktracker.data.remote.dto.CreateMemberTaskRequest(
        topicId = topicId,
        title = title,
        note = note,
        priority = priority.name,
        dueDate = dueDate
      )
      val response = taskApi.createMemberTask(request)
      Timber.d("Created member task: ${response.task.title}")
      Result.Success(response.task.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun updateMemberTask(
    taskId: String,
    title: String?,
    note: String?,
    status: TaskStatus?,
    priority: Priority?,
    dueDate: String?
  ): Result<Task> {
    return try {
      val request = com.example.minitasktracker.data.remote.dto.UpdateTaskRequest(
        title = title,
        note = note,
        status = status?.name,
        priority = priority?.name,
        dueDate = dueDate
      )
      val response = taskApi.updateMemberTask(taskId, request)
      Timber.d("Updated member task: $taskId")
      Result.Success(response.task.toDomainModel())
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun deleteMemberTask(taskId: String): Result<Boolean> {
    return try {
      val response = taskApi.deleteMemberTask(taskId)
      Timber.d("Deleted member task: $taskId")
      Result.Success(response.success)
    } catch (e: HttpException) {
      Result.Error(parseHttpError(e))
    } catch (e: IOException) {
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
    } catch (e: Exception) {
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  private suspend fun executeTaskRequest(
    scope: String,
    request: suspend () -> com.example.minitasktracker.data.remote.dto.TasksResponse
  ): Result<List<Task>> {
    return try {
      val response = request()
      val tasks = response.tasks.map { it.toDomainModel() }
      Timber.d("Fetched ${tasks.size} tasks for scope: $scope")
      Result.Success(tasks)
      
    } catch (e: HttpException) {
      Timber.e(e, "Fetch tasks HTTP error: ${e.code()}")
      Result.Error(parseHttpError(e))
      
    } catch (e: IOException) {
      Timber.e(e, "Fetch tasks network error")
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
      
    } catch (e: Exception) {
      Timber.e(e, "Fetch tasks unknown error")
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  private fun parseHttpError(exception: HttpException): AppException {
    return try {
      val errorBody = exception.response()?.errorBody()?.string()
      if (errorBody != null) {
        val errorResponse = json.decodeFromString<ErrorResponse>(errorBody)
        when (exception.code()) {
          401 -> AppException.UnauthorizedError(errorResponse.error.message)
          403 -> AppException.UnauthorizedError("You don't have permission to perform this action")
          400 -> AppException.ValidationError(errorResponse.error.message)
          404 -> AppException.ValidationError("Task not found")
          else -> AppException.ServerError(errorResponse.error.code, errorResponse.error.message)
        }
      } else {
        AppException.ServerError("HTTP_${exception.code()}", "Server error: ${exception.message()}")
      }
    } catch (e: Exception) {
      AppException.ServerError("PARSE_ERROR", "Failed to parse error: ${exception.message()}")
    }
  }

  private fun com.example.minitasktracker.data.remote.dto.TaskDto.toDomainModel(): Task {
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

  private fun com.example.minitasktracker.data.remote.dto.TopicDto.toDomainTopicModel(): com.example.minitasktracker.domain.model.Topic {
    return com.example.minitasktracker.domain.model.Topic(
      id = id,
      title = title,
      description = description,
      isActive = isActive,
      createdAt = createdAt,
      updatedAt = updatedAt,
      taskCount = _count?.tasks ?: tasks.size,
      tasks = tasks.map { it.toDomainModel() }
    )
  }
}
