import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../navigation/screens/main_navigation_shell.dart';
import '../../nutrition/services/nutrition_service.dart';
import '../../settings/screens/settings_screen_v2.dart';

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2> {
  final _userService = getIt<UserService>();
  final _weightService = getIt<WeightService>();
  final _competitionService = getIt<CompetitionService>();
  final _nutritionService = getIt<NutritionService>();

  int _streak = 0;
  Key _streamKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _nutritionService.getStreak();
    if (mounted) {
      setState(() => _streak = streak);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _streamKey = UniqueKey();
    });
    await _loadStreak();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: StreamBuilder<_ProfileData>(
          key: _streamKey,
          stream: _buildProfileStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SFLoading());
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(child: SFLoading());
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceDark,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildHeroSection(data),
                        const SizedBox(height: 24),
                        _buildStatsGrid(data),
                        const SizedBox(height: 24),
                        _buildWeightEvolution(data),
                        const SizedBox(height: 24),
                        _buildActiveCompetitions(data),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Stream<_ProfileData> _buildProfileStream() {
    return Rx.combineLatest3<UserModel?, List<WeightRecordModel>,
        List<CompetitionModel>, _ProfileData>(
      _userService.getCurrentUserStream(),
      _weightService.getWeightHistoryStream(),
      _competitionService.getMyCompetitionsStream(),
      (user, weights, competitions) {
        return _ProfileData(
          user: user,
          weights: weights,
          competitions: competitions,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Perfil',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreenV2()),
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
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppColors.textHighContrast,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(_ProfileData data) {
    final user = data.user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'Usuário';
    final initials = _getInitials(displayName);
    final memberSince = _formatMemberSince(user?.createdAt);
    final activeCompetitions = data.competitions.where((c) => c.isActive).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Avatar grande
          SFAvatar(
            initials: initials,
            size: 96,
            gradient: AppGradients.hype,
            imageUrl: user?.photoUrl,
            showRing: true,
          ),
          const SizedBox(height: 16),

          // Nome
          Text(
            displayName,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Membro desde
          Text(
            memberSince,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),

          // Chips informativos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                icon: Icons.local_fire_department_rounded,
                label: '$_streak dias',
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                icon: Icons.emoji_events_rounded,
                label: '${data.victories} vitórias',
                color: AppColors.lime,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                icon: Icons.group_rounded,
                label: '$activeCompetitions squads',
                color: AppColors.magenta,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(_ProfileData data) {
    final user = data.user;
    final latestWeight = data.weights.isNotEmpty ? data.weights.first.weight : null;
    final weightLost = _calculateWeightLost(user?.initialWeight, latestWeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildStatCard(
        icon: Icons.trending_down_rounded,
        label: 'Peso perdido',
        value: weightLost != null ? '${weightLost.toStringAsFixed(1)} kg' : '--',
        color: AppColors.success,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightEvolution(_ProfileData data) {
    final user = data.user;
    final latestWeight = data.weights.isNotEmpty ? data.weights.first.weight : null;
    final goalWeight = user?.goalWeight;
    final initialWeight = user?.initialWeight;

    // Pegar últimos 30 dias
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentWeights = data.weights
        .where((w) => w.date.isAfter(thirtyDaysAgo))
        .toList();

    double? deltaWeight;
    if (recentWeights.length >= 2) {
      deltaWeight = recentWeights.first.weight - recentWeights.last.weight;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Evolução · 30 dias',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                if (deltaWeight != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deltaWeight < 0
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${deltaWeight < 0 ? '' : '+'}${deltaWeight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: deltaWeight < 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Peso atual
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  latestWeight?.toStringAsFixed(1) ?? '--',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'kg',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini chart visual
            if (recentWeights.isNotEmpty) _buildMiniChart(recentWeights),

            const SizedBox(height: 16),

            // Meta
            if (goalWeight != null && latestWeight != null)
              _buildGoalProgress(latestWeight, goalWeight, initialWeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(List<WeightRecordModel> weights) {
    if (weights.isEmpty) return const SizedBox.shrink();

    final minWeight = weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final effectiveRange = range < 0.5 ? 1.0 : range;

    return SizedBox(
      height: 60,
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _WeightChartPainter(
          weights: weights.reversed.toList(),
          minWeight: minWeight - (effectiveRange * 0.1),
          maxWeight: maxWeight + (effectiveRange * 0.1),
        ),
      ),
    );
  }

  Widget _buildGoalProgress(double current, double goal, double? initial) {
    final start = initial ?? current + 5;
    final totalToLose = start - goal;
    final lost = start - current;
    final progress = totalToLose > 0 ? (lost / totalToLose).clamp(0.0, 1.0) : 0.0;
    final remaining = current - goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meta: ${goal.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
            Text(
              remaining > 0
                  ? '${remaining.toStringAsFixed(1)} kg restantes'
                  : 'Meta atingida!',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: remaining > 0 ? AppColors.primary : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppShadows.glowOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCompetitions(_ProfileData data) {
    final activeComps = data.competitions.where((c) => c.isActive).toList();

    if (activeComps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPETIÇÕES ATIVAS',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          ...activeComps.map((comp) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCompetitionCard(comp),
              )),
        ],
      ),
    );
  }

  Widget _buildCompetitionCard(CompetitionModel competition) {
    final daysLeft = competition.endDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        // Navega para a tela de competições (tab index 3 no MainNavigationShell)
        // Usamos um callback global para mudar a tab
        _navigateToCompetitionTab();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysLeft > 0 ? '$daysLeft dias restantes' : 'Termina hoje',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiaryDark,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCompetitionTab() {
    // Muda para a tab de competições (index 3)
    MainNavigationController.instance.goToTab(3);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _formatMemberSince(DateTime? date) {
    if (date == null) return 'Membro';

    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return 'Membro desde ${months[date.month - 1]}/${date.year}';
  }

  double? _calculateWeightLost(double? initial, double? current) {
    if (initial == null || current == null) return null;
    final lost = initial - current;
    return lost > 0 ? lost : null;
  }
}

class _ProfileData {
  final UserModel? user;
  final List<WeightRecordModel> weights;
  final List<CompetitionModel> competitions;

  _ProfileData({
    required this.user,
    required this.weights,
    required this.competitions,
  });

  int get victories {
    // TODO: Implementar contagem de vitórias quando tiver essa informação
    return 0;
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightRecordModel> weights;
  final double minWeight;
  final double maxWeight;

  _WeightChartPainter({
    required this.weights,
    required this.minWeight,
    required this.maxWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final range = maxWeight - minWeight;

    for (int i = 0; i < weights.length; i++) {
      final x = (i / (weights.length - 1)) * size.width;
      final normalizedY = (weights[i].weight - minWeight) / range;
      final y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Ponto final
    if (weights.isNotEmpty) {
      final lastX = size.width;
      final lastNormalizedY = (weights.last.weight - minWeight) / range;
      final lastY = size.height - (lastNormalizedY * size.height);

      final dotPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);

      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 8, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
