import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool isRequired;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool expands;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.helperText,
    this.errorText,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.expands = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          minLines: widget.minLines,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          expands: widget.expands,
          decoration: InputDecoration(
            // Floating label with required indicator
            label: widget.label != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.label!),
                      if (widget.isRequired)
                        Text(' *', style: TextStyle(color: colorScheme.error)),
                    ],
                  )
                : null,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            // Leading icon with error color
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  )
                : null,
            // Trailing icon (password toggle or custom icon or error icon)
            suffixIcon: hasError
                ? Icon(Icons.error, color: colorScheme.error)
                : widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? colorScheme.surfaceContainer
                : colorScheme.surfaceContainer.withValues(alpha: 0.5),
            // WhatsApp-style borders
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// TekTech AppTextArea Component
///
/// Multi-line text field for notes, descriptions, etc.
/// - Based on AppTextField with multiline support
/// - Min/max lines control
/// - Same validation and styling as AppTextField
class AppTextArea extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? helperText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isRequired;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const AppTextArea({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.validator,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 5,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      helperText: helperText,
      validator: validator,
      onChanged: onChanged,
      isRequired: isRequired,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
    );
  }
}
