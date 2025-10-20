package com.example.minitasktracker.features.tasks.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import com.example.minitasktracker.BuildConfig
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.minitasktracker.R
import com.example.minitasktracker.features.admin.ui.AdminScreen
import com.example.minitasktracker.features.tasks.ui.completed.CompletedTasksScreen
import com.example.minitasktracker.features.tasks.ui.myactive.MyActiveTasksScreen
import com.example.minitasktracker.features.tasks.ui.teamactive.TeamActiveTasksScreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
  onLogout: () -> Unit,
  viewModel: HomeViewModel = hiltViewModel()
) {
  var selectedTab by remember { mutableIntStateOf(0) }
  var showAdminScreen by remember { mutableStateOf(false) }
  var showComponentCatalog by remember { mutableStateOf(false) }
  var showMenu by remember { mutableStateOf(false) }
  
  val userSession by viewModel.sessionManager.userSession.collectAsState(initial = null)
  val userRole = userSession?.userRole
  val showAboutDialog by viewModel.showAboutDialog.collectAsState()

  Scaffold(
    topBar = {
      TopAppBar(
        title = { Text("TekTech") },
        actions = {
          IconButton(onClick = { showMenu = !showMenu }) {
            Icon(Icons.Default.MoreVert, contentDescription = "Menu")
          }
          DropdownMenu(
            expanded = showMenu,
            onDismissRequest = { showMenu = false }
          ) {
            if (userRole == "ADMIN") {
              DropdownMenuItem(
                text = { Text(stringResource(R.string.nav_admin)) },
                onClick = {
                  showAdminScreen = true
                  showMenu = false
                },
                leadingIcon = { Icon(Icons.Default.Settings, null) }
              )
            }
            DropdownMenuItem(
              text = { Text(stringResource(R.string.nav_logout)) },
              onClick = {
                showMenu = false
                viewModel.logout()
                onLogout()
              },
              leadingIcon = { Icon(Icons.Default.ExitToApp, null) }
            )
            if (com.example.minitasktracker.BuildConfig.DEBUG) {
              DropdownMenuItem(
                text = { Text("Hakkında") },
                onClick = {
                  showMenu = false
                  viewModel.showAboutDialog()
                },
                leadingIcon = { Icon(Icons.Default.Info, null) }
              )
              DropdownMenuItem(
                text = { Text("Component Catalog") },
                onClick = {
                  showMenu = false
                  showComponentCatalog = true
                },
                leadingIcon = { Icon(Icons.Default.Settings, null) }
              )
            }
          }
        }
      )
    },
    bottomBar = {
      if (!showAdminScreen && !showComponentCatalog) {
        NavigationBar {
          NavigationBarItem(
            icon = { Icon(Icons.Default.CheckCircle, contentDescription = null) },
            label = { Text(stringResource(R.string.nav_my_active)) },
            selected = selectedTab == 0,
            onClick = { selectedTab = 0 }
          )
          NavigationBarItem(
            icon = { Icon(Icons.Default.List, contentDescription = null) },
            label = { Text(stringResource(R.string.nav_team_active)) },
            selected = selectedTab == 1,
            onClick = { selectedTab = 1 }
          )
          NavigationBarItem(
            icon = { Icon(Icons.Default.Done, contentDescription = null) },
            label = { Text(stringResource(R.string.nav_completed)) },
            selected = selectedTab == 2,
            onClick = { selectedTab = 2 }
          )
        }
      }
    }
  ) { paddingValues ->
    Box(modifier = Modifier.padding(paddingValues)) {
      if (showAdminScreen) {
        AdminScreen(onBack = { showAdminScreen = false })
      } else if (showComponentCatalog) {
        com.example.minitasktracker.features.catalog.ComponentCatalogScreen(
          onNavigateBack = { showComponentCatalog = false }
        )
      } else {
        when (selectedTab) {
          0 -> MyActiveTasksScreen()
          1 -> TeamActiveTasksScreen()
          2 -> CompletedTasksScreen()
        }
      }
    }

    // About Dialog (Debug only)
    if (showAboutDialog && BuildConfig.DEBUG) {
      AlertDialog(
        onDismissRequest = { viewModel.dismissAboutDialog() },
        title = { Text("TekTech") },
        text = {
          Column {
            Text("Version: ${BuildConfig.VERSION_NAME}")
            Text("Build Type: ${BuildConfig.BUILD_TYPE}")
            Text("Base URL: ${BuildConfig.BASE_URL}")
          }
        },
        confirmButton = {
          TextButton(onClick = { viewModel.dismissAboutDialog() }) {
            Text("Tamam")
          }
        }
      )
    }
  }
}
