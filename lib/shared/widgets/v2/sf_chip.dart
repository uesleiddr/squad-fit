import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Chip premium do Squad Fit
///
/// Exemplo:
/// ```dart
/// SFChip(
///   label: 'ATIVO',
///   icon: Icons.local_fire_department,
///   color: AppColors.primary,
/// )
/// ```
class SFChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? glow;
  final VoidCallback? onTap;

  const SFChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.glow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textSecondaryDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: glow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: textColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip com gradiente de fundo
class SFChipGradient extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Gradient gradient;
  final Color textColor;
  final List<BoxShadow>? glow;

  const SFChipGradient({
    super.key,
    required this.label,
    this.icon,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFA8038), Color(0xFFE06820)],
    ),
    this.textColor = Colors.white,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: glow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: textColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
