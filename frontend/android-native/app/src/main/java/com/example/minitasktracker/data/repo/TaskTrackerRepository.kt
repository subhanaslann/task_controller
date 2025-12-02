package com.example.minitasktracker.data.repo

import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.remote.FirebaseService
import com.example.minitasktracker.domain.model.*
import com.google.firebase.Timestamp
import com.google.firebase.functions.FirebaseFunctionsException
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TaskTrackerRepository @Inject constructor(
  private val firebaseService: FirebaseService
) {

  suspend fun fetchMyActiveTasks(): Result<List<Task>> {
    return try {
      val tasksData = firebaseService.getMyActiveTasks()
      val tasks = tasksData.map { it.toDomainTask() }
      Timber.d("Fetched ${tasks.size} tasks for scope: my_active")
      Result.Success(tasks)
    } catch (e: Exception) {
      Timber.e(e, "Fetch tasks error")
      Result.Error(parseError(e))
    }
  }

  suspend fun fetchTeamActiveTasks(): Result<List<Task>> {
    return try {
      val tasksData = firebaseService.getTeamActiveTasks()
      val tasks = tasksData.map { it.toDomainTask() }
      Timber.d("Fetched ${tasks.size} tasks for scope: team_active")
      Result.Success(tasks)
    } catch (e: Exception) {
      Timber.e(e, "Fetch tasks error")
      Result.Error(parseError(e))
    }
  }

  suspend fun fetchMyDoneTasks(): Result<List<Task>> {
    return try {
      val tasksData = firebaseService.getMyCompletedTasks()
      val tasks = tasksData.map { it.toDomainTask() }
      Timber.d("Fetched ${tasks.size} tasks for scope: my_done")
      Result.Success(tasks)
    } catch (e: Exception) {
      Timber.e(e, "Fetch tasks error")
      Result.Error(parseError(e))
    }
  }

  suspend fun updateMyTaskStatus(taskId: String, status: TaskStatus): Result<Task> {
    return try {
      val taskData = firebaseService.updateTaskStatus(taskId, status.name)
      Timber.d("Task status updated: $taskId -> $status")
      Result.Success(taskData.toDomainTask())
    } catch (e: Exception) {
      Timber.e(e, "Update task status error")
      Result.Error(parseError(e))
    }
  }

  suspend fun getActiveTopics(): Result<List<Topic>> {
    return try {
      val topicsData = firebaseService.getActiveTopics()
      val topics = topicsData.map { it.toDomainTopic() }
      Timber.d("Fetched ${topics.size} active topics")
      Result.Success(topics)
    } catch (e: Exception) {
      Timber.e(e, "Fetch topics error")
      Result.Error(parseError(e))
    }
  }

  suspend fun createMemberTask(
    topicId: String?,
    title: String,
    note: String?,
    priority: Priority,
    dueDate: String?
  ): Result<Task> {
    return try {
      val data = mutableMapOf<String, Any>(
        "title" to title,
        "priority" to priority.name
      )
      topicId?.let { data["topicId"] = it }
      note?.let { data["note"] = it }
      dueDate?.let { data["dueDate"] = it }

      val taskData = firebaseService.createMemberTask(data)
      Timber.d("Created member task: $title")
      Result.Success(taskData.toDomainTask())
    } catch (e: Exception) {
      Timber.e(e, "Create task error")
      Result.Error(parseError(e))
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
      val data = mutableMapOf<String, Any>("taskId" to taskId)
      title?.let { data["title"] = it }
      note?.let { data["note"] = it }
      status?.let { data["status"] = it.name }
      priority?.let { data["priority"] = it.name }
      dueDate?.let { data["dueDate"] = it }

      val taskData = firebaseService.updateMemberTask(data)
      Timber.d("Updated member task: $taskId")
      Result.Success(taskData.toDomainTask())
    } catch (e: Exception) {
      Timber.e(e, "Update task error")
      Result.Error(parseError(e))
    }
  }

  suspend fun deleteMemberTask(taskId: String): Result<Boolean> {
    return try {
      firebaseService.deleteMemberTask(taskId)
      Timber.d("Deleted member task: $taskId")
      Result.Success(true)
    } catch (e: Exception) {
      Timber.e(e, "Delete task error")
      Result.Error(parseError(e))
    }
  }

  private fun parseError(e: Exception): AppException {
    return when (e) {
      is FirebaseFunctionsException -> {
        when (e.code) {
          FirebaseFunctionsException.Code.UNAUTHENTICATED ->
            AppException.UnauthorizedError(e.message ?: "Unauthorized")
          FirebaseFunctionsException.Code.PERMISSION_DENIED ->
            AppException.UnauthorizedError(e.message ?: "Permission denied")
          FirebaseFunctionsException.Code.INVALID_ARGUMENT ->
            AppException.ValidationError(e.message ?: "Invalid input")
          FirebaseFunctionsException.Code.NOT_FOUND ->
            AppException.ValidationError(e.message ?: "Not found")
          else ->
            AppException.ServerError(e.code.name, e.message ?: "Server error")
        }
      }
      else -> AppException.UnknownError(e.message ?: "Unknown error")
    }
  }

  private fun Map<String, Any>.toDomainTask(): Task {
    return Task(
      id = this["id"] as String,
      topicId = this["topicId"] as? String,
      topicTitle = null,
      title = this["title"] as String,
      note = this["note"] as? String,
      assigneeId = this["assigneeId"] as? String,
      assigneeName = null,
      status = TaskStatus.valueOf(this["status"] as String),
      priority = Priority.valueOf(this["priority"] as String),
      dueDate = timestampToString(this["dueDate"]),
      createdAt = timestampToString(this["createdAt"]) ?: "",
      updatedAt = timestampToString(this["updatedAt"]) ?: "",
      completedAt = timestampToString(this["completedAt"])
    )
  }

  private fun Map<String, Any>.toDomainTopic(): Topic {
    return Topic(
      id = this["id"] as String,
      title = this["title"] as String,
      description = this["description"] as? String,
      isActive = this["isActive"] as? Boolean ?: true,
      createdAt = timestampToString(this["createdAt"]) ?: "",
      updatedAt = timestampToString(this["updatedAt"]) ?: "",
      taskCount = 0,
      tasks = emptyList()
    )
  }

  private fun timestampToString(value: Any?): String? {
    return when (value) {
      is Timestamp -> value.toDate().toInstant().toString()
      is String -> value
      else -> null
    }
  }
}
