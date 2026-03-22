import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
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
  final _competitionService = getIt<CompetitionService>();

  @override
  Widget build(BuildContext context) {
    if (widget.competition == null) {
      return _buildEmptyState(context, 'Sem competição ativa');
    }

    final hasEnded = widget.competition!.hasEnded;

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

        // Se a competição encerrou, mostra o pódio
        if (hasEnded) {
          return _buildPodiumCard(context, rankings);
        }

        // Ranking normal para competição ativa
        return _buildActiveRanking(context, rankings);
      },
    );
  }

  Widget _buildActiveRanking(
    BuildContext context,
    List<RankingEntryModel> rankings,
  ) {
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
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 72, color: Colors.black26),
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
  }

  Widget _buildPodiumCard(
    BuildContext context,
    List<RankingEntryModel> rankings,
  ) {
    final top3 = rankings.take(3).toList();
    final winner = rankings.first;
    final isCurrentUserWinner = winner.isCurrentUser;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Desafio Encerrado!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.competition!.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Pódio visual
              _buildPodium(context, top3),

              const SizedBox(height: 24),

              // Mensagem de parabéns se o usuário venceu
              if (isCurrentUserWinner)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Parabéns! Você venceu!',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isCurrentUserWinner) const SizedBox(height: 16),

              // Botão de concluir
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDismissConfirmation(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Concluir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<RankingEntryModel> top3) {
    // Reorganiza para mostrar: 2º | 1º | 3º
    final positions = <RankingEntryModel?>[];
    positions.add(top3.length > 1 ? top3[1] : null); // 2º lugar
    positions.add(top3.isNotEmpty ? top3[0] : null); // 1º lugar
    positions.add(top3.length > 2 ? top3[2] : null); // 3º lugar

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2º lugar
        if (positions[0] != null)
          _buildPodiumPlace(
            context,
            positions[0]!,
            2,
            Colors.grey.shade400,
            80,
          ),
        const SizedBox(width: 8),
        // 1º lugar
        if (positions[1] != null)
          _buildPodiumPlace(context, positions[1]!, 1, Colors.amber, 100),
        const SizedBox(width: 8),
        // 3º lugar
        if (positions[2] != null)
          _buildPodiumPlace(
            context,
            positions[2]!,
            3,
            Colors.brown.shade300,
            60,
          ),
      ],
    );
  }

  Widget _buildPodiumPlace(
    BuildContext context,
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
        // Avatar/Ícone
        CircleAvatar(
          radius: position == 1 ? 28 : 22,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            Icons.emoji_events,
            color: color,
            size: position == 1 ? 28 : 22,
          ),
        ),
        const SizedBox(height: 8),
        // Nome
        SizedBox(
          width: 80,
          child: Text(
            entry.userName.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: entry.isCurrentUser
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: position == 1 ? 14 : 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Peso perdido
        Text(
          displayValue,
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
            fontSize: position == 1 ? 14 : 12,
          ),
        ),
        const SizedBox(height: 8),
        // Pedestal
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$positionº',
              style: TextStyle(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Text('Arquivar Desafio'),
        content: const Text(
          'Ao arquivar, este desafio será removido da sua tela inicial. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desafio arquivado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível arquivar o desafio. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
              Text(message, style: TextStyle(color: Colors.grey.shade600)),
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

  const _RankingTile({required this.data, required this.victoryRule});

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
                  fontWeight: data.isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.normal,
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
                'Você',
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
          color: (isPositive ? Colors.green : Colors.red).withValues(
            alpha: 0.2,
          ),
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
