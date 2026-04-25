import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Campo de texto premium do Squad Fit Design System
///
/// Exemplo:
/// ```dart
/// SFInput(
///   label: 'Email',
///   icon: Icons.email_outlined,
///   placeholder: 'seu@email.com',
///   onChanged: (value) {},
/// )
/// ```
class SFInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final IconData? icon;
  final Widget? trailing;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final int? maxLines;
  final FocusNode? focusNode;

  const SFInput({
    super.key,
    this.label,
    this.placeholder,
    this.icon,
    this.trailing,
    this.error,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<SFInput> createState() => _SFInputState();
}

class _SFInputState extends State<SFInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : AppColors.borderDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input container - surfaceDark = #1A1C22 (mesmo que SF.surface no design)
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: widget.maxLines == 1 ? 54 : null,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.maxLines == 1 ? 0 : 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            // Focus ring como no design: 3px spread com cor laranja/erro
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (hasError ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.18),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading icon
              if (widget.icon != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Text field - completamente limpo, sem decoração interna
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  autofocus: widget.autofocus,
                  maxLines: widget.maxLines,
                  cursorColor: AppColors.primary,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiaryDark,
                    ),
                    // Remove TODAS as bordas e decorações do TextField
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    isCollapsed: true,
                  ),
                ),
              ),

              // Trailing widget
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),

        // Error message
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                widget.error!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
