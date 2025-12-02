package com.example.minitasktracker.data.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "session_prefs")

data class UserSession(
  val token: String,
  val userId: String,
  val userName: String,
  val userRole: String,
  val visibleTopicIds: List<String> = emptyList()
)

@Singleton
class SessionManager @Inject constructor(
  @ApplicationContext private val context: Context
) {

  private val dataStore = context.dataStore

  companion object {
    private val AUTH_TOKEN = stringPreferencesKey("auth_token")
    private val USER_ID = stringPreferencesKey("user_id")
    private val USER_NAME = stringPreferencesKey("user_name")
    private val USER_ROLE = stringPreferencesKey("user_role")
    private val VISIBLE_TOPIC_IDS = stringPreferencesKey("visible_topic_ids")
  }

  val userSession: Flow<UserSession?> = dataStore.data.map { prefs ->
    val token = prefs[AUTH_TOKEN]
    val userId = prefs[USER_ID]
    val userName = prefs[USER_NAME]
    val userRole = prefs[USER_ROLE]
    val visibleTopicIdsStr = prefs[VISIBLE_TOPIC_IDS] ?: ""
    val visibleTopicIds = if (visibleTopicIdsStr.isNotEmpty()) {
      visibleTopicIdsStr.split(",")
    } else {
      emptyList()
    }

    if (token != null && userId != null && userName != null && userRole != null) {
      UserSession(token, userId, userName, userRole, visibleTopicIds)
    } else {
      null
    }
  }

  val authToken: Flow<String?> = dataStore.data.map { it[AUTH_TOKEN] }

  suspend fun saveSession(
    token: String,
    userId: String,
    userName: String,
    userRole: String,
    visibleTopicIds: List<String> = emptyList()
  ) {
    dataStore.edit { prefs ->
      prefs[AUTH_TOKEN] = token
      prefs[USER_ID] = userId
      prefs[USER_NAME] = userName
      prefs[USER_ROLE] = userRole
      prefs[VISIBLE_TOPIC_IDS] = visibleTopicIds.joinToString(",")
    }
  }

  suspend fun clearSession() {
    dataStore.edit { it.clear() }
  }

  suspend fun getToken(): String? {
    return dataStore.data.map { it[AUTH_TOKEN] }.first()
  }

  suspend fun getCurrentSession(): UserSession? {
    return userSession.first()
  }
}
