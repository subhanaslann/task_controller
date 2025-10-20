package com.example.minitasktracker.core.navigation

sealed class Screen(val route: String) {
  data object Login : Screen("login")
  data object Home : Screen("home")
  data object MyActive : Screen("my_active")
  data object TeamActive : Screen("team_active")
  data object Completed : Screen("completed")
  data object Admin : Screen("admin")
  data object ComponentCatalog : Screen("component_catalog")
}
