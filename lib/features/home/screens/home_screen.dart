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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _competitionService = getIt<CompetitionService>();
  Key _streamKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStream();
    }
  }

  void _refreshStream() {
    if (mounted) {
      setState(() {
        _streamKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Image.asset(
            'assets/logo/SquadFit-logo-transparent.png',
            height: 168,
          ),
        ),
        centerTitle: true,
      ),
      drawer: AppDrawer(onNavigationReturn: _refreshStream),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: StreamBuilder<List<CompetitionModel>>(
            key: _streamKey,
            stream: _competitionService.getMyCompetitionsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }

              final competitions = snapshot.data ?? [];
              final currentCompetition = _competitionService
                  .getCurrentCompetition(competitions);
              final activeCompetition = competitions
                  .where((c) => !c.hasEnded)
                  .toList()
                  .firstOrNull;

              return RefreshIndicator(
                onRefresh: () async => _refreshStream(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserStatsCard(activeCompetition: activeCompetition),
                      SizedBox(height: context.cardSpacing),
                      RankingList(competition: currentCompetition),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
