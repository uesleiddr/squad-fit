import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Variantes de card
enum SFCardVariant {
  /// Card padrão com borda sutil
  surface,

  /// Card elevado (hover state)
  elevated,

  /// Card com destaque (highlight)
  highlight,

  /// Card com gradiente primário
  primary,

  /// Card transparente com borda
  outlined,
}

/// Card premium do Squad Fit Design System
///
/// Exemplo:
/// ```dart
/// SFCard(
///   child: Text('Conteúdo'),
///   onTap: () {},
/// )
/// ```
class SFCard extends StatefulWidget {
  final Widget child;
  final SFCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final bool showInsetHighlight;

  const SFCard({
    super.key,
    required this.child,
    this.variant = SFCardVariant.surface,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.borderColor,
    this.showInsetHighlight = true,
  });

  @override
  State<SFCard> createState() => _SFCardState();
}

class _SFCardState extends State<SFCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  _SFCardStyle get _style {
    return switch (widget.variant) {
      SFCardVariant.surface => _SFCardStyle(
          color: AppColors.surfaceDark,
          borderColor: widget.borderColor ?? AppColors.borderDark,
          shadow: AppShadows.smDark,
        ),
      SFCardVariant.elevated => _SFCardStyle(
          color: AppColors.surface2,
          borderColor: widget.borderColor ?? AppColors.borderDark,
          shadow: AppShadows.mdDark,
        ),
      SFCardVariant.highlight => _SFCardStyle(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.18),
              AppColors.surfaceDark,
            ],
          ),
          borderColor:
              widget.borderColor ?? AppColors.primary.withValues(alpha: 0.45),
          shadow: [
            // Glow sutil externo (0 0 0 1px rgba(250,128,56,.25))
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
      SFCardVariant.primary => _SFCardStyle(
          gradient: widget.gradient ?? AppGradients.primary,
          borderColor: null,
          shadow: AppShadows.glowOrange,
        ),
      SFCardVariant.outlined => _SFCardStyle(
          color: Colors.transparent,
          borderColor: widget.borderColor ?? AppColors.borderDark,
          shadow: null,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final radius = widget.borderRadius ?? AppRadius.lg;

    Widget card = Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.gradient == null ? style.color : null,
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(radius),
        border: style.borderColor != null
            ? Border.all(color: style.borderColor!)
            : null,
        boxShadow: widget.showInsetHighlight && style.shadow != null
            ? [...style.shadow!, ...AppShadows.insetHighlight]
            : style.shadow,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: card,
        ),
      );
    }

    return card;
  }
}

class _SFCardStyle {
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  const _SFCardStyle({
    this.color,
    this.gradient,
    this.borderColor,
    this.shadow,
  });
}
