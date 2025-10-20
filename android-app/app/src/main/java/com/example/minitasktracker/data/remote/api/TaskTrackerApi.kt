package com.example.minitasktracker.data.remote.api

import com.example.minitasktracker.data.remote.dto.*
import retrofit2.http.*

interface TaskApi {

  // View tasks
  @GET("tasks/view")
  suspend fun getTasks(@Query("scope") scope: String): TasksResponse

  @PATCH("tasks/{id}/status")
  suspend fun updateTaskStatus(
    @Path("id") taskId: String,
    @Body request: UpdateTaskStatusRequest
  ): TaskDto

  // Topics
  @GET("topics/active")
  suspend fun getActiveTopics(): TopicsResponse

  // Member task CRUD
  @POST("tasks")
  suspend fun createMemberTask(@Body request: CreateMemberTaskRequest): TaskResponse

  @PATCH("tasks/{id}")
  suspend fun updateMemberTask(
    @Path("id") taskId: String,
    @Body request: UpdateTaskRequest
  ): TaskResponse

  @DELETE("tasks/{id}")
  suspend fun deleteMemberTask(@Path("id") taskId: String): DeleteResponse
}
