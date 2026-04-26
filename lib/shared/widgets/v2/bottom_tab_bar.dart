import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deep,
        border: Border(
          top: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryDark,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          items: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Início',
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.monitor_weight_rounded,
              label: 'Peso',
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Diário',
              isSelected: currentIndex == 2,
              isCenter: true,
            ),
            _buildNavItem(
              icon: Icons.emoji_events_rounded,
              label: 'Desafio',
              isSelected: currentIndex == 3,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              isSelected: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isCenter = false,
  }) {
    if (isCenter) {
      return BottomNavigationBarItem(
        icon: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.primary : null,
            color: isSelected ? null : AppColors.surface2,
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? null : Border.all(color: AppColors.borderDark),
            boxShadow: isSelected ? AppShadows.glowOrange : null,
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
        label: label,
      );
    }

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 20 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: isSelected ? AppShadows.glowOrange : null,
            ),
          ),
          Icon(icon, size: 22),
        ],
      ),
      label: label,
    );
  }
}
