import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../home/widgets/ranking_list_v2.dart';
import '../widgets/create_competition_modal_v2.dart';
import '../widgets/edit_competition_modal.dart';
import '../widgets/join_competition_modal_v2.dart';

class CompetitionScreenV2 extends StatefulWidget {
  const CompetitionScreenV2({super.key});

  @override
  State<CompetitionScreenV2> createState() => _CompetitionScreenV2State();
}

class _CompetitionScreenV2State extends State<CompetitionScreenV2> {
  final _competitionService = getIt<CompetitionService>();
  Key _streamKey = UniqueKey();

  void _refreshStream() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  Future<void> _onRefresh() async {
    _refreshStream();
    // Aguarda um pouco para dar tempo do stream atualizar
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SafeArea(
        child: Stack(
          children: [
            // Background glows
            _buildBackgroundGlows(),

            // Content
            StreamBuilder<List<CompetitionModel>>(
              key: _streamKey,
              stream: _competitionService.getMyCompetitionsStream(),
              builder: (context, snapshot) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceDark,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // App bar
                      SliverToBoxAdapter(
                        child: _buildAppBar(context, snapshot.data),
                      ),

                      // Body
                      SliverPadding(
                        padding: context.screenPadding.copyWith(top: 8),
                        sliver: SliverToBoxAdapter(
                          child: _buildBody(context, snapshot),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, List<CompetitionModel>? competitions) {
    final currentCompetition = competitions != null
        ? _competitionService.getCurrentCompetition(competitions)
        : null;
    final activeCompetition = currentCompetition != null && !currentCompetition.hasEnded
        ? currentCompetition
        : null;
    final isAdmin = currentCompetition != null &&
        _competitionService.isCurrentUserAdmin(currentCompetition.adminId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Text(
              'Desafio',
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          // Actions
          if (activeCompetition != null && !isAdmin)
            _buildActionButton(
              icon: Icons.exit_to_app,
              onTap: () => _showLeaveConfirmation(context, activeCompetition),
            ),
          if (activeCompetition != null && isAdmin) ...[
            _buildActionButton(
              icon: Icons.edit_outlined,
              onTap: () => _showEditCompetition(context, activeCompetition),
            ),
            const SizedBox(width: 8),
          ],
          if (currentCompetition != null && isAdmin)
            _buildActionButton(
              icon: Icons.delete_outline,
              color: AppColors.error,
              onTap: () => _showDeleteConfirmation(context, currentCompetition),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? AppColors.textHighContrast,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<CompetitionModel>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SFLoadingSpinner(
        message: 'Carregando...',
      );
    }

    if (snapshot.hasError) {
      return _buildErrorState(context, snapshot.error.toString());
    }

    final competitions = snapshot.data ?? [];
    final currentCompetition = _competitionService.getCurrentCompetition(competitions);

    if (currentCompetition == null) {
      return _buildEmptyState(context);
    }

    return _buildCompetitionDetails(context, currentCompetition);
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final isTokenExpired = errorMessage.contains('InvalidJWTToken') ||
        errorMessage.contains('Token has expired');

    return SFCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            isTokenExpired ? Icons.lock_clock : Icons.error_outline,
            size: 48,
            color: AppColors.textTertiaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            isTokenExpired ? 'Sua sessão expirou' : 'Erro ao carregar',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTokenExpired
                ? 'Faça login novamente para continuar.'
                : 'Tente novamente mais tarde.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          if (isTokenExpired) ...[
            const SizedBox(height: 20),
            SFButton(
              variant: SFButtonVariant.primary,
              icon: Icons.login,
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text('Fazer Login'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SFEmptyState.noSquad(
      onCreateSquad: () => _showCreateModal(context),
      onJoinWithCode: () => _showJoinModal(context),
    );
  }

  Widget _buildCompetitionDetails(BuildContext context, CompetitionModel competition) {
    final daysRemaining = competition.endDate.difference(DateTime.now()).inDays;
    final hasEnded = competition.hasEnded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Competition info card
        SFCard(
          variant: SFCardVariant.elevated,
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              // Glow effect
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        (hasEnded ? Colors.grey : AppColors.primary)
                            .withValues(alpha: 0.2),
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
                      // Trophy icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: hasEnded
                              ? null
                              : AppGradients.primary,
                          color: hasEnded ? AppColors.surface2 : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: hasEnded
                              ? null
                              : AppShadows.glowOrange,
                        ),
                        child: Icon(
                          hasEnded ? Icons.flag : Icons.emoji_events,
                          color: hasEnded ? AppColors.textSecondaryDark : Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              competition.name,
                              style: TextStyle(
                                fontFamily: AppTypography.fontDisplay,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (competition.description != null)
                              Text(
                                competition.description!,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  color: AppColors.textSecondaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      // Status badge
                      SFChip(
                        label: hasEnded
                            ? 'Encerrado'
                            : daysRemaining > 0
                                ? '$daysRemaining dias'
                                : 'Hoje!',
                        icon: hasEnded ? Icons.flag : Icons.bolt,
                        color: hasEnded ? AppColors.textSecondaryDark : AppColors.lime,
                        backgroundColor: hasEnded
                            ? AppColors.surface2
                            : AppColors.lime.withValues(alpha: 0.12),
                        borderColor: hasEnded
                            ? AppColors.borderDark
                            : AppColors.lime.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info rows
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Termina em',
                    value: DateFormatter.format(competition.endDate),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.emoji_events_outlined,
                    label: 'Regra de vitória',
                    value: _getVictoryRuleText(competition.victoryRule),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Invite code card
        _buildInviteCodeCard(context, competition),
        const SizedBox(height: 20),

        // Ranking
        RankingListV2(competition: competition),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textTertiaryDark,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInviteCodeCard(BuildContext context, CompetitionModel competition) {
    return SFCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Convidar Participantes',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(
              competition.inviteCode,
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.outline,
                  icon: Icons.copy,
                  onPressed: () => _copyCode(context, competition.inviteCode),
                  child: const Text('Copiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.primary,
                  icon: Icons.share,
                  onPressed: () => _shareWhatsApp(context, competition),
                  child: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVictoryRuleText(VictoryRule rule) {
    switch (rule) {
      case VictoryRule.totalWeightLoss:
        return 'Maior perda de peso (kg)';
      case VictoryRule.percentageLoss:
        return 'Maior percentual perdido (%)';
    }
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    SFToast.success(context, 'Código copiado!');
  }

  Future<void> _shareWhatsApp(BuildContext context, CompetitionModel competition) async {
    final deepLink = getIt<DeepLinkService>().generateInviteLink(competition.inviteCode);
    final message = 'Entre no meu desafio de emagrecimento no Squad Fit! '
        'Use o código: ${competition.inviteCode}\n\n'
        'Ou clique no link: $deepLink';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        SFToast.error(context, 'Não foi possível abrir o WhatsApp');
      }
    }
  }

  Future<void> _showCreateModal(BuildContext context) async {
    final competition = await CreateCompetitionModalV2.show(context);

    if (competition != null && context.mounted) {
      _refreshStream();
      SFToast.show(
        context,
        title: 'Desafio criado',
        message: competition.name,
        type: SFToastType.success,
      );
    }
  }

  Future<void> _showJoinModal(BuildContext context) async {
    final joined = await JoinCompetitionModalV2.show(context);

    if (joined == true && mounted) {
      _refreshStream();
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CompetitionModel competition,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            Text(
              'Excluir Desafio',
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir este desafio?',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta ação não pode ser desfeita.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ],
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
            variant: SFButtonVariant.destructive,
            size: SFButtonSize.sm,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _competitionService.deleteCompetition(competition.id);
        if (context.mounted) {
          _refreshStream(); // Força atualização para mostrar estado vazio
          SFToast.success(context, 'Desafio excluído com sucesso');
        }
      } catch (e) {
        if (context.mounted) {
          SFToast.error(context, 'Não foi possível excluir o desafio');
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
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: AppColors.warning),
            const SizedBox(width: 12),
            Text(
              'Sair do Desafio',
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja sair deste desafio?',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você poderá entrar novamente usando o código de convite.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textTertiaryDark,
                fontSize: 13,
              ),
            ),
          ],
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
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _competitionService.leaveCompetition(competition.id);
        if (context.mounted) {
          _refreshStream(); // Força atualização para mostrar estado vazio
          SFToast.success(context, 'Você saiu do desafio');
        }
      } catch (e) {
        if (context.mounted) {
          SFToast.error(context, 'Não foi possível sair do desafio');
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
      SFToast.success(context, 'Desafio atualizado com sucesso');
    }
  }
}
