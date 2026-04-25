import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/ranking_entry_model.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/widgets/v2/v2.dart';

class RankingListV2 extends StatefulWidget {
  final CompetitionModel? competition;

  const RankingListV2({super.key, this.competition});

  @override
  State<RankingListV2> createState() => _RankingListV2State();
}

class _RankingListV2State extends State<RankingListV2> {
  final _competitionService = getIt<CompetitionService>();

  @override
  Widget build(BuildContext context) {
    if (widget.competition == null) {
      return _buildEmptyState('Sem competição ativa');
    }

    final hasEnded = widget.competition!.hasEnded;

    return StreamBuilder<List<RankingEntryModel>>(
      stream: _competitionService.getCompetitionRankingStream(
        widget.competition!.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SFCard(
            padding: const EdgeInsets.all(32),
            child: const LoadingIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState('Erro ao carregar ranking');
        }

        final rankings = snapshot.data ?? [];

        if (rankings.isEmpty) {
          return _buildEmptyState('Nenhum participante');
        }

        if (hasEnded) {
          return _buildPodiumCard(rankings);
        }

        return _buildActiveRanking(rankings);
      },
    );
  }

  Widget _buildActiveRanking(List<RankingEntryModel> rankings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SectionHeader(
          title: 'Ranking do squad',
          action: 'Ver tudo',
          onAction: () {
            // TODO: Navigate to full ranking
          },
        ),
        const SizedBox(height: 12),

        // Ranking rows
        ...rankings.take(5).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RankingRowV2(
                entry: entry,
                victoryRule: widget.competition!.victoryRule,
              ),
            )),
      ],
    );
  }

  Widget _buildPodiumCard(List<RankingEntryModel> rankings) {
    final winner = rankings.first;
    final isCurrentUserWinner = winner.isCurrentUser;

    return SFCard(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.2),
          AppColors.surfaceDark,
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: const Color(0xFFFFD166),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Desafio Encerrado!',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.competition!.name,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),

          // Podium
          _buildPodium(rankings.take(3).toList()),
          const SizedBox(height: 24),

          // Winner message
          if (isCurrentUserWinner)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lime.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: AppColors.lime),
                  const SizedBox(width: 8),
                  Text(
                    'Parabéns! Você venceu!',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
            ),

          if (isCurrentUserWinner) const SizedBox(height: 16),

          // Archive button
          SFButton(
            variant: SFButtonVariant.primary,
            fullWidth: true,
            icon: Icons.check_circle_outline,
            onPressed: () => _showDismissConfirmation(context),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<RankingEntryModel> top3) {
    final positions = <RankingEntryModel?>[];
    positions.add(top3.length > 1 ? top3[1] : null);
    positions.add(top3.isNotEmpty ? top3[0] : null);
    positions.add(top3.length > 2 ? top3[2] : null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (positions[0] != null)
          _buildPodiumPlace(positions[0]!, 2, Colors.grey.shade400, 80),
        const SizedBox(width: 8),
        if (positions[1] != null)
          _buildPodiumPlace(positions[1]!, 1, const Color(0xFFFFD166), 100),
        const SizedBox(width: 8),
        if (positions[2] != null)
          _buildPodiumPlace(positions[2]!, 3, Colors.brown.shade300, 60),
      ],
    );
  }

  Widget _buildPodiumPlace(
    RankingEntryModel entry,
    int position,
    Color color,
    double height,
  ) {
    final displayValue =
        widget.competition!.victoryRule == VictoryRule.percentageLoss
            ? '-${entry.percentageLost.abs().toStringAsFixed(1)}%'
            : '-${entry.weightLost.abs().toStringAsFixed(1)}kg';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SFAvatar(
          initials: entry.userName.split(' ').first.substring(0, 1).toUpperCase() +
              (entry.userName.split(' ').length > 1
                  ? entry.userName.split(' ').last.substring(0, 1).toUpperCase()
                  : ''),
          size: position == 1 ? 56 : 44,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.6)],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            entry.userName.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight:
                  entry.isCurrentUser ? FontWeight.bold : FontWeight.w500,
              fontSize: position == 1 ? 14 : 12,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            color: AppColors.lime,
            fontWeight: FontWeight.bold,
            fontSize: position == 1 ? 14 : 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '$positionº',
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDismissConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Arquivar Desafio',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Ao arquivar, este desafio será removido da sua tela inicial. Deseja continuar?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          SFButton(
            variant: SFButtonVariant.primary,
            size: SFButtonSize.sm,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _competitionService.archiveCompetition(widget.competition!.id);
        if (context.mounted) {
          SnackBarHelper.showSuccess(context, 'Desafio arquivado com sucesso');
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(
              context, 'Não foi possível arquivar o desafio. Tente novamente.');
        }
      }
    }
  }

  Widget _buildEmptyState(String message) {
    return SFCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 48,
              color: AppColors.textTertiaryDark,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingRowV2 extends StatelessWidget {
  final RankingEntryModel entry;
  final VictoryRule victoryRule;

  const _RankingRowV2({
    required this.entry,
    required this.victoryRule,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = victoryRule == VictoryRule.percentageLoss
        ? '${entry.percentageLost >= 0 ? '-' : '+'}${entry.percentageLost.abs().toStringAsFixed(1)}%'
        : '${entry.weightLost >= 0 ? '-' : '+'}${entry.weightLost.abs().toStringAsFixed(1)} kg';

    final medal = _getMedalColor(entry.position);

    return SFCard(
      variant: entry.isCurrentUser ? SFCardVariant.highlight : SFCardVariant.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: medal != null
                  ? LinearGradient(
                      colors: [medal, medal.withValues(alpha: 0.6)],
                    )
                  : null,
              color: medal == null ? AppColors.surface2 : null,
              borderRadius: BorderRadius.circular(10),
              border: medal == null
                  ? Border.all(color: AppColors.borderDark)
                  : null,
              boxShadow: medal != null
                  ? [
                      BoxShadow(
                        color: medal.withValues(alpha: 0.4),
                        blurRadius: 16,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '${entry.position}',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: medal != null ? AppColors.deep : AppColors.textSecondaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          SFAvatar(
            initials: _getInitials(entry.userName),
            size: 40,
            gradient: AppGradients.squad,
          ),
          const SizedBox(width: 12),

          // Name and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'VOCÊ',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayValue,
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: entry.isCurrentUser || entry.position <= 3
                      ? AppColors.lime
                      : AppColors.textHighContrast,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color? _getMedalColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD166);
      case 2:
        return const Color(0xFFD9D9E0);
      case 3:
        return const Color(0xFFE09460);
      default:
        return null;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
