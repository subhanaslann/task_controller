package com.example.minitasktracker.features.tasks.ui.completed

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.minitasktracker.core.ui.components.*

@Composable
fun CompletedTasksScreen(
  viewModel: CompletedViewModel = hiltViewModel()
) {
  val uiState by viewModel.uiState.collectAsState()

  LaunchedEffect(Unit) {
    viewModel.loadTasks()
  }

  Box(
    modifier = Modifier.fillMaxSize()
  ) {
    when (val state = uiState) {
      is CompletedUiState.Loading -> {
        LazyColumn {
          items(3) {
            LoadingPlaceholder()
          }
        }
      }
      is CompletedUiState.Success -> {
        if (state.tasks.isEmpty()) {
          Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
          ) {
            NoCompletedTasksEmptyState()
          }
        } else {
          LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(vertical = 8.dp)
          ) {
            items(
              items = state.tasks,
              key = { it.id }
            ) { task ->
              TaskCard(
                task = task,
                onStatusChange = null, // Read-only
                showNote = true
              )
            }
          }
        }
      }
      is CompletedUiState.Error -> {
        ErrorState(
          message = state.message,
          onRetry = { viewModel.loadTasks() }
        )
      }
    }
  }
}
