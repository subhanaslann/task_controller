package com.example.minitasktracker.features.tasks.ui.myactive

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
import com.example.minitasktracker.domain.model.TaskStatus

@Composable
fun MyActiveTasksScreen(
  viewModel: MyActiveViewModel = hiltViewModel()
) {
  val uiState by viewModel.uiState.collectAsState()

  LaunchedEffect(Unit) {
    viewModel.loadTasks()
  }

  Box(
    modifier = Modifier.fillMaxSize()
  ) {
    when (val state = uiState) {
      is MyActiveUiState.Loading -> {
        LazyColumn {
          items(3) {
            LoadingPlaceholder()
          }
        }
      }
      is MyActiveUiState.Success -> {
        if (state.tasks.isEmpty()) {
          Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
          ) {
            EmptyState(
              title = "Aktif görev yok",
              message = "Şu anda üzerinde çalıştığınız bir görev bulunmuyor"
            )
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
                onStatusChange = { newStatus ->
                  viewModel.updateTaskStatus(task.id, newStatus)
                },
                showNote = true
              )
            }
          }
        }
      }
      is MyActiveUiState.Error -> {
        ErrorState(
          message = state.message,
          onRetry = { viewModel.loadTasks() }
        )
      }
    }
  }
}
