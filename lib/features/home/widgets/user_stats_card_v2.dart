import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/widgets/v2/v2.dart';

/// Dados combinados para o UserStatsCard
class _UserStatsData {
  final UserModel? user;
  final WeightRecordModel? latestWeight;
  final CompetitionModel? activeCompetition;

  _UserStatsData({
    this.user,
    this.latestWeight,
    this.activeCompetition,
  });
}

class UserStatsCardV2 extends StatefulWidget {
  const UserStatsCardV2({super.key});

  @override
  State<UserStatsCardV2> createState() => _UserStatsCardV2State();
}

class _UserStatsCardV2State extends State<UserStatsCardV2> {
  final _userService = getIt<UserService>();
  final _weightService = getIt<WeightService>();
  final _competitionService = getIt<CompetitionService>();

  late final Stream<_UserStatsData> _combinedStream;

  @override
  void initState() {
    super.initState();
    _combinedStream = _createCombinedStream();
  }

  Stream<_UserStatsData> _createCombinedStream() {
    final userStream = _userService.getCurrentUserStream();

    final weightStream = _weightService
        .getWeightHistoryStream()
        .map((records) => records.isNotEmpty ? records.first : null);

    final competitionStream = _competitionService
        .getMyCompetitionsStream()
        .map((competitions) =>
            competitions.where((c) => !c.hasEnded).toList().firstOrNull);

    return Rx.combineLatest3(
      userStream,
      weightStream,
      competitionStream,
      (UserModel? user, WeightRecordModel? weight, CompetitionModel? comp) {
        return _UserStatsData(
          user: user,
          latestWeight: weight,
          activeCompetition: comp,
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_UserStatsData>(
      stream: _combinedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SFCard(
            padding: const EdgeInsets.all(40),
            child: const LoadingIndicator(),
          );
        }

        final data = snapshot.data;
        return _buildCard(context, data);
      },
    );
  }

  Widget _buildCard(BuildContext context, _UserStatsData? data) {
    final user = data?.user;
    final latestWeight = data?.latestWeight;
    final activeCompetition = data?.activeCompetition;

    final firstName = user?.firstName ?? 'Usuário';
    final currentWeight = latestWeight?.weight ?? user?.initialWeight;
    final goalWeight = user?.goalWeight;
    final initialWeight = user?.initialWeight;

    // Calcula perda de peso
    double? weightLost;
    if (initialWeight != null && currentWeight != null) {
      weightLost = initialWeight - currentWeight;
    }

    // Calcula progresso (0-100)
    double progress = 0;
    if (initialWeight != null && goalWeight != null && currentWeight != null) {
      final totalToLose = initialWeight - goalWeight;
      if (totalToLose > 0) {
        final lost = initialWeight - currentWeight;
        progress = ((lost / totalToLose) * 100).clamp(0.0, 100.0);
      }
    }

    return Column(
      children: [
        // Header com avatar e nome
        _buildHeader(context, firstName, user?.photoUrl, activeCompetition),
        const SizedBox(height: 16),

        // Hero card com ring de progresso
        _buildHeroCard(
          context,
          progress,
          currentWeight,
          goalWeight,
          weightLost,
        ),
        const SizedBox(height: 12),

        // Quick stats row
        _buildQuickStats(context, weightLost),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String firstName,
    String? photoUrl,
    CompetitionModel? competition,
  ) {
    return Row(
      children: [
        // Avatar
        SFAvatar(
          initials: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          size: 44,
          gradient: AppGradients.hype,
          imageUrl: photoUrl,
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              Text(
                firstName,
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Notification button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications,
                  size: 20,
                  color: AppColors.textHighContrast,
                ),
              ),
              // Notification dot
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.magenta,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.magenta.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    double progress,
    double? currentWeight,
    double? goalWeight,
    double? weightLost,
  ) {
    final today = DateTime.now();
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final monthNames = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    final dateStr =
        '${dayNames[today.weekday % 7]} · ${today.day} ${monthNames[today.month - 1]}';

    return SFCard(
      variant: SFCardVariant.elevated,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          // Glow effect
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoje · $dateStr'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  SFChip(
                    label: 'Ativo',
                    icon: Icons.bolt,
                    color: AppColors.lime,
                    backgroundColor: AppColors.lime.withValues(alpha: 0.12),
                    borderColor: AppColors.lime.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress ring and stats
              Row(
                children: [
                  // Ring
                  ProgressRing(
                    value: progress,
                    size: 130,
                    label: 'Meta diária',
                    bigLabel: '${progress.toInt()}',
                    unit: '%',
                    strokeWidth: 9,
                  ),
                  const SizedBox(width: 16),

                  // Stats column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current weight
                        _buildStatRow(
                          'Peso atual',
                          currentWeight?.toStringAsFixed(1) ?? '--',
                          'kg',
                          Colors.white,
                        ),
                        const SizedBox(height: 14),
                        // Goal
                        _buildStatRow(
                          'Meta',
                          goalWeight?.toStringAsFixed(1) ?? '--',
                          'kg',
                          AppColors.textSecondaryDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, double? weightLost) {
    return Row(
      children: [
        Expanded(
          child: StatPill(
            label: 'Perdido',
            value: weightLost != null
                ? '${weightLost >= 0 ? '-' : '+'}${weightLost.abs().toStringAsFixed(1)}'
                : '--',
            unit: 'kg',
            icon: Icons.monitor_weight_outlined,
            accentColor: weightLost != null && weightLost >= 0
                ? AppColors.lime
                : AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatPill(
            label: 'Posição',
            value: '#--',
            icon: Icons.leaderboard_outlined,
            accentColor: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
