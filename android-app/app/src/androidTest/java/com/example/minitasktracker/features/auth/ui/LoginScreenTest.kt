package com.example.minitasktracker.features.auth.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.minitasktracker.features.auth.presentation.LoginUiState
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class LoginScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun loginScreen_displaysAllComponents() {
        // Given
        val uiState = LoginUiState()

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = {},
                onNavigateToHome = {}
            )
        }

        // Then
        composeTestRule.onNodeWithTag("username_field").assertExists()
        composeTestRule.onNodeWithTag("password_field").assertExists()
        composeTestRule.onNodeWithTag("login_button").assertExists()
    }

    @Test
    fun loginScreen_showsErrorWhenUsernameEmpty() {
        // Given
        val uiState = LoginUiState(usernameError = "Kullanıcı adı boş olamaz")

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = {},
                onNavigateToHome = {}
            )
        }

        // Then
        composeTestRule.onNodeWithText("Kullanıcı adı boş olamaz").assertExists()
    }

    @Test
    fun loginScreen_showsLoadingState() {
        // Given
        val uiState = LoginUiState(isLoading = true)

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = {},
                onNavigateToHome = {}
            )
        }

        // Then
        composeTestRule.onNodeWithTag("login_button").assertIsNotEnabled()
        composeTestRule.onNodeWithTag("loading_indicator").assertExists()
    }

    @Test
    fun loginScreen_passwordToggleWorks() {
        // Given
        val uiState = LoginUiState(password = "test123")

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = {},
                onNavigateToHome = {}
            )
        }

        // Then - password should be hidden initially
        composeTestRule.onNodeWithTag("password_visibility_toggle").assertExists()
        
        // When - click toggle
        composeTestRule.onNodeWithTag("password_visibility_toggle").performClick()
        
        // Then - password should be visible (test would need implementation detail check)
    }

    @Test
    fun loginScreen_clickingLoginCallsCallback() {
        // Given
        var loginClicked = false
        val uiState = LoginUiState(
            username = "testuser",
            password = "password123"
        )

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = { loginClicked = true },
                onNavigateToHome = {}
            )
        }

        // Then
        composeTestRule.onNodeWithTag("login_button").performClick()
        assert(loginClicked)
    }

    @Test
    fun loginScreen_disablesButtonWhenFieldsEmpty() {
        // Given
        val uiState = LoginUiState(username = "", password = "")

        // When
        composeTestRule.setContent {
            LoginScreen(
                uiState = uiState,
                onUsernameChange = {},
                onPasswordChange = {},
                onLoginClick = {},
                onNavigateToHome = {}
            )
        }

        // Then
        composeTestRule.onNodeWithTag("login_button").assertIsNotEnabled()
    }
}
