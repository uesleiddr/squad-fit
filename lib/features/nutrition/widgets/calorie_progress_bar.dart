import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Widget que exibe a barra de progresso de calorias do dia
class CalorieProgressBar extends StatelessWidget {
  final int consumed;
  final int goal;

  const CalorieProgressBar({
    super.key,
    required this.consumed,
    required this.goal,
  });

  double get progress => goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
  int get remaining => goal - consumed;
  bool get isOverGoal => consumed > goal;

  Color _getProgressColor(BuildContext context) {
    if (isOverGoal) {
      return AppColors.error;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorias restantes (ou excedidas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isOverGoal
                    ? '${(consumed - goal).abs()}'
                    : '$remaining',
                style: AppTypography.statNumber(
                  context,
                  color: isOverGoal ? AppColors.error : null,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.local_fire_department,
                color: AppColors.primary,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOverGoal ? 'kcal excedidas' : 'kcal restantes',
            style: AppTypography.unit(context),
          ),
          SizedBox(height: AppSpacing.md),

          // Barra de progresso
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Meta e consumido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta: $goal kcal',
                style: AppTypography.bodySecondary(context),
              ),
              Text(
                'Consumido: $consumed kcal',
                style: AppTypography.bodySecondary(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
