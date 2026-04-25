import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Variantes de botão do Squad Fit
enum SFButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  victory,
  dark,
}

/// Tamanhos de botão
enum SFButtonSize {
  sm,
  md,
  lg,
}

/// Botão premium do Squad Fit Design System
///
/// Exemplo:
/// ```dart
/// SFButton(
///   variant: SFButtonVariant.primary,
///   onPressed: () {},
///   child: Text('Entrar'),
/// )
/// ```
class SFButton extends StatefulWidget {
  final SFButtonVariant variant;
  final SFButtonSize size;
  final Widget? child;
  final IconData? icon;
  final IconData? iconRight;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool glow;
  final bool isLoading;

  const SFButton({
    super.key,
    this.variant = SFButtonVariant.primary,
    this.size = SFButtonSize.md,
    this.child,
    this.icon,
    this.iconRight,
    this.onPressed,
    this.fullWidth = false,
    this.glow = true,
    this.isLoading = false,
  });

  @override
  State<SFButton> createState() => _SFButtonState();
}

class _SFButtonState extends State<SFButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  _SFButtonConfig get _config {
    return switch (widget.size) {
      SFButtonSize.sm => _SFButtonConfig(
          height: 36,
          paddingH: 14,
          fontSize: 13,
          radius: 10,
          iconSize: 18,
        ),
      SFButtonSize.md => _SFButtonConfig(
          height: 48,
          paddingH: 20,
          fontSize: 15,
          radius: 12,
          iconSize: 20,
        ),
      SFButtonSize.lg => _SFButtonConfig(
          height: 56,
          paddingH: 24,
          fontSize: 16,
          radius: 14,
          iconSize: 22,
        ),
    };
  }

  _SFButtonStyle get _style {
    return switch (widget.variant) {
      SFButtonVariant.primary => _SFButtonStyle(
          gradient: AppGradients.primary,
          textColor: Colors.white,
          shadow: widget.glow ? AppShadows.glowOrange : null,
          border: null,
        ),
      SFButtonVariant.secondary => _SFButtonStyle(
          color: AppColors.surface2,
          textColor: AppColors.textPrimaryDark,
          shadow: null,
          border: Border.all(color: AppColors.borderDark),
        ),
      SFButtonVariant.outline => _SFButtonStyle(
          color: Colors.transparent,
          textColor: AppColors.primary,
          shadow: null,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
      SFButtonVariant.ghost => _SFButtonStyle(
          color: Colors.transparent,
          textColor: AppColors.textHighContrast,
          shadow: null,
          border: null,
        ),
      SFButtonVariant.destructive => _SFButtonStyle(
          color: AppColors.error.withValues(alpha: 0.12),
          textColor: AppColors.error,
          shadow: null,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
      SFButtonVariant.victory => _SFButtonStyle(
          gradient: AppGradients.victory,
          textColor: AppColors.deep,
          shadow: widget.glow ? AppShadows.glowLime : null,
          border: null,
        ),
      SFButtonVariant.dark => _SFButtonStyle(
          color: Colors.black,
          textColor: Colors.white,
          shadow: null,
          border: Border.all(color: AppColors.borderDark),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final style = _style;
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: config.height,
            constraints: widget.fullWidth
                ? const BoxConstraints(minWidth: double.infinity)
                : null,
            decoration: BoxDecoration(
              gradient: style.gradient,
              color: style.gradient == null ? style.color : null,
              borderRadius: BorderRadius.circular(config.radius),
              border: style.border,
              boxShadow: style.shadow,
            ),
            padding: EdgeInsets.symmetric(horizontal: config.paddingH),
            child: Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null && !widget.isLoading) ...[
                  Icon(
                    widget.icon,
                    size: config.iconSize,
                    color: style.textColor,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.isLoading)
                  SizedBox(
                    width: config.iconSize,
                    height: config.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: style.textColor,
                    ),
                  )
                else if (widget.child != null)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: config.fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.01,
                      color: style.textColor,
                    ),
                    child: widget.child!,
                  ),
                if (widget.iconRight != null && !widget.isLoading) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.iconRight,
                    size: config.iconSize,
                    color: style.textColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SFButtonConfig {
  final double height;
  final double paddingH;
  final double fontSize;
  final double radius;
  final double iconSize;

  const _SFButtonConfig({
    required this.height,
    required this.paddingH,
    required this.fontSize,
    required this.radius,
    required this.iconSize,
  });
}

class _SFButtonStyle {
  final Gradient? gradient;
  final Color? color;
  final Color textColor;
  final List<BoxShadow>? shadow;
  final Border? border;

  const _SFButtonStyle({
    this.gradient,
    this.color,
    required this.textColor,
    this.shadow,
    this.border,
  });
}
