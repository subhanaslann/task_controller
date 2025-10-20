package com.example.minitasktracker

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.minitasktracker.core.navigation.Screen
import com.example.minitasktracker.core.ui.theme.MiniTaskTrackerTheme
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.features.auth.ui.LoginScreen
import com.example.minitasktracker.features.tasks.ui.HomeScreen
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

  @Inject
  lateinit var sessionManager: SessionManager

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()

    setContent {
      val navController = rememberNavController()
      val userSession by sessionManager.userSession.collectAsState(initial = null)
      var hasNavigated by remember { mutableStateOf(false) }

      // Navigate once on initial session load
      LaunchedEffect(userSession) {
        if (!hasNavigated) {
          hasNavigated = true
          if (userSession != null) {
            // User already logged in, go to home
            navController.navigate(Screen.Home.route) {
              popUpTo(Screen.Login.route) { inclusive = true }
            }
          }
        }
      }

      MiniTaskTrackerTheme {
        Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
          NavHost(
            navController = navController,
            startDestination = Screen.Login.route,
            modifier = Modifier.padding(innerPadding)
          ) {
            composable(Screen.Login.route) {
              LoginScreen(
                onLoginSuccess = {
                  navController.navigate(Screen.Home.route) {
                    popUpTo(Screen.Login.route) { inclusive = true }
                  }
                }
              )
            }

            composable(Screen.Home.route) {
              HomeScreen(
                onLogout = {
                  navController.navigate(Screen.Login.route) {
                    popUpTo(Screen.Home.route) { inclusive = true }
                  }
                }
              )
            }
          }
        }
      }
    }
  }
}
