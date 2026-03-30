import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/services/competition_service.dart';

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

class UserStatsCard extends StatefulWidget {
  const UserStatsCard({super.key});

  @override
  State<UserStatsCard> createState() => _UserStatsCardState();
}

class _UserStatsCardState extends State<UserStatsCard> {
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
      (UserModel? user, WeightRecordModel? weight, CompetitionModel? competition) {
        return _UserStatsData(
          user: user,
          latestWeight: weight,
          activeCompetition: competition,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<_UserStatsData>(
      stream: _combinedStream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return _buildCard(
          context,
          colorScheme,
          data?.user,
          data?.latestWeight,
          data?.activeCompetition,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    ColorScheme colorScheme,
    UserModel? user,
    WeightRecordModel? latestWeight,
    CompetitionModel? activeCompetition,
  ) {
    final firstName = user?.firstName ?? 'Usuário';
    final currentWeight = latestWeight?.weight ?? user?.initialWeight;
    final goalWeight = user?.goalWeight;
    final initialWeight = user?.initialWeight;

    // Calcula perda de peso
    double? weightLost;
    if (initialWeight != null && currentWeight != null) {
      weightLost = initialWeight - currentWeight;
    }

    // Calcula progresso
    double progress = 0;
    if (initialWeight != null && goalWeight != null && currentWeight != null) {
      final totalToLose = initialWeight - goalWeight;
      if (totalToLose > 0) {
        final lost = initialWeight - currentWeight;
        progress = (lost / totalToLose).clamp(0.0, 1.0);
      }
    }

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.white,
                        )
                      : null,
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
                          'Olá, $firstName!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          activeCompetition != null
                              ? 'Competição: ${activeCompetition.name}'
                              : 'Sem competição ativa',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso Atual',
                    value: currentWeight != null
                        ? '${currentWeight.toStringAsFixed(1)} kg'
                        : '-- kg',
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.flag_outlined,
                    label: 'Meta',
                    value: goalWeight != null
                        ? '${goalWeight.toStringAsFixed(1)} kg'
                        : '-- kg',
                    color: colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: weightLost != null && weightLost >= 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    label: 'Perdido',
                    value: weightLost != null
                        ? '${weightLost >= 0 ? '-' : '+'}${weightLost.abs().toStringAsFixed(1)} kg'
                        : '-- kg',
                    color: weightLost != null && weightLost >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goalWeight != null
                  ? '${(progress * 100).toInt()}% da meta atingida'
                  : 'Defina uma meta de peso',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
