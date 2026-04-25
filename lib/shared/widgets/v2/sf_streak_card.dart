import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_card.dart';

/// Card de streak (sequência de dias) do Squad Fit Design System
///
/// Exemplo de uso:
/// ```dart
/// SFStreakCard(
///   currentStreak: 7,
///   longestStreak: 14,
///   weekDays: [true, true, true, true, true, false, false],
/// )
/// ```
class SFStreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<bool> weekDays; // 7 dias, começando em Seg

  const SFStreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    final isOnFire = currentStreak >= 3;

    return SFCard(
      variant: SFCardVariant.elevated,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          // Glow effect for active streak
          if (isOnFire)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Fire icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isOnFire ? AppGradients.streak : null,
                      color: isOnFire ? null : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isOnFire ? AppShadows.glowOrange : null,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      size: 24,
                      color: isOnFire ? Colors.white : AppColors.textTertiaryDark,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Streak count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$currentStreak',
                              style: TextStyle(
                                fontFamily: AppTypography.fontDisplay,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: isOnFire ? AppColors.primary : Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentStreak == 1 ? 'dia' : 'dias',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isOnFire
                              ? 'Você está em chamas!'
                              : 'Continue registrando!',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Longest streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'RECORDE',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                        Text(
                          '$longestStreak',
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Week days
              _buildWeekDays(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final dayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = weekDays.length > index && weekDays[index];
        final isToday = index == DateTime.now().weekday - 1;

        return Column(
          children: [
            Text(
              dayLabels[index],
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isActive ? AppGradients.streak : null,
                color: isActive ? null : AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isActive
                    ? Border.all(color: AppColors.primary, width: 2)
                    : isActive
                        ? null
                        : Border.all(color: AppColors.borderDark),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                isActive ? Icons.check : Icons.remove,
                size: 18,
                color: isActive ? Colors.white : AppColors.textTertiaryDark,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Mini versão do streak para exibição em headers
class SFStreakBadge extends StatelessWidget {
  final int streak;

  const SFStreakBadge({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final isOnFire = streak >= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: isOnFire ? AppGradients.streak : null,
        color: isOnFire ? null : AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: isOnFire ? null : Border.all(color: AppColors.borderDark),
        boxShadow: isOnFire ? AppShadows.glowOrange : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: isOnFire ? Colors.white : AppColors.textTertiaryDark,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isOnFire ? Colors.white : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
