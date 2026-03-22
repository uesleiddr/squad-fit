import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../home/widgets/ranking_list.dart';
import '../widgets/create_competition_modal.dart';
import '../widgets/edit_competition_modal.dart';
import '../widgets/join_competition_modal.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  final _competitionService = getIt<CompetitionService>();

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CompetitionModel competition,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Excluir Desafio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja excluir este desafio?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta ação não pode ser desfeita. Todos os participantes serão removidos.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _competitionService.deleteCompetition(competition.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desafio excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível excluir o desafio. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showLeaveConfirmation(
    BuildContext context,
    CompetitionModel competition,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange),
            SizedBox(width: 12),
            Text('Sair do Desafio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja sair deste desafio?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Você poderá entrar novamente usando o código de convite.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _competitionService.leaveCompetition(competition.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você saiu do desafio'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível sair do desafio. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditCompetition(
    BuildContext context,
    CompetitionModel competition,
  ) async {
    final result = await EditCompetitionModal.show(context, competition);

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafio atualizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CompetitionModel>>(
      stream: _competitionService.getMyCompetitionsStream(),
      builder: (context, snapshot) {
        final competitions = snapshot.data ?? [];

        // Prioriza competição ativa, mas mostra encerrada se não houver ativa
        final activeCompetition = competitions
            .where((c) => !c.hasEnded)
            .toList()
            .firstOrNull;

        final endedCompetition = competitions
            .where((c) => c.hasEnded)
            .toList()
            .firstOrNull;

        final currentCompetition = activeCompetition ?? endedCompetition;

        final isAdmin = currentCompetition != null &&
            _competitionService.isCurrentUserAdmin(currentCompetition.adminId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Desafio'),
            actions: [
              // Botão de sair só aparece para competição ativa e não-admin
              if (activeCompetition != null && !isAdmin)
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: 'Sair do desafio',
                  onPressed: () =>
                      _showLeaveConfirmation(context, activeCompetition),
                ),
              // Botão de editar aparece para admin (apenas competição ativa)
              if (activeCompetition != null && isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar desafio',
                  onPressed: () =>
                      _showEditCompetition(context, activeCompetition),
                ),
              // Botão de excluir aparece para admin (ativa ou encerrada)
              if (currentCompetition != null && isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir desafio',
                  onPressed: () =>
                      _showDeleteConfirmation(context, currentCompetition),
                ),
            ],
          ),
          body: _buildBody(context, snapshot, currentCompetition),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<CompetitionModel>> snapshot,
    CompetitionModel? activeCompetition,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text('Erro ao carregar: ${snapshot.error}'),
      );
    }

    if (activeCompetition == null) {
      return _EmptyState(
        onCreatePressed: () => _showCreateModal(context),
        onJoinWithCode: () => _showJoinModal(context),
      );
    }

    return _CompetitionDetails(
      competition: activeCompetition,
    );
  }

  Future<void> _showCreateModal(BuildContext context) async {
    final competition = await CreateCompetitionModal.show(context);

    if (competition != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafio criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showJoinModal(BuildContext context) async {
    await JoinCompetitionModal.show(context);
  }
}

// Estado vazio - sem competição ativa
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePressed;
  final VoidCallback onJoinWithCode;

  const _EmptyState({
    required this.onCreatePressed,
    required this.onJoinWithCode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum desafio ativo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crie um novo desafio para competir com seus amigos ou entre em um desafio existente usando um código de convite.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onCreatePressed,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Criar Desafio',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: onJoinWithCode,
                icon: const Icon(Icons.login),
                label: const Text(
                  'Entrar com Código',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detalhes da competição ativa
class _CompetitionDetails extends StatelessWidget {
  final CompetitionModel competition;

  const _CompetitionDetails({required this.competition});

  String _getVictoryRuleText(VictoryRule rule) {
    switch (rule) {
      case VictoryRule.totalWeightLoss:
        return 'Maior perda de peso (kg)';
      case VictoryRule.percentageLoss:
        return 'Maior percentual perdido (%)';
    }
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: competition.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final deepLink =
        getIt<DeepLinkService>().generateInviteLink(competition.inviteCode);
    final message = 'Entre no meu desafio de emagrecimento no Squad Fit! '
        'Use o código: ${competition.inviteCode}\n\n'
        'Ou clique no link: $deepLink';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp. '
                'Verifique se o app está instalado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = competition.endDate.difference(DateTime.now()).inDays;
    final hasEnded = competition.hasEnded;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: context.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com nome do desafio
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: hasEnded ? Colors.grey : colorScheme.primary,
                          child: Icon(
                            hasEnded ? Icons.flag : Icons.emoji_events,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  competition.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (competition.description != null)
                                Text(
                                  competition.description!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.7),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hasEnded
                            ? Colors.grey.withValues(alpha: 0.2)
                            : colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasEnded
                            ? 'Encerrado'
                            : daysRemaining > 0
                                ? '$daysRemaining dias restantes'
                                : 'Encerra hoje!',
                        style: TextStyle(
                          color: hasEnded ? Colors.grey : colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.cardSpacing),

            // Informações do desafio
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Termina em',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              Text(
                                DateFormatter.format(competition.endDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Regra de vitória',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              Text(
                                _getVictoryRuleText(competition.victoryRule),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.cardSpacing),

            // Código de convite
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Convidar Participantes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Código de Convite',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        competition.inviteCode,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyCode(context),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copiar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareWhatsApp(context),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.cardSpacing),

            // Ranking dos participantes
            RankingList(competition: competition),
          ],
        ),
      ),
    );
  }
}
