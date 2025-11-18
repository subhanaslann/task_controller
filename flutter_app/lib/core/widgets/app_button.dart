import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum ButtonVariant { primary, secondary, tertiary, destructive, ghost }

enum ButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final ButtonSize size;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = _getButtonStyle();
    final double buttonHeight = _getButtonHeight();
    final Widget child = widget.isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : _buildContent();

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height ?? buttonHeight,
          child: _buildButton(style, child),
        ),
      ),
    );
  }

  Widget _buildButton(ButtonStyle style, Widget child) {
    // Use different button types based on variant
    if (widget.variant == ButtonVariant.tertiary) {
      return widget.icon != null && !widget.isLoading
          ? OutlinedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon, size: _getIconSize()),
              label: Text(widget.text),
              style: style,
            )
          : OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: style,
              child: child,
            );
    } else if (widget.variant == ButtonVariant.ghost) {
      return widget.icon != null && !widget.isLoading
          ? TextButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon, size: _getIconSize()),
              label: Text(widget.text),
              style: style,
            )
          : TextButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: style,
              child: child,
            );
    } else {
      return widget.icon != null && !widget.isLoading
          ? ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon, size: _getIconSize()),
              label: Text(widget.text),
              style: style,
            )
          : ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: style,
              child: child,
            );
    }
  }

  Widget _buildContent() {
    return Text(
      widget.text,
      style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.w600),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 48.0; // Min touch target 48dp (WCAG AA)
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 18.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  ButtonStyle _getButtonStyle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.38),
          disabledForegroundColor: colorScheme.onPrimary.withValues(
            alpha: 0.38,
          ),
          padding: _getButtonPadding(),
          elevation: 0, // WhatsApp flat design
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          disabledBackgroundColor: colorScheme.secondary.withValues(
            alpha: 0.38,
          ),
          disabledForegroundColor: colorScheme.onSecondary.withValues(
            alpha: 0.38,
          ),
          padding: _getButtonPadding(),
          elevation: 0, // WhatsApp flat design
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        );
      case ButtonVariant.tertiary:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          side: BorderSide(
            color: widget.onPressed != null && !widget.isLoading
                ? colorScheme.outline
                : colorScheme.outline.withValues(alpha: 0.38),
            width: 1.0,
          ),
          padding: _getButtonPadding(),
          elevation: 0, // WhatsApp flat design
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        );
      case ButtonVariant.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          disabledBackgroundColor: colorScheme.error.withValues(alpha: 0.38),
          disabledForegroundColor: colorScheme.onError.withValues(alpha: 0.38),
          padding: _getButtonPadding(),
          elevation: 0, // WhatsApp flat design
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        );
      case ButtonVariant.ghost:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          padding: _getButtonPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        );
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
}
