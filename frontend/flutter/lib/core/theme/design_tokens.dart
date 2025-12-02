import 'package:flutter/material.dart';

/// TekTech Design Tokens
/// 
/// Centralized design system constants for:
/// - Spacing
/// - Border radius
/// - Elevation
/// - Shadows
/// - Duration & Curves
/// - Breakpoints

/// Spacing tokens (8px base)
class AppSpacing {
  AppSpacing._();

  // Base spacing unit
  static const double base = 8.0;

  // Spacing scale
  static const double xs = base * 0.5;      // 4px
  static const double sm = base;            // 8px
  static const double md = base * 2;        // 16px
  static const double lg = base * 3;        // 24px
  static const double xl = base * 4;        // 32px
  static const double xxl = base * 6;       // 48px
  static const double xxxl = base * 8;      // 64px

  // Semantic spacing
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double sectionSpacing = lg;
  static const double listItemSpacing = sm;
  static const double iconTextGap = sm;
  static const double bubblePadding = md;  // WhatsApp bubble padding
  
  // EdgeInsets shortcuts
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius tokens
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 9999;  // Circular

  // BorderRadius shortcuts
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));

  // Semantic radius
  static const BorderRadius card = borderRadiusMD;
  static const BorderRadius button = borderRadiusMD;  // Updated to 12 for modern look
  static const BorderRadius input = borderRadiusMD;  // Updated to 12
  static const BorderRadius dialog = borderRadiusLG;
  static const BorderRadius bubble = borderRadiusSM;  // WhatsApp message bubbles (8px)
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  // WhatsApp-specific bubble shapes
  static const BorderRadius bubbleOutgoing = BorderRadius.only(
    topLeft: Radius.circular(sm),
    topRight: Radius.circular(sm),
    bottomLeft: Radius.circular(sm),
    bottomRight: Radius.circular(xs),  // Small tail
  );

  static const BorderRadius bubbleIncoming = BorderRadius.only(
    topLeft: Radius.circular(sm),
    topRight: Radius.circular(sm),
    bottomLeft: Radius.circular(xs),  // Small tail
    bottomRight: Radius.circular(sm),
  );
}

/// Elevation tokens
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 16;
  static const double xxl = 24;

  // Semantic elevations
  static const double card = sm;
  static const double cardHover = md;
  static const double dialog = lg;
  static const double bottomSheet = xl;
  static const double appBar = none;  // Flat design
  static const double fab = lg;
}

/// Shadow tokens
class AppShadows {
  AppShadows._();

  // Light theme shadows
  static const BoxShadow shadowXS = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow shadowXL = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  // Dark theme shadows (subtle - 30% less than light theme for WhatsApp feel)
  static const BoxShadow shadowXSDark = BoxShadow(
    color: Color(0x07000000),  // Very subtle
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowSMDark = BoxShadow(
    color: Color(0x0A000000),  // Reduced opacity
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMDDark = BoxShadow(
    color: Color(0x0D000000),  // Subtle elevation
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLGDark = BoxShadow(
    color: Color(0x12000000),  // Moderate depth
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow shadowXLDark = BoxShadow(
    color: Color(0x16000000),  // Reduced for flat dark theme
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  // List shortcuts
  static const List<BoxShadow> cardShadow = [shadowSM];
  static const List<BoxShadow> cardHoverShadow = [shadowMD];
  static const List<BoxShadow> dialogShadow = [shadowLG];
  static const List<BoxShadow> bottomSheetShadow = [shadowXL];

  static const List<BoxShadow> cardShadowDark = [shadowSMDark];
  static const List<BoxShadow> cardHoverShadowDark = [shadowMDDark];
  static const List<BoxShadow> dialogShadowDark = [shadowLGDark];
  static const List<BoxShadow> bottomSheetShadowDark = [shadowXLDark];
}

/// Animation duration tokens
class AppDuration {
  AppDuration._();

  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
  static const Duration slowest = Duration(milliseconds: 1000);

  // Semantic durations
  static const Duration buttonTap = fast;
  static const Duration pageTransition = normal;
  static const Duration dialogOpen = normal;
  static const Duration bottomSheetOpen = Duration(milliseconds: 350);  // Slightly slower for sheet
  static const Duration snackbar = Duration(milliseconds: 3000);  // Reduced to 3s

  // WhatsApp-specific durations
  static const Duration bubblePop = Duration(milliseconds: 200);  // Bubble appearance
  static const Duration fadeIn = normal;
  static const Duration slideIn = Duration(milliseconds: 250);  // Tab/list transitions
}

/// Animation curve tokens
class AppCurves {
  AppCurves._();

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Semantic curves
  static const Curve defaultCurve = easeInOut;
  static const Curve pageTransition = fastOutSlowIn;
  static const Curve dialogOpen = easeOut;
  static const Curve bottomSheetOpen = easeOut;
}

/// Icon size tokens
class AppIconSize {
  AppIconSize._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;

  // Semantic sizes
  static const double button = sm;
  static const double listItem = md;
  static const double appBar = md;
  static const double avatar = xl;
  static const double logo = xxl;
}

/// Breakpoint tokens for responsive design
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 0;
  static const double mobileMax = 599;
  
  static const double tablet = 600;
  static const double tabletMax = 1199;
  
  static const double desktop = 1200;
  static const double desktopMax = double.infinity;

  /// Check if screen width is mobile
  static bool isMobile(double width) => width < tablet;

  /// Check if screen width is tablet
  static bool isTablet(double width) => width >= tablet && width < desktop;

  /// Check if screen width is desktop
  static bool isDesktop(double width) => width >= desktop;
}

/// Border width tokens
class AppBorderWidth {
  AppBorderWidth._();

  static const double none = 0;
  static const double thin = 1.0;
  static const double normal = 2.0;
  static const double thick = 3.0;
  static const double thicker = 4.0;

  // Semantic widths
  static const double input = thin;
  static const double card = none;
  static const double button = thin;
  static const double divider = thin;
}

/// Opacity tokens
class AppOpacity {
  AppOpacity._();

  static const double transparent = 0.0;
  static const double subtle = 0.05;
  static const double light = 0.1;
  static const double medium = 0.5;
  static const double strong = 0.8;
  static const double opaque = 1.0;

  // Semantic opacities
  static const double disabled = medium;
  static const double hover = light;
  static const double pressed = medium;
  static const double overlay = strong;
}

/// Line height tokens (relative to font size)
class AppLineHeight {
  AppLineHeight._();

  static const double tight = 1.2;
  static const double normal = 1.5;
  static const double relaxed = 1.75;
  static const double loose = 2.0;

  // Semantic line heights
  static const double heading = tight;
  static const double body = normal;
  static const double paragraph = relaxed;
}

/// Z-index tokens for layering
class AppZIndex {
  AppZIndex._();

  static const int base = 0;
  static const int elevated = 1;
  static const int dropdown = 10;
  static const int sticky = 100;
  static const int modal = 1000;
  static const int popover = 1100;
  static const int tooltip = 1200;
  static const int notification = 1300;
  static const int max = 9999;
}
