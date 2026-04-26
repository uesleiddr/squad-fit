import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_stats_card.dart';
import '../widgets/ranking_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _competitionService = getIt<CompetitionService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Image.asset(
            'assets/logo/squadfit-icon.png',
            height: 120,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: StreamBuilder<List<CompetitionModel>>(
            stream: _competitionService.getMyCompetitionsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }

              final competitions = snapshot.data ?? [];
              final currentCompetition = _competitionService
                  .getCurrentCompetition(competitions);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: context.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UserStatsCard(),
                    SizedBox(height: context.cardSpacing),
                    RankingList(competition: currentCompetition),
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
