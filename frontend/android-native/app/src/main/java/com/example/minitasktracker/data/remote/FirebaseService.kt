package com.example.minitasktracker.data.remote

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.functions.FirebaseFunctions
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FirebaseService @Inject constructor() {
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
    private val functions: FirebaseFunctions = FirebaseFunctions.getInstance()

    val currentUser get() = auth.currentUser
    val currentUserId get() = auth.currentUser?.uid

    suspend fun getOrganizationId(): String? {
        val user = auth.currentUser ?: return null
        val tokenResult = user.getIdToken(false).await()
        return tokenResult.claims["organizationId"] as? String
    }

    // ===================
    // Auth Functions
    // ===================

    suspend fun login(usernameOrEmail: String, password: String): Map<String, Any> {
        val result = functions.getHttpsCallable("loginUser")
            .call(mapOf(
                "usernameOrEmail" to usernameOrEmail,
                "password" to password
            ))
            .await()

        @Suppress("UNCHECKED_CAST")
        val data = result.data as Map<String, Any>
        val customToken = data["customToken"] as String
        auth.signInWithCustomToken(customToken).await()

        return data
    }

    suspend fun registerTeam(
        companyName: String,
        teamName: String,
        managerName: String,
        username: String,
        email: String,
        password: String
    ): Map<String, Any> {
        val result = functions.getHttpsCallable("registerTeam")
            .call(mapOf(
                "companyName" to companyName,
                "teamName" to teamName,
                "managerName" to managerName,
                "username" to username,
                "email" to email,
                "password" to password
            ))
            .await()

        @Suppress("UNCHECKED_CAST")
        val data = result.data as Map<String, Any>
        val customToken = data["customToken"] as String
        auth.signInWithCustomToken(customToken).await()

        return data
    }

    fun logout() {
        auth.signOut()
    }

    // ===================
    // Task Functions
    // ===================

    suspend fun getMyActiveTasks(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()
        val userId = currentUserId ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("tasks")
            .whereEqualTo("assigneeId", userId)
            .whereIn("status", listOf("TODO", "IN_PROGRESS"))
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun getTeamActiveTasks(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("tasks")
            .whereIn("status", listOf("TODO", "IN_PROGRESS"))
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun getMyCompletedTasks(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()
        val userId = currentUserId ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("tasks")
            .whereEqualTo("assigneeId", userId)
            .whereEqualTo("status", "DONE")
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun createMemberTask(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("createMemberTask")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun updateMemberTask(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("updateMemberTask")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun updateTaskStatus(taskId: String, status: String): Map<String, Any> {
        val result = functions.getHttpsCallable("updateTaskStatus")
            .call(mapOf(
                "taskId" to taskId,
                "status" to status
            ))
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun deleteMemberTask(taskId: String) {
        functions.getHttpsCallable("deleteMemberTask")
            .call(mapOf("taskId" to taskId))
            .await()
    }

    // ===================
    // Topic Functions
    // ===================

    suspend fun getActiveTopics(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("topics")
            .whereEqualTo("isActive", true)
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun getAllTopics(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("topics")
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun createTopic(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("createTopic")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun updateTopic(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("updateTopic")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun deleteTopic(topicId: String) {
        functions.getHttpsCallable("deleteTopic")
            .call(mapOf("topicId" to topicId))
            .await()
    }

    // ===================
    // User Functions
    // ===================

    suspend fun getUsers(): List<Map<String, Any>> {
        val orgId = getOrganizationId() ?: return emptyList()

        val snapshot = firestore
            .collection("organizations").document(orgId)
            .collection("users")
            .get()
            .await()

        return snapshot.documents.map { doc ->
            mapOf("id" to doc.id) + (doc.data ?: emptyMap())
        }
    }

    suspend fun createUser(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("createUser")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun updateUser(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("updateUser")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun deleteUser(userId: String) {
        functions.getHttpsCallable("deleteUser")
            .call(mapOf("userId" to userId))
            .await()
    }

    // ===================
    // Organization Functions
    // ===================

    suspend fun getOrganization(): Map<String, Any>? {
        val orgId = getOrganizationId() ?: return null

        val doc = firestore
            .collection("organizations").document(orgId)
            .get()
            .await()

        if (!doc.exists()) return null
        return mapOf("id" to doc.id) + (doc.data ?: emptyMap())
    }

    suspend fun updateOrganization(data: Map<String, Any>): Map<String, Any> {
        val result = functions.getHttpsCallable("updateOrganization")
            .call(data)
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }

    suspend fun getOrganizationStats(): Map<String, Any> {
        val result = functions.getHttpsCallable("getOrganizationStats")
            .call(emptyMap<String, Any>())
            .await()
        @Suppress("UNCHECKED_CAST")
        return result.data as Map<String, Any>
    }
}
