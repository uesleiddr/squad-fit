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
    final percentage = progress;
    if (percentage < 0.7) {
      return Theme.of(context).colorScheme.secondary; // Verde
    } else if (percentage < 0.9) {
      return Colors.orange;
    } else {
      return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorias restantes (ou excedidas)
          Text(
            isOverGoal
                ? '${(consumed - goal).abs()} kcal excedidas'
                : '$remaining kcal restantes',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOverGoal ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Meta e consumido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta: $goal',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Consumido: $consumed',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
