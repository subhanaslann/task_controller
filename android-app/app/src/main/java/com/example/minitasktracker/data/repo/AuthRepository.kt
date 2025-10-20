package com.example.minitasktracker.data.repo

import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.data.local.UserSession
import com.example.minitasktracker.data.remote.api.AuthApi
import com.example.minitasktracker.data.remote.dto.ErrorResponse
import com.example.minitasktracker.data.remote.dto.LoginRequest
import kotlinx.coroutines.flow.Flow
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
  private val authApi: AuthApi,
  private val sessionManager: SessionManager,
  private val json: Json
) {

  val userSession: Flow<UserSession?> = sessionManager.userSession

  suspend fun login(usernameOrEmail: String, password: String): Result<UserSession> {
    return try {
      val response = authApi.login(LoginRequest(usernameOrEmail, password))
      
      val session = UserSession(
        token = response.token,
        userId = response.user.id,
        userName = response.user.username,
        userRole = response.user.role,
        visibleTopicIds = response.user.visibleTopicIds
      )

      sessionManager.saveSession(
        token = response.token,
        userId = response.user.id,
        userName = response.user.username,
        userRole = response.user.role,
        visibleTopicIds = response.user.visibleTopicIds
      )

      Timber.d("Login successful: ${response.user.username} (${response.user.role})")
      Result.Success(session)

    } catch (e: HttpException) {
      Timber.e(e, "Login HTTP error: ${e.code()}")
      val errorResult = parseHttpError(e)
      Result.Error(errorResult)
      
    } catch (e: IOException) {
      Timber.e(e, "Login network error")
      Result.Error(AppException.NetworkError("Network error. Please check your connection."))
      
    } catch (e: Exception) {
      Timber.e(e, "Login unknown error")
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun logout(): Result<Unit> {
    return try {
      sessionManager.clearSession()
      Timber.d("Logout successful")
      Result.Success(Unit)
    } catch (e: Exception) {
      Timber.e(e, "Logout error")
      Result.Error(AppException.UnknownError(e.message ?: "Failed to logout"))
    }
  }

  private fun parseHttpError(exception: HttpException): AppException {
    return try {
      val errorBody = exception.response()?.errorBody()?.string()
      if (errorBody != null) {
        val errorResponse = json.decodeFromString<ErrorResponse>(errorBody)
        when (exception.code()) {
          401 -> AppException.UnauthorizedError(errorResponse.error.message)
          400 -> AppException.ValidationError(errorResponse.error.message)
          else -> AppException.ServerError(errorResponse.error.code, errorResponse.error.message)
        }
      } else {
        AppException.ServerError("HTTP_${exception.code()}", "Server error: ${exception.message()}")
      }
    } catch (e: Exception) {
      AppException.ServerError("PARSE_ERROR", "Failed to parse error: ${exception.message()}")
    }
  }
}
