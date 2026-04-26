import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../home/screens/home_screen_v2.dart';
import '../../weight/screens/weight_screen_v2.dart';
import '../../nutrition/screens/nutrition_screen_v2.dart';
import '../../competition/screens/competition_screen_v2.dart';
import '../../profile/screens/profile_screen_v2.dart';

/// Controller global para navegação entre tabs
class MainNavigationController {
  MainNavigationController._();
  static final instance = MainNavigationController._();

  void Function(int)? _onTabChange;

  void setTabChangeCallback(void Function(int) callback) {
    _onTabChange = callback;
  }

  void goToTab(int index) {
    _onTabChange?.call(index);
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Lazy loading das telas para manter estado
  final List<Widget> _screens = [
    const HomeScreenV2(),
    const WeightScreenV2(),
    const NutritionScreenV2(),
    const CompetitionScreenV2(),
    const ProfileScreenV2(),
  ];

  @override
  void initState() {
    super.initState();
    MainNavigationController.instance.setTabChangeCallback(_onTabTapped);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomTabBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
