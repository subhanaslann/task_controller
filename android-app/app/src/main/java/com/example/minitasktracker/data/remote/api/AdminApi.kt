package com.example.minitasktracker.data.remote.api

import com.example.minitasktracker.data.remote.dto.*
import retrofit2.http.*

interface AdminApi {

  // User management
  @GET("users")
  suspend fun getUsers(): UsersResponse

  @GET("users/{id}")
  suspend fun getUser(@Path("id") userId: String): UserResponse

  @POST("users")
  suspend fun createUser(@Body request: CreateUserRequest): UserResponse

  @PATCH("users/{id}")
  suspend fun updateUser(
    @Path("id") userId: String,
    @Body request: UpdateUserRequest
  ): UserResponse

  // Task management
  @GET("admin/tasks")
  suspend fun getAllTasks(): TasksResponse

  @GET("admin/tasks/{id}")
  suspend fun getTask(@Path("id") taskId: String): TaskResponse

  @POST("admin/tasks")
  suspend fun createTask(@Body request: CreateTaskRequest): TaskResponse

  @PATCH("admin/tasks/{id}")
  suspend fun updateTask(
    @Path("id") taskId: String,
    @Body request: UpdateTaskRequest
  ): TaskResponse

  @DELETE("admin/tasks/{id}")
  suspend fun deleteTask(@Path("id") taskId: String): DeleteResponse

  // Topic management
  @GET("admin/topics")
  suspend fun getTopics(): TopicsResponse

  @GET("admin/topics/{id}")
  suspend fun getTopic(@Path("id") topicId: String): TopicResponse

  @POST("admin/topics")
  suspend fun createTopic(@Body request: CreateTopicRequest): TopicResponse

  @PATCH("admin/topics/{id}")
  suspend fun updateTopic(
    @Path("id") topicId: String,
    @Body request: UpdateTopicRequest
  ): TopicResponse

  @DELETE("admin/topics/{id}")
  suspend fun deleteTopic(@Path("id") topicId: String): DeleteResponse

  // User delete
  @DELETE("users/{id}")
  suspend fun deleteUser(@Path("id") userId: String): DeleteResponse
}
