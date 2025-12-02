package com.example.minitasktracker.features.auth.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.minitasktracker.R
import com.example.minitasktracker.core.ui.components.AppButton
import com.example.minitasktracker.core.ui.components.AppTextField
import com.example.minitasktracker.core.ui.components.ButtonSize
import com.example.minitasktracker.core.ui.components.ButtonVariant

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
  onLoginSuccess: () -> Unit,
  viewModel: LoginViewModel = hiltViewModel()
) {
  var username by remember { mutableStateOf("") }
  var password by remember { mutableStateOf("") }
  var visible by remember { mutableStateOf(false) }
  
  val uiState by viewModel.uiState.collectAsState()
  val focusManager = LocalFocusManager.current

  // Animate on launch
  LaunchedEffect(Unit) {
    visible = true
  }

  // Navigate on success
  LaunchedEffect(uiState.isSuccess) {
    if (uiState.isSuccess) {
      onLoginSuccess()
    }
  }

  Box(
    modifier = Modifier
      .fillMaxSize()
      .background(
        Brush.verticalGradient(
          colors = listOf(
            MaterialTheme.colorScheme.surface,
            MaterialTheme.colorScheme.surfaceVariant
          )
        )
      )
  ) {
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(horizontal = 32.dp),
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center
    ) {
      AnimatedVisibility(
        visible = visible,
        enter = fadeIn(animationSpec = tween(600)) + 
                slideInVertically(initialOffsetY = { -50 })
      ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
          // App Logo/Brand
          Text(
            text = stringResource(R.string.login_welcome),
            style = MaterialTheme.typography.displaySmall.copy(
              fontWeight = FontWeight.Bold,
              letterSpacing = 2.sp
            ),
            color = MaterialTheme.colorScheme.primary
          )
          
          Spacer(modifier = Modifier.height(8.dp))
          
          Text(
            text = stringResource(R.string.login_subtitle),
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
          )
        }
      }

      Spacer(modifier = Modifier.height(64.dp))

      // Login Form Card
      AnimatedVisibility(
        visible = visible,
        enter = fadeIn(animationSpec = tween(600, delayMillis = 200)) + 
                slideInVertically(initialOffsetY = { 50 })
      ) {
        Card(
          modifier = Modifier.fillMaxWidth(),
          shape = RoundedCornerShape(24.dp),
          colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
          ),
          elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
        ) {
          Column(
            modifier = Modifier
              .fillMaxWidth()
              .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
          ) {
            // Username field
            AppTextField(
              value = username,
              onValueChange = { username = it },
              label = stringResource(R.string.login_username_hint),
              leadingIcon = Icons.Default.Person,
              enabled = !uiState.isLoading,
              keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Text,
                imeAction = ImeAction.Next
              ),
              keyboardActions = KeyboardActions(
                onNext = { focusManager.moveFocus(FocusDirection.Down) }
              )
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Password field
            AppTextField(
              value = password,
              onValueChange = { password = it },
              label = stringResource(R.string.login_password_hint),
              leadingIcon = Icons.Default.Lock,
              isPassword = true,
              enabled = !uiState.isLoading,
              keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done
              ),
              keyboardActions = KeyboardActions(
                onDone = {
                  focusManager.clearFocus()
                  if (username.isNotBlank() && password.isNotBlank()) {
                    viewModel.login(username, password)
                  }
                }
              )
            )

            Spacer(modifier = Modifier.height(32.dp))

            // Login button
            AppButton(
              text = stringResource(R.string.login_button),
              onClick = {
                focusManager.clearFocus()
                viewModel.login(username, password)
              },
              enabled = username.isNotBlank() && password.isNotBlank(),
              loading = uiState.isLoading,
              fullWidth = true,
              size = ButtonSize.LARGE,
              variant = ButtonVariant.PRIMARY
            )
          }
        }
      }

      // Error message
      if (uiState.error != null) {
        Spacer(modifier = Modifier.height(16.dp))
        Card(
          modifier = Modifier.fillMaxWidth(),
          colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
          ),
          shape = RoundedCornerShape(12.dp)
        ) {
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
          ) {
            Text(
              text = uiState.error ?: "",
              style = MaterialTheme.typography.bodyMedium,
              color = MaterialTheme.colorScheme.onErrorContainer,
              modifier = Modifier.weight(1f)
            )
            TextButton(onClick = { viewModel.clearError() }) {
              Text(
                stringResource(R.string.ok),
                color = MaterialTheme.colorScheme.onErrorContainer
              )
            }
          }
        }
      }
    }
  }
}
