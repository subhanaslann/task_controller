package com.example.minitasktracker.features.auth.ui

import app.cash.turbine.test
import com.example.minitasktracker.data.AppException
import com.example.minitasktracker.data.Result
import com.example.minitasktracker.data.local.UserSession
import com.example.minitasktracker.data.repo.AuthRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class LoginViewModelTest {

  private val testDispatcher = StandardTestDispatcher()
  private lateinit var authRepository: AuthRepository
  private lateinit var viewModel: LoginViewModel

  @Before
  fun setup() {
    Dispatchers.setMain(testDispatcher)
    authRepository = mockk()
    viewModel = LoginViewModel(authRepository)
  }

  @After
  fun tearDown() {
    Dispatchers.resetMain()
  }

  @Test
  fun `login with empty username shows error`() = runTest {
    viewModel.uiState.test {
      val initialState = awaitItem()
      assertFalse(initialState.isLoading)

      viewModel.login("", "password")
      testDispatcher.scheduler.advanceUntilIdle()

      val errorState = awaitItem()
      assertEquals("Kullanıcı adı veya e-posta gerekli", errorState.error)
      assertFalse(errorState.isSuccess)
    }
  }

  @Test
  fun `login with empty password shows error`() = runTest {
    viewModel.uiState.test {
      awaitItem() // initial state

      viewModel.login("username", "")
      testDispatcher.scheduler.advanceUntilIdle()

      val errorState = awaitItem()
      assertEquals("Şifre gerekli", errorState.error)
      assertFalse(errorState.isSuccess)
    }
  }

  @Test
  fun `login with valid credentials succeeds`() = runTest {
    val mockSession = UserSession("token", "user-id", "Test User", "MEMBER")
    coEvery { authRepository.login("admin", "admin123") } returns Result.Success(mockSession)

    viewModel.uiState.test {
      awaitItem() // initial state

      viewModel.login("admin", "admin123")
      
      val loadingState = awaitItem()
      assertTrue(loadingState.isLoading)
      
      testDispatcher.scheduler.advanceUntilIdle()
      
      val successState = awaitItem()
      assertTrue(successState.isSuccess)
      assertNull(successState.error)
    }
  }

  @Test
  fun `login with invalid credentials shows error`() = runTest {
    coEvery { 
      authRepository.login("wrong", "wrong") 
    } returns Result.Error(AppException.UnauthorizedError("Invalid credentials"))

    viewModel.uiState.test {
      awaitItem() // initial state

      viewModel.login("wrong", "wrong")
      awaitItem() // loading state
      testDispatcher.scheduler.advanceUntilIdle()

      val errorState = awaitItem()
      assertEquals("Geçersiz bilgiler", errorState.error)
      assertFalse(errorState.isSuccess)
    }
  }

  @Test
  fun `login with network error shows error`() = runTest {
    coEvery { 
      authRepository.login(any(), any()) 
    } returns Result.Error(AppException.NetworkError("Network error"))

    viewModel.uiState.test {
      awaitItem() // initial state

      viewModel.login("user", "pass")
      awaitItem() // loading
      testDispatcher.scheduler.advanceUntilIdle()

      val errorState = awaitItem()
      assertEquals("Sunucuya bağlanılamadı", errorState.error)
    }
  }

  @Test
  fun `clearError resets error state`() = runTest {
    viewModel.uiState.test {
      awaitItem() // initial

      viewModel.login("", "pass")
      testDispatcher.scheduler.advanceUntilIdle()
      awaitItem() // error state

      viewModel.clearError()
      testDispatcher.scheduler.advanceUntilIdle()

      val clearedState = awaitItem()
      assertNull(clearedState.error)
    }
  }
}
