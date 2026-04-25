import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_button.dart';
import 'sf_card.dart';

/// Estado vazio premium do Squad Fit Design System
///
/// Exemplo de uso:
/// ```dart
/// SFEmptyState(
///   icon: Icons.emoji_events_outlined,
///   title: 'Nenhum desafio ativo',
///   description: 'Crie um novo desafio para competir com seus amigos.',
///   actionLabel: 'Criar Desafio',
///   onAction: () {},
/// )
/// ```
class SFEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;
  final bool useCard;

  const SFEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with glow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        // Description
        if (description != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],

        // Action button
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          SFButton(
            variant: SFButtonVariant.primary,
            onPressed: onAction!,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (useCard) {
      return SFCard(
        padding: const EdgeInsets.all(32),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: content,
    );
  }
}
