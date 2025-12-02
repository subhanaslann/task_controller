package com.example.minitasktracker.core.ui.theme

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * TekTech Design Tokens
 * 
 * Design system constants following 8dp grid system
 * Based on Material 3 guidelines with custom values
 */

object Spacing {
  // 8dp grid spacing scale
  val spacing4: Dp = 4.dp
  val spacing8: Dp = 8.dp
  val spacing12: Dp = 12.dp
  val spacing16: Dp = 16.dp
  val spacing20: Dp = 20.dp
  val spacing24: Dp = 24.dp
  val spacing32: Dp = 32.dp
  val spacing40: Dp = 40.dp
  val spacing48: Dp = 48.dp
  val spacing56: Dp = 56.dp
  val spacing64: Dp = 64.dp
  
  // Semantic spacing
  val spacingXs: Dp = spacing4
  val spacingSm: Dp = spacing8
  val spacingMd: Dp = spacing16
  val spacingLg: Dp = spacing24
  val spacingXl: Dp = spacing32
  
  // Component-specific
  val cardPadding: Dp = spacing20
  val screenPadding: Dp = spacing16
  val buttonPadding: Dp = spacing16
  val chipPadding: Dp = spacing12
}

object Radius {
  // Corner radius scale
  val radius4: Dp = 4.dp
  val radius8: Dp = 8.dp
  val radius12: Dp = 12.dp
  val radius16: Dp = 16.dp
  val radius20: Dp = 20.dp
  val radius24: Dp = 24.dp
  val radius28: Dp = 28.dp
  val radiusFull: Dp = 999.dp
  
  // Semantic radius
  val radiusXs: Dp = radius4
  val radiusSm: Dp = radius8
  val radiusMd: Dp = radius12
  val radiusLg: Dp = radius16
  val radiusXl: Dp = radius24
  
  // Component-specific
  val buttonRadius: Dp = radius12
  val cardRadius: Dp = radius16
  val chipRadius: Dp = radius8
  val dialogRadius: Dp = radius28
}

object Elevation {
  // Elevation scale
  val elevation0: Dp = 0.dp
  val elevation1: Dp = 1.dp
  val elevation2: Dp = 2.dp
  val elevation3: Dp = 3.dp
  val elevation4: Dp = 4.dp
  val elevation6: Dp = 6.dp
  val elevation8: Dp = 8.dp
  
  // Semantic elevation
  val elevationNone: Dp = elevation0
  val elevationLow: Dp = elevation1
  val elevationMedium: Dp = elevation2
  val elevationHigh: Dp = elevation4
}

object Sizes {
  // Minimum touch target (accessibility)
  val minTouchTarget: Dp = 48.dp
  
  // Icon sizes
  val iconXs: Dp = 16.dp
  val iconSm: Dp = 20.dp
  val iconMd: Dp = 24.dp
  val iconLg: Dp = 32.dp
  val iconXl: Dp = 48.dp
  
  // Button heights
  val buttonSmall: Dp = 40.dp
  val buttonMedium: Dp = 48.dp
  val buttonLarge: Dp = 56.dp
  
  // Avatar sizes
  val avatarSmall: Dp = 24.dp
  val avatarMedium: Dp = 32.dp
  val avatarLarge: Dp = 40.dp
  val avatarXl: Dp = 56.dp
}

object Duration {
  // Animation durations (milliseconds)
  const val instant = 0
  const val fast = 120
  const val normal = 180
  const val slow = 220
  const val verySlow = 300
  const val loading = 600
  
  // Semantic durations
  const val stateChange = fast
  const val enterExit = normal
  const val pageTransition = slow
  const val shimmer = loading
}

object BorderWidth {
  val thin: Dp = 1.dp
  val medium: Dp = 2.dp
  val thick: Dp = 3.dp
  
  // Component-specific
  val outlineWidth: Dp = thin
  val focusWidth: Dp = medium
}
