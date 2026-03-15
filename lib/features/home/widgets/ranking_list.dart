import 'package:flutter/material.dart';
import '../../../core/models/ranking_entry_model.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';

class RankingList extends StatefulWidget {
  final CompetitionModel? competition;

  const RankingList({super.key, this.competition});

  @override
  State<RankingList> createState() => _RankingListState();
}

class _RankingListState extends State<RankingList> {
  final _competitionService = CompetitionService();

  @override
  Widget build(BuildContext context) {
    if (widget.competition == null) {
      return _buildEmptyState(context, 'Sem competicao ativa');
    }

    return StreamBuilder<List<RankingEntryModel>>(
      stream: _competitionService.getCompetitionRankingStream(
        widget.competition!.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(context, 'Erro ao carregar ranking');
        }

        final rankings = snapshot.data ?? [];

        if (rankings.isEmpty) {
          return _buildEmptyState(context, 'Nenhum participante');
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ranking - ${widget.competition!.name}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rankings.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  indent: 72,
                  color: Colors.black26,
                ),
                itemBuilder: (context, index) {
                  final ranking = rankings[index];
                  return _RankingTile(
                    data: ranking,
                    victoryRule: widget.competition!.victoryRule,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  final RankingEntryModel data;
  final VictoryRule victoryRule;

  const _RankingTile({
    required this.data,
    required this.victoryRule,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determina o valor a exibir baseado na regra de vitória
    final displayValue = victoryRule == VictoryRule.percentageLoss
        ? '${data.percentageLost >= 0 ? '-' : '+'}${data.percentageLost.abs().toStringAsFixed(1)}%'
        : '${data.weightLost >= 0 ? '-' : '+'}${data.weightLost.abs().toStringAsFixed(1)} kg';

    final isPositive = data.weightLost >= 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildPositionBadge(context),
      title: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.userName,
                style: TextStyle(
                  fontWeight: data.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (data.isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Voce',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayValue,
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionBadge(BuildContext context) {
    Color badgeColor;
    IconData? icon;

    switch (data.position) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.brown.shade300;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.grey;
        icon = null;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: CircleAvatar(
        backgroundColor: badgeColor.withValues(alpha: 0.2),
        child: icon != null
            ? Icon(icon, color: badgeColor, size: 20)
            : Text(
                '${data.position}',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
