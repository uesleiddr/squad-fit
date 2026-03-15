import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_stats_card.dart';
import '../widgets/ranking_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  final _competitionService = CompetitionService();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onLottieLoaded(LottieComposition composition) {
    _lottieController.duration = composition.duration;
    _lottieController.forward(from: 0);
  }

  void _onDrawerChanged(bool isOpened) {
    if (!isOpened) {
      // Reinicia a animação quando fecha o drawer
      _lottieController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              width: 32,
              child: Lottie.asset(
                'assets/animations/gym.json',
                controller: _lottieController,
                onLoaded: _onLottieLoaded,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text('SquadFit'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      drawerEdgeDragWidth: 60,
      onDrawerChanged: _onDrawerChanged,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: StreamBuilder<List<CompetitionModel>>(
            stream: _competitionService.getMyCompetitionsStream(),
            builder: (context, snapshot) {
              final competitions = snapshot.data ?? [];
              final activeCompetition = competitions
                  .where((c) => !c.hasEnded)
                  .toList()
                  .firstOrNull;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: context.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UserStatsCard(),
                    SizedBox(height: context.cardSpacing),
                    RankingList(competition: activeCompetition),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
