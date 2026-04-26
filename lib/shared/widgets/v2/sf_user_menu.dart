import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../core/di/service_locator.dart';

/// Menu que aparece ao clicar no avatar do usuário
class SFUserMenu extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutComplete;

  const SFUserMenu({
    super.key,
    this.onSettingsTap,
    this.onLogoutComplete,
  });

  /// Exibe o menu do usuário
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSettingsTap,
    VoidCallback? onLogoutComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SFUserMenu(
        onSettingsTap: onSettingsTap,
        onLogoutComplete: onLogoutComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Opções
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () {
              Navigator.pop(context);
              onSettingsTap?.call();
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: AppColors.borderDark, height: 1),
          ),

          _buildMenuItem(
            context,
            icon: Icons.logout_rounded,
            label: 'Sair da conta',
            isDestructive: true,
            onTap: () async {
              Navigator.pop(context);
              await _handleLogout(context);
              onLogoutComplete?.call();
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textHighContrast;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: color,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authService = getIt<AuthService>();
      await authService.signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: $e')),
        );
      }
    }
  }
}
