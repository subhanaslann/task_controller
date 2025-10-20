package com.example.minitasktracker.core.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.theme.*

/**
 * TekTech AppButton Component
 * 
 * Unified button component with 5 variants and all states
 * - Primary: Main actions (Indigo 600)
 * - Secondary: Secondary actions (Green 500)
 * - Tertiary: Less prominent actions (outlined)
 * - Destructive: Dangerous actions (Red 500)
 * - Ghost: Minimal actions (text only)
 * 
 * States: Default, Pressed, Disabled, Loading
 * Accessibility: 48dp minimum touch target, semantic labels
 * 
 * @param text Button label
 * @param onClick Click handler
 * @param modifier Modifier
 * @param variant Button style variant
 * @param size Button size (small, medium, large)
 * @param enabled Whether button is enabled
 * @param loading Whether button shows loading spinner
 * @param icon Optional leading icon
 * @param fullWidth Whether button fills max width
 */

enum class ButtonVariant {
  PRIMARY,
  SECONDARY,
  TERTIARY,
  DESTRUCTIVE,
  GHOST
}

enum class ButtonSize {
  SMALL,
  MEDIUM,
  LARGE
}

@Composable
fun AppButton(
  text: String,
  onClick: () -> Unit,
  modifier: Modifier = Modifier,
  variant: ButtonVariant = ButtonVariant.PRIMARY,
  size: ButtonSize = ButtonSize.MEDIUM,
  enabled: Boolean = true,
  loading: Boolean = false,
  icon: @Composable (() -> Unit)? = null,
  fullWidth: Boolean = false,
  contentDescription: String? = null
) {
  val interactionSource = remember { MutableInteractionSource() }
  val isPressed by interactionSource.collectIsPressedAsState()
  
  // Press animation
  val scale by animateFloatAsState(
    targetValue = if (isPressed && enabled) 0.97f else 1f,
    label = "button_press_scale"
  )
  
  // Colors based on variant
  val buttonColors = when (variant) {
    ButtonVariant.PRIMARY -> ButtonDefaults.buttonColors(
      containerColor = MaterialTheme.colorScheme.primary,
      contentColor = MaterialTheme.colorScheme.onPrimary,
      disabledContainerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.38f),
      disabledContentColor = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.38f)
    )
    ButtonVariant.SECONDARY -> ButtonDefaults.buttonColors(
      containerColor = MaterialTheme.colorScheme.secondary,
      contentColor = MaterialTheme.colorScheme.onSecondary,
      disabledContainerColor = MaterialTheme.colorScheme.secondary.copy(alpha = 0.38f),
      disabledContentColor = MaterialTheme.colorScheme.onSecondary.copy(alpha = 0.38f)
    )
    ButtonVariant.TERTIARY -> ButtonDefaults.outlinedButtonColors(
      containerColor = Color.Transparent,
      contentColor = MaterialTheme.colorScheme.primary,
      disabledContainerColor = Color.Transparent,
      disabledContentColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
    )
    ButtonVariant.DESTRUCTIVE -> ButtonDefaults.buttonColors(
      containerColor = MaterialTheme.colorScheme.error,
      contentColor = MaterialTheme.colorScheme.onError,
      disabledContainerColor = MaterialTheme.colorScheme.error.copy(alpha = 0.38f),
      disabledContentColor = MaterialTheme.colorScheme.onError.copy(alpha = 0.38f)
    )
    ButtonVariant.GHOST -> ButtonDefaults.textButtonColors(
      containerColor = Color.Transparent,
      contentColor = MaterialTheme.colorScheme.primary,
      disabledContainerColor = Color.Transparent,
      disabledContentColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
    )
  }
  
  // Border for tertiary variant
  val border = if (variant == ButtonVariant.TERTIARY) {
    BorderStroke(
      width = BorderWidth.thin,
      color = if (enabled) MaterialTheme.colorScheme.outline else MaterialTheme.colorScheme.outline.copy(alpha = 0.38f)
    )
  } else null
  
  // Height based on size
  val height = when (size) {
    ButtonSize.SMALL -> Sizes.buttonSmall
    ButtonSize.MEDIUM -> Sizes.buttonMedium
    ButtonSize.LARGE -> Sizes.buttonLarge
  }
  
  // Typography based on size
  val textStyle = when (size) {
    ButtonSize.SMALL -> MaterialTheme.typography.labelMedium
    ButtonSize.MEDIUM -> MaterialTheme.typography.labelLarge
    ButtonSize.LARGE -> MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold)
  }
  
  val buttonModifier = modifier
    .then(if (fullWidth) Modifier.fillMaxWidth() else Modifier)
    .height(height)
    .graphicsLayer {
      scaleX = scale
      scaleY = scale
    }
    .semantics {
      role = Role.Button
      contentDescription?.let { this.contentDescription = it }
    }
  
  // Render appropriate button type based on variant
  when (variant) {
    ButtonVariant.TERTIARY -> {
      OutlinedButton(
        onClick = onClick,
        modifier = buttonModifier,
        enabled = enabled && !loading,
        colors = buttonColors,
        border = border,
        interactionSource = interactionSource,
        contentPadding = PaddingValues(horizontal = Spacing.buttonPadding),
        shape = MaterialTheme.shapes.medium
      ) {
        ButtonContent(
          text = text,
          loading = loading,
          icon = icon,
          textStyle = textStyle
        )
      }
    }
    ButtonVariant.GHOST -> {
      TextButton(
        onClick = onClick,
        modifier = buttonModifier,
        enabled = enabled && !loading,
        colors = buttonColors,
        interactionSource = interactionSource,
        contentPadding = PaddingValues(horizontal = Spacing.buttonPadding),
        shape = MaterialTheme.shapes.medium
      ) {
        ButtonContent(
          text = text,
          loading = loading,
          icon = icon,
          textStyle = textStyle
        )
      }
    }
    else -> {
      Button(
        onClick = onClick,
        modifier = buttonModifier,
        enabled = enabled && !loading,
        colors = buttonColors,
        interactionSource = interactionSource,
        contentPadding = PaddingValues(horizontal = Spacing.buttonPadding),
        shape = MaterialTheme.shapes.medium,
        elevation = ButtonDefaults.buttonElevation(
          defaultElevation = Elevation.elevationNone,
          pressedElevation = Elevation.elevationNone
        )
      ) {
        ButtonContent(
          text = text,
          loading = loading,
          icon = icon,
          textStyle = textStyle
        )
      }
    }
  }
}

@Composable
private fun ButtonContent(
  text: String,
  loading: Boolean,
  icon: @Composable (() -> Unit)?,
  textStyle: androidx.compose.ui.text.TextStyle
) {
  if (loading) {
    CircularProgressIndicator(
      modifier = Modifier.size(Sizes.iconSm),
      strokeWidth = 2.dp
    )
  } else {
    Row(
      horizontalArrangement = Arrangement.Center,
      verticalAlignment = Alignment.CenterVertically,
      modifier = Modifier.defaultMinSize(minHeight = Sizes.minTouchTarget)
    ) {
      icon?.let {
        Box(modifier = Modifier.size(Sizes.iconSm)) {
          it()
        }
        Spacer(modifier = Modifier.width(Spacing.spacing8))
      }
      Text(
        text = text,
        style = textStyle
      )
    }
  }
}
