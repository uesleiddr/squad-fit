import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../auth/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = getIt<AuthService>();
  bool _isLoading = false;

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await SFConfirmationDialog.show(
      context,
      title: 'Excluir conta',
      message: 'Tem certeza que deseja excluir sua conta?\n\nEssa acao e irreversivel e todos os seus dados serao perdidos.',
      confirmText: 'Excluir',
      variant: SFConfirmationVariant.destructive,
    );

    if (confirmed == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);

    try {
      await _authService.deleteAccount();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(
          context,
          'Nao foi possivel excluir a conta. Tente novamente.',
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userMetadata = user?.userMetadata;
    final userName =
        userMetadata?['full_name'] as String? ??
        userMetadata?['name'] as String? ??
        'Usuario';
    final userEmail = user?.email ?? '';
    final userPhoto =
        userMetadata?['avatar_url'] as String? ??
        userMetadata?['picture'] as String?;

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: SFLoading())
            : CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Avatar
                          SFAvatar(
                            initials: _getInitials(userName),
                            size: 80,
                            imageUrl: userPhoto,
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            userName,
                            style: TextStyle(
                              fontFamily: AppTypography.fontDisplay,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings sections
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),

                        // Account section
                        _buildSectionHeader('Conta'),
                        const SizedBox(height: 8),
                        SFCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.person_outline,
                                title: 'Editar perfil',
                                onTap: () {
                                  // TODO: Implement edit profile
                                },
                              ),
                              _buildDivider(),
                              _buildSettingsTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notificacoes',
                                onTap: () {
                                  // TODO: Implement notifications
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Danger zone
                        _buildSectionHeader('Zona de perigo'),
                        const SizedBox(height: 8),
                        SFCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                icon: Icons.logout,
                                title: 'Sair da conta',
                                iconColor: AppColors.warning,
                                onTap: _handleSignOut,
                              ),
                              _buildDivider(),
                              _buildSettingsTile(
                                icon: Icons.delete_outline,
                                title: 'Excluir conta',
                                iconColor: AppColors.error,
                                titleColor: AppColors.error,
                                onTap: _confirmDeleteAccount,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderDark,
      indent: 64,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
