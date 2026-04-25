import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Pill de estatística do Squad Fit
///
/// Exemplo:
/// ```dart
/// StatPill(
///   label: 'PROTEÍNA',
///   value: '120',
///   unit: 'g',
///   icon: Icons.egg_outlined,
///   accentColor: AppColors.protein,
/// )
/// ```
class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? accentColor;

  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: AppShadows.insetHighlight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label row
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Value row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
