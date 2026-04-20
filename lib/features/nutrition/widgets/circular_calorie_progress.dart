import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/theme/design_system.dart';

/// Widget circular que exibe o progresso de calorias do dia
/// Inspirado no design Sandow
class CircularCalorieProgress extends StatelessWidget {
  final int consumed;
  final int goal;
  final VoidCallback? onEditGoal;

  const CircularCalorieProgress({
    super.key,
    required this.consumed,
    required this.goal,
    this.onEditGoal,
  });

  int get remaining => goal - consumed;
  bool get isOverGoal => consumed > goal;
  double get progress => goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

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
        children: [
          // Slider circular
          SleekCircularSlider(
            min: 0,
            max: goal.toDouble(),
            initialValue: consumed.toDouble().clamp(0, goal.toDouble()),
            appearance: CircularSliderAppearance(
              size: 200,
              startAngle: 135,
              angleRange: 270,
              customWidths: CustomSliderWidths(
                trackWidth: 12,
                progressBarWidth: 12,
                handlerSize: 0, // Sem handle (apenas visualização)
              ),
              customColors: CustomSliderColors(
                trackColor: colorScheme.outline.withValues(alpha: 0.2),
                progressBarColors: isOverGoal
                    ? [AppColors.error, AppColors.errorDark]
                    : [AppColors.primary, AppColors.primaryDark],
                hideShadow: true,
              ),
              infoProperties: InfoProperties(
                mainLabelStyle: AppTypography.statNumber(context),
                topLabelStyle: AppTypography.caption(context),
                bottomLabelStyle: AppTypography.unit(context),
                topLabelText: '',
                bottomLabelText: isOverGoal ? 'kcal excedidas' : 'kcal restantes',
                modifier: (value) {
                  if (isOverGoal) {
                    return '${(consumed - goal).abs()}';
                  }
                  return '$remaining';
                },
              ),
            ),
            innerWidget: (percentage) => _buildInnerWidget(context),
          ),

          SizedBox(height: AppSpacing.md),

          // Meta e consumido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoColumn(
                context,
                label: 'Meta',
                value: '$goal',
                unit: 'kcal',
                onTap: onEditGoal,
              ),
              Container(
                height: 40,
                width: 1,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildInfoColumn(
                context,
                label: 'Restante',
                value: '${remaining.abs()}',
                unit: 'kcal',
                highlight: isOverGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInnerWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calorias consumidas (número principal)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$consumed',
                style: AppTypography.statNumber(
                  context,
                  color: isOverGoal ? AppColors.error : null,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.local_fire_department,
                color: isOverGoal ? AppColors.error : AppColors.primary,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'kcal consumidas',
            style: AppTypography.unit(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    bool highlight = false,
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption(context),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                size: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.statNumberSmall(
                context,
                color: highlight ? AppColors.error : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppTypography.caption(context),
            ),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: content,
        ),
      );
    }

    return content;
  }
}
