package com.example.minitasktracker.core.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

// TekTech Dark Theme - Professional Dark Mode
private val DarkColorScheme = darkColorScheme(
  primary = Indigo400,
  onPrimary = Indigo900,
  primaryContainer = Indigo800,
  onPrimaryContainer = Indigo100,
  
  secondary = Green400,
  onSecondary = Green900,
  secondaryContainer = Green800,
  onSecondaryContainer = Green100,
  
  tertiary = Cyan400,
  onTertiary = Cyan900,
  tertiaryContainer = Cyan800,
  onTertiaryContainer = Cyan100,
  
  error = Red400,
  onError = Red900,
  errorContainer = Red800,
  onErrorContainer = Red100,
  
  background = DarkBackground,
  onBackground = Gray100,
  surface = DarkSurface,
  onSurface = Gray100,
  surfaceVariant = DarkSurfaceVariant,
  onSurfaceVariant = Gray300,
  
  outline = DarkOutline,
  outlineVariant = Gray700,
  scrim = Black.copy(alpha = 0.32f)
)

// TekTech Light Theme - Clean & Modern
private val LightColorScheme = lightColorScheme(
  primary = Indigo600,
  onPrimary = White,
  primaryContainer = Indigo100,
  onPrimaryContainer = Indigo900,
  
  secondary = Green500,
  onSecondary = White,
  secondaryContainer = Green100,
  onSecondaryContainer = Green900,
  
  tertiary = Cyan600,
  onTertiary = White,
  tertiaryContainer = Cyan100,
  onTertiaryContainer = Cyan900,
  
  error = Red500,
  onError = White,
  errorContainer = Red100,
  onErrorContainer = Red900,
  
  background = White,
  onBackground = Gray900,
  surface = White,
  onSurface = Gray900,
  surfaceVariant = Gray50,
  onSurfaceVariant = Gray700,
  
  outline = Gray200,
  outlineVariant = Gray100,
  scrim = Black.copy(alpha = 0.32f)
)

@Composable
fun MiniTaskTrackerTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  dynamicColor: Boolean = false, // Disabled for consistent branding
  content: @Composable () -> Unit
) {
  val colorScheme = when {
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
      val context = LocalContext.current
      if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    }
    darkTheme -> DarkColorScheme
    else -> LightColorScheme
  }

  MaterialTheme(
    colorScheme = colorScheme,
    typography = TekTechTypography,
    shapes = TekTechShapes,
    content = content
  )
}
