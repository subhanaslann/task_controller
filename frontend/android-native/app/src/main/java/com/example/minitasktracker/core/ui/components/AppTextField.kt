package com.example.minitasktracker.core.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.Radius
import com.example.minitasktracker.core.ui.theme.Spacing

/**
 * TekTech AppTextField Component
 * 
 * Modern text input field with:
 * - Label (floating)
 * - Helper text
 * - Error state with icon + message
 * - Required/optional indicator
 * - Leading/trailing icons
 * - Password visibility toggle
 * - Validation support
 * 
 * Accessibility: WCAG AA compliant, semantic labels
 * 
 * @param value Current text value
 * @param onValueChange Value change callback
 * @param label Field label
 * @param modifier Modifier
 * @param placeholder Optional placeholder text
 * @param helperText Optional helper text (shown below field)
 * @param errorText Optional error message (overrides helper)
 * @param isRequired Show required indicator (*)
 * @param enabled Whether field is enabled
 * @param readOnly Whether field is read-only
 * @param singleLine Single line input
 * @param maxLines Maximum lines for multiline
 * @param leadingIcon Optional leading icon
 * @param trailingIcon Optional trailing icon
 * @param isPassword Password field (shows visibility toggle)
 * @param keyboardOptions Keyboard options
 * @param keyboardActions Keyboard actions
 */
@Composable
fun AppTextField(
  value: String,
  onValueChange: (String) -> Unit,
  label: String,
  modifier: Modifier = Modifier,
  placeholder: String? = null,
  helperText: String? = null,
  errorText: String? = null,
  isRequired: Boolean = false,
  enabled: Boolean = true,
  readOnly: Boolean = false,
  singleLine: Boolean = true,
  maxLines: Int = 1,
  leadingIcon: ImageVector? = null,
  trailingIcon: ImageVector? = null,
  isPassword: Boolean = false,
  keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
  keyboardActions: KeyboardActions = KeyboardActions.Default
) {
  var passwordVisible by remember { mutableStateOf(false) }
  val isError = errorText != null
  
  Column(modifier = modifier) {
    OutlinedTextField(
      value = value,
      onValueChange = onValueChange,
      label = {
        Row {
          Text(label)
          if (isRequired) {
            Text(
              text = " *",
              color = MaterialTheme.colorScheme.error
            )
          }
        }
      },
      placeholder = placeholder?.let { { Text(it) } },
      leadingIcon = leadingIcon?.let {
        {
          Icon(
            imageVector = it,
            contentDescription = null,
            tint = if (isError) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurfaceVariant
          )
        }
      },
      trailingIcon = {
        when {
          isError -> {
            Icon(
              imageVector = Icons.Default.Error,
              contentDescription = "Error",
              tint = MaterialTheme.colorScheme.error
            )
          }
          isPassword -> {
            IconButton(onClick = { passwordVisible = !passwordVisible }) {
              Icon(
                imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                contentDescription = if (passwordVisible) "Hide password" else "Show password"
              )
            }
          }
          trailingIcon != null -> {
            Icon(
              imageVector = trailingIcon,
              contentDescription = null
            )
          }
        }
      },
      visualTransformation = if (isPassword && !passwordVisible) {
        PasswordVisualTransformation()
      } else {
        VisualTransformation.None
      },
      isError = isError,
      enabled = enabled,
      readOnly = readOnly,
      singleLine = singleLine,
      maxLines = maxLines,
      keyboardOptions = keyboardOptions,
      keyboardActions = keyboardActions,
      shape = MaterialTheme.shapes.medium,
      colors = OutlinedTextFieldDefaults.colors(
        focusedBorderColor = MaterialTheme.colorScheme.primary,
        unfocusedBorderColor = MaterialTheme.colorScheme.outline,
        errorBorderColor = MaterialTheme.colorScheme.error,
        disabledBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.38f)
      ),
      modifier = Modifier.fillMaxWidth()
    )
    
    // Helper or error text
    if (errorText != null || helperText != null) {
      Spacer(modifier = Modifier.height(Spacing.spacing4))
      Text(
        text = errorText ?: helperText ?: "",
        style = MaterialTheme.typography.bodySmall,
        color = if (isError) {
          MaterialTheme.colorScheme.error
        } else {
          MaterialTheme.colorScheme.onSurfaceVariant
        },
        modifier = Modifier.padding(start = Spacing.spacing16)
      )
    }
  }
}

/**
 * AppTextField variant for multiline text (notes, descriptions)
 */
@Composable
fun AppTextArea(
  value: String,
  onValueChange: (String) -> Unit,
  label: String,
  modifier: Modifier = Modifier,
  placeholder: String? = null,
  helperText: String? = null,
  errorText: String? = null,
  isRequired: Boolean = false,
  enabled: Boolean = true,
  minLines: Int = 3,
  maxLines: Int = 5,
  keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
  keyboardActions: KeyboardActions = KeyboardActions.Default
) {
  AppTextField(
    value = value,
    onValueChange = onValueChange,
    label = label,
    placeholder = placeholder,
    helperText = helperText,
    errorText = errorText,
    isRequired = isRequired,
    enabled = enabled,
    singleLine = false,
    maxLines = maxLines,
    keyboardOptions = keyboardOptions,
    keyboardActions = keyboardActions,
    modifier = modifier.defaultMinSize(minHeight = (minLines * 24).dp)
  )
}
