package com.example.minitasktracker.data.repo

import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.data.local.UserSession
import com.example.minitasktracker.data.remote.FirebaseService
import com.google.firebase.functions.FirebaseFunctionsException
import kotlinx.coroutines.flow.Flow
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
  private val firebaseService: FirebaseService,
  private val sessionManager: SessionManager
) {

  val userSession: Flow<UserSession?> = sessionManager.userSession

  suspend fun login(usernameOrEmail: String, password: String): Result<UserSession> {
    return try {
      val response = firebaseService.login(usernameOrEmail, password)

      @Suppress("UNCHECKED_CAST")
      val user = response["user"] as Map<String, Any>

      val session = UserSession(
        token = "", // Firebase handles tokens internally
        userId = user["id"] as String,
        userName = user["username"] as String,
        userRole = user["role"] as String,
        visibleTopicIds = (user["visibleTopicIds"] as? List<*>)?.filterIsInstance<String>() ?: emptyList()
      )

      sessionManager.saveSession(
        token = "",
        userId = session.userId,
        userName = session.userName,
        userRole = session.userRole,
        visibleTopicIds = session.visibleTopicIds
      )

      Timber.d("Login successful: ${session.userName} (${session.userRole})")
      Result.Success(session)

    } catch (e: FirebaseFunctionsException) {
      Timber.e(e, "Login Firebase error: ${e.code}")
      val exception = when (e.code) {
        FirebaseFunctionsException.Code.UNAUTHENTICATED ->
          AppException.UnauthorizedError(e.message ?: "Invalid credentials")
        FirebaseFunctionsException.Code.INVALID_ARGUMENT ->
          AppException.ValidationError(e.message ?: "Invalid input")
        else ->
          AppException.ServerError(e.code.name, e.message ?: "Server error")
      }
      Result.Error(exception)

    } catch (e: Exception) {
      Timber.e(e, "Login unknown error")
      Result.Error(AppException.UnknownError(e.message ?: "Unknown error occurred"))
    }
  }

  suspend fun logout(): Result<Unit> {
    return try {
      firebaseService.logout()
      sessionManager.clearSession()
      Timber.d("Logout successful")
      Result.Success(Unit)
    } catch (e: Exception) {
      Timber.e(e, "Logout error")
      Result.Error(AppException.UnknownError(e.message ?: "Failed to logout"))
    }
  }

  fun isLoggedIn(): Boolean {
    return firebaseService.currentUser != null
  }
}
