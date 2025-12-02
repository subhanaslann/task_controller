package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Inbox
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

@Composable
fun EmptyState(
  message: String,
  modifier: Modifier = Modifier
) {
  Column(
    modifier = modifier
      .fillMaxSize()
      .padding(32.dp),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.Center
  ) {
    Icon(
      imageVector = Icons.Default.Inbox,
      contentDescription = null,
      modifier = Modifier.size(64.dp),
      tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
    )
    Spacer(modifier = Modifier.height(16.dp))
    Text(
      text = message,
      style = MaterialTheme.typography.bodyLarge,
      color = MaterialTheme.colorScheme.onSurfaceVariant,
      textAlign = TextAlign.Center
    )
  }
}

@Composable
fun ErrorState(
  message: String,
  onRetry: () -> Unit,
  modifier: Modifier = Modifier
) {
  Column(
    modifier = modifier
      .fillMaxSize()
      .padding(32.dp),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.Center
  ) {
    Icon(
      imageVector = Icons.Default.Error,
      contentDescription = null,
      modifier = Modifier.size(64.dp),
      tint = MaterialTheme.colorScheme.error
    )
    Spacer(modifier = Modifier.height(16.dp))
    Text(
      text = message,
      style = MaterialTheme.typography.bodyLarge,
      color = MaterialTheme.colorScheme.error,
      textAlign = TextAlign.Center
    )
    Spacer(modifier = Modifier.height(16.dp))
    Button(onClick = onRetry) {
      Text("Tekrar Dene")
    }
  }
}

@Composable
fun LoadingState(
  modifier: Modifier = Modifier
) {
  Box(
    modifier = modifier.fillMaxSize(),
    contentAlignment = Alignment.Center
  ) {
    CircularProgressIndicator()
  }
}

@Composable
fun LoadingPlaceholder(
  modifier: Modifier = Modifier
) {
  Card(
    modifier = modifier
      .fillMaxWidth()
      .padding(horizontal = 16.dp, vertical = 8.dp)
  ) {
    Column(
      modifier = Modifier.padding(16.dp)
    ) {
      Box(
        modifier = Modifier
          .fillMaxWidth(0.7f)
          .height(24.dp)
          .shimmerEffect()
      )
      Spacer(modifier = Modifier.height(8.dp))
      Box(
        modifier = Modifier
          .fillMaxWidth(0.9f)
          .height(16.dp)
          .shimmerEffect()
      )
      Spacer(modifier = Modifier.height(12.dp))
      Row {
        Box(
          modifier = Modifier
            .width(80.dp)
            .height(24.dp)
            .shimmerEffect()
        )
        Spacer(modifier = Modifier.width(8.dp))
        Box(
          modifier = Modifier
            .width(80.dp)
            .height(24.dp)
            .shimmerEffect()
        )
      }
    }
  }
}

@Composable
private fun Modifier.shimmerEffect(): Modifier {
  return this.then(
    Modifier
      .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
  )
}
