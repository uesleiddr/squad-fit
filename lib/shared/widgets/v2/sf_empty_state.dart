import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_button.dart';
import 'sf_card.dart';
import 'sf_empty_illustration.dart';

/// Estado vazio premium do Squad Fit Design System
///
/// Suporta dois modos:
/// 1. Simples com ícone (modo original)
/// 2. Premium com SFEmptyIllustration decorativa
///
/// Exemplo de uso simples:
/// ```dart
/// SFEmptyState(
///   icon: Icons.emoji_events_outlined,
///   title: 'Nenhum desafio ativo',
///   description: 'Crie um novo desafio para competir com seus amigos.',
///   actionLabel: 'Criar Desafio',
///   onAction: () {},
/// )
/// ```
///
/// Exemplo com ilustração:
/// ```dart
/// SFEmptyState(
///   illustration: SFEmptyIllustration(
///     icon: Icons.group_add,
///     glowColor: AppColors.magenta,
///   ),
///   kicker: 'SEM SQUAD',
///   title: 'Treino é melhor em squad',
///   description: 'Crie ou entre num squad...',
///   primaryAction: SFButton(...),
///   secondaryAction: SFButton(...),
/// )
/// ```
class SFEmptyState extends StatelessWidget {
  /// Ícone simples (usado quando illustration é null)
  final IconData? icon;

  /// Ilustração decorativa premium
  final Widget? illustration;

  /// Kicker - texto pequeno acima do título (ex: "SEM SQUAD")
  final String? kicker;

  /// Título principal
  final String title;

  /// Descrição opcional
  final String? description;

  /// Label do botão de ação (modo simples)
  final String? actionLabel;

  /// Callback do botão de ação (modo simples)
  final VoidCallback? onAction;

  /// Botão de ação primário (modo avançado)
  final Widget? primaryAction;

  /// Botão de ação secundário (modo avançado)
  final Widget? secondaryAction;

  /// Cor de destaque
  final Color? accentColor;

  /// Se deve usar SFCard como wrapper
  final bool useCard;

  /// Se deve ocupar toda a altura disponível
  final bool fullHeight;

  const SFEmptyState({
    super.key,
    this.icon,
    this.illustration,
    this.kicker,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.primaryAction,
    this.secondaryAction,
    this.accentColor,
    this.useCard = true,
    this.fullHeight = false,
  }) : assert(icon != null || illustration != null,
            'Either icon or illustration must be provided');

  /// Factory: Sem squad/desafio ativo
  factory SFEmptyState.noSquad({
    required VoidCallback onCreateSquad,
    required VoidCallback onJoinWithCode,
  }) {
    return SFEmptyState(
      illustration: SFEmptyIllustration(
        icon: Icons.group_add_rounded,
        glowColor: AppColors.magenta,
        accentColor: AppColors.magenta,
      ),
      kicker: 'SEM SQUAD',
      title: 'Treino é melhor em squad',
      description:
          'Crie ou entre num squad pra competir em desafios e se motivar com amigos.',
      primaryAction: SFButton(
        variant: SFButtonVariant.primary,
        size: SFButtonSize.lg,
        fullWidth: true,
        onPressed: onCreateSquad,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: 8),
            const Text('Criar squad'),
          ],
        ),
      ),
      secondaryAction: SFButton(
        variant: SFButtonVariant.outline,
        size: SFButtonSize.lg,
        fullWidth: true,
        onPressed: onJoinWithCode,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key, size: 18),
            const SizedBox(width: 8),
            const Text('Entrar com código'),
          ],
        ),
      ),
      useCard: false,
      fullHeight: true,
    );
  }

  /// Factory: Diário vazio (sem refeições registradas)
  factory SFEmptyState.emptyDiary({
    required VoidCallback onAddMeal,
  }) {
    return SFEmptyState(
      illustration: SFEmptyIllustration(
        icon: Icons.restaurant_menu_rounded,
        glowColor: AppColors.success,
        accentColor: AppColors.success,
      ),
      kicker: 'DIÁRIO DE HOJE',
      title: 'Nenhuma refeição registrada',
      description:
          'Adicione seu café da manhã pra acompanhar calorias e macros do dia.',
      primaryAction: SFButton(
        variant: SFButtonVariant.primary,
        size: SFButtonSize.lg,
        fullWidth: true,
        onPressed: onAddMeal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle, size: 20),
            const SizedBox(width: 8),
            const Text('Adicionar refeição'),
          ],
        ),
      ),
      useCard: false,
      fullHeight: true,
    );
  }

  /// Factory: Busca sem resultados
  factory SFEmptyState.noSearchResults({
    required String query,
    List<String>? suggestions,
    VoidCallback? onCreateCustom,
  }) {
    return SFEmptyState(
      illustration: SFEmptyIllustration(
        icon: Icons.search_off_rounded,
        glowColor: AppColors.textTertiaryDark,
        accentColor: AppColors.textSecondaryDark,
        size: 160,
      ),
      kicker: 'SEM RESULTADOS',
      title: 'Não achamos esse alimento',
      description:
          'Tenta um nome mais simples ou cadastra como alimento personalizado.',
      primaryAction: onCreateCustom != null
          ? SFButton(
              variant: SFButtonVariant.primary,
              onPressed: onCreateCustom,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle, size: 18),
                  const SizedBox(width: 8),
                  const Text('Criar alimento'),
                ],
              ),
            )
          : null,
      useCard: false,
      fullHeight: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Illustration ou Icon
        if (illustration != null)
          illustration!
        else if (icon != null)
          _buildSimpleIcon(color),

        // Kicker
        if (kicker != null) ...[
          const SizedBox(height: 20),
          Text(
            kicker!,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],

        // Title
        SizedBox(height: kicker != null ? 8 : 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: illustration != null ? 22 : 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),

        // Description
        if (description != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],

        // Actions
        if (primaryAction != null || secondaryAction != null) ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ?primaryAction,
                if (secondaryAction != null) ...[
                  const SizedBox(height: 8),
                  secondaryAction!,
                ],
              ],
            ),
          ),
        ] else if (actionLabel != null && onAction != null) ...[
          // Modo simples (compatibilidade)
          const SizedBox(height: 24),
          SFButton(
            variant: SFButtonVariant.primary,
            onPressed: onAction!,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    // Wrapper para full height
    if (fullHeight) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(child: content),
      );
    } else if (useCard) {
      return SFCard(
        padding: const EdgeInsets.all(32),
        child: content,
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(32),
        child: content,
      );
    }

    return content;
  }

  Widget _buildSimpleIcon(Color color) {
    return Container(
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
    );
  }
}
