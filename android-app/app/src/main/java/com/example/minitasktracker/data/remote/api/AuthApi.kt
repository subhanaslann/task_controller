package com.example.minitasktracker.data.remote.api

import com.example.minitasktracker.data.remote.dto.LoginRequest
import com.example.minitasktracker.data.remote.dto.AuthResponse
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthApi {
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse
}

