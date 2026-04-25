import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/models/ranking_entry_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../nutrition/models/daily_summary.dart';
import '../../nutrition/screens/nutrition_screen_v2.dart';
import '../../nutrition/services/nutrition_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/ranking_list_v2.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  final _competitionService = getIt<CompetitionService>();
  final _userService = getIt<UserService>();
  final _weightService = getIt<WeightService>();
  final _nutritionService = getIt<NutritionService>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundDark,
      drawer: const AppDrawer(),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: StreamBuilder<List<CompetitionModel>>(
          stream: _competitionService.getMyCompetitionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            final competitions = snapshot.data ?? [];
            final currentCompetition =
                _competitionService.getCurrentCompetition(competitions);

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildStreakBanner(),
                      const SizedBox(height: 14),
                      _buildNutritionHeroCard(),
                      const SizedBox(height: 14),
                      _buildQuickStats(currentCompetition),
                      const SizedBox(height: 20),
                      RankingListV2(competition: currentCompetition),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildHeader() {
    return StreamBuilder<UserModel?>(
      stream: _userService.getCurrentUserStream(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final firstName = user?.firstName ?? 'Usuário';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: SFAvatar(
                  initials: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  size: 40,
                  gradient: AppGradients.hype,
                  imageUrl: user?.photoUrl,
                ),
              ),
              const SizedBox(width: 12),
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
              GestureDetector(
                onTap: () {
                  SnackBarHelper.showInfo(
                    context,
                    'Notificações em desenvolvimento',
                  );
                },
                child: Container(
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakBanner() {
    return FutureBuilder<int>(
      future: _nutritionService.getStreak(),
      builder: (context, snapshot) {
        final streakDays = snapshot.data ?? 0;

        if (streakDays == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0x38FA8038),
                Color(0x1FFF3B8B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.glowOrange,
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_fire_department,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakDays dias em chamas 🔥',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Registre uma refeição pra manter a sequência',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$streakDays',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionHeroCard() {
    final today = DateTime.now();
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final monthNames = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final dateStr = '${dayNames[today.weekday % 7]} · ${today.day} ${monthNames[today.month - 1]}';

    return FutureBuilder<DailySummary>(
      future: _nutritionService.getDailySummary(today),
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final consumed = summary?.totalCalories ?? 0;
        final dailyCalorieGoal = summary?.calorieGoal ?? 1800;
        final remaining = dailyCalorieGoal - consumed;
        final progress = dailyCalorieGoal > 0
            ? ((consumed / dailyCalorieGoal) * 100).clamp(0.0, 100.0)
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NutritionScreenV2()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surface2, AppColors.surfaceDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderDark),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                children: [
                  // Glow laranja - posicionado atrás do conteúdo
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
                  // Conteúdo
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
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
                        Row(
                          children: [
                            ProgressRing(
                              value: progress,
                              size: 130,
                              label: 'Meta diária',
                              bigLabel: '${progress.toInt()}',
                              unit: '%',
                              strokeWidth: 9,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNutritionStatRow(
                                    'Calorias',
                                    '$consumed',
                                    '/ $dailyCalorieGoal',
                                    Colors.white,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildNutritionStatRow(
                                    'Restante',
                                    '${remaining > 0 ? remaining : 0}',
                                    'kcal',
                                    remaining > 0 ? AppColors.lime : AppColors.error,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionStatRow(String label, String value, String unit, Color valueColor) {
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
                color: valueColor,
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

  Widget _buildQuickStats(CompetitionModel? competition) {
    return StreamBuilder(
      stream: Rx.combineLatest2(
        _userService.getCurrentUserStream(),
        _weightService.getWeightHistoryStream(),
        (UserModel? user, List<WeightRecordModel> weights) => (user, weights),
      ),
      builder: (context, snapshot) {
        final user = snapshot.data?.$1;
        final weights = snapshot.data?.$2 ?? [];

        final initialWeight = user?.initialWeight;
        final currentWeight = weights.isNotEmpty ? weights.first.weight : initialWeight;

        double? weightLost;
        if (initialWeight != null && currentWeight != null) {
          weightLost = initialWeight - currentWeight;
        }

        return Row(
          children: [
            Expanded(
              child: StatPill(
                label: 'Peso',
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
              child: _buildPositionPill(competition),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionPill(CompetitionModel? competition) {
    if (competition == null) {
      return StatPill(
        label: 'Posição',
        value: '--',
        icon: Icons.leaderboard_outlined,
        accentColor: AppColors.secondary,
      );
    }

    return FutureBuilder<List<RankingEntryModel>>(
      future: _competitionService.getCompetitionRanking(competition.id),
      builder: (context, snapshot) {
        int position = 0;

        if (snapshot.hasData) {
          final ranking = snapshot.data!;
          final myEntry = ranking.where((e) => e.isCurrentUser).firstOrNull;
          position = myEntry?.position ?? 0;
        }

        return StatPill(
          label: 'Posição',
          value: position > 0 ? '#$position' : '--',
          icon: Icons.leaderboard_outlined,
          accentColor: position == 1 ? AppColors.lime : AppColors.secondary,
        );
      },
    );
  }
}
