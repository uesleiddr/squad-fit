import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Tipos de badges/conquistas disponíveis
enum SFBadgeRarity {
  common,    // Cinza
  uncommon,  // Verde
  rare,      // Azul
  epic,      // Roxo
  legendary, // Dourado
}

/// Badge/Conquista do Squad Fit Design System
///
/// Exemplo de uso:
/// ```dart
/// SFBadge(
///   icon: Icons.emoji_events,
///   title: 'Primeiro Peso',
///   description: 'Registrou seu primeiro peso',
///   rarity: SFBadgeRarity.common,
///   isUnlocked: true,
/// )
/// ```
class SFBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final SFBadgeRarity rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final VoidCallback? onTap;

  const SFBadge({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.rarity = SFBadgeRarity.common,
    this.isUnlocked = false,
    this.unlockedAt,
    this.onTap,
  });

  Color get _color {
    if (!isUnlocked) return AppColors.textTertiaryDark;

    switch (rarity) {
      case SFBadgeRarity.common:
        return const Color(0xFF9CA3AF);
      case SFBadgeRarity.uncommon:
        return AppColors.lime;
      case SFBadgeRarity.rare:
        return AppColors.secondary;
      case SFBadgeRarity.epic:
        return AppColors.magenta;
      case SFBadgeRarity.legendary:
        return const Color(0xFFFFD166);
    }
  }

  Gradient? get _gradient {
    if (!isUnlocked) return null;

    switch (rarity) {
      case SFBadgeRarity.common:
        return null;
      case SFBadgeRarity.uncommon:
        return LinearGradient(
          colors: [AppColors.lime, AppColors.lime.withValues(alpha: 0.7)],
        );
      case SFBadgeRarity.rare:
        return AppGradients.squad;
      case SFBadgeRarity.epic:
        return AppGradients.hype;
      case SFBadgeRarity.legendary:
        return const LinearGradient(
          colors: [Color(0xFFFFD166), Color(0xFFF59E0B)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? _color.withValues(alpha: 0.3)
                : AppColors.borderDark,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: _gradient,
                color: _gradient == null
                    ? (isUnlocked ? _color.withValues(alpha: 0.15) : AppColors.surface2)
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isUnlocked && rarity != SFBadgeRarity.common
                    ? [
                        BoxShadow(
                          color: _color.withValues(alpha: 0.3),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isUnlocked
                    ? (_gradient != null ? Colors.white : _color)
                    : AppColors.textTertiaryDark.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.white : AppColors.textTertiaryDark,
              ),
            ),

            // Locked indicator
            if (!isUnlocked) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.lock,
                size: 12,
                color: AppColors.textTertiaryDark.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid de badges
class SFBadgeGrid extends StatelessWidget {
  final List<SFBadge> badges;
  final int crossAxisCount;
  final double spacing;

  const SFBadgeGrid({
    super.key,
    required this.badges,
    this.crossAxisCount = 3,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => badges[index],
    );
  }
}

/// Card de progresso de badges
class SFBadgeProgress extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;

  const SFBadgeProgress({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conquistas',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$unlockedCount/$totalCount',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.lime),
            ),
          ),
        ],
      ),
    );
  }
}
