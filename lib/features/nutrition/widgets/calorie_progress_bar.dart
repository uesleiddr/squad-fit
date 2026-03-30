import 'package:flutter/material.dart';

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
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorias restantes (ou excedidas)
          Text(
            isOverGoal
                ? '${(consumed - goal).abs()}'
                : '$remaining',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOverGoal ? colorScheme.error : colorScheme.primary,
            ),
          ),
          Text(
            isOverGoal ? 'kcal excedidas' : 'kcal restantes',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Meta e consumido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta: $goal kcal',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Consumido: $consumed kcal',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
