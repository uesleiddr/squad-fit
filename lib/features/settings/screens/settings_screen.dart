import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/edit_profile_modal.dart';
import '../widgets/edit_calorie_goal_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _userService = getIt<UserService>();
  final _authService = getIt<AuthService>();

  UserModel? _user;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openEditProfile() async {
    if (_user == null) return;

    final updated = await EditProfileModal.show(context, _user!);
    if (updated == true) {
      _loadUser();
    }
  }

  Future<void> _openEditCalorieGoal() async {
    if (_user == null) return;

    final updated = await EditCalorieGoalModal.show(context, _user!.calorieGoal);
    if (updated == true) {
      _loadUser();
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta?\n\n'
          'Essa acao e irreversivel e todos os seus dados serao perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      // Primeiro deleta o perfil do usuario
      await _userService.deleteUserProfile();

      // Depois deleta a conta de autenticacao
      await _authService.deleteAccount();

      if (mounted) {
        // Navega para a tela de login
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        SnackBarHelper.showError(
          context,
          'Nao foi possivel excluir a conta. Tente novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LoadingScaffold(
      isLoading: _isLoading || _isDeleting,
      appBar: AppBar(
        title: const Text('Configuracoes'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Secao: Perfil
                _SectionHeader(title: 'Perfil'),
                Card(
                  elevation: 2,
                  color: colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Dados pessoais',
                        subtitle: _user?.fullName ?? 'Carregando...',
                        onTap: _openEditProfile,
                      ),
                      Divider(height: 1, color: colorScheme.outlineVariant),
                      _SettingsTile(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Meta de calorias',
                        subtitle: '${_user?.calorieGoal ?? 2000} kcal/dia',
                        onTap: _openEditCalorieGoal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Secao: Conta
                _SectionHeader(title: 'Conta'),
                Card(
                  elevation: 2,
                  color: colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: _user?.email ?? 'Carregando...',
                        onTap: null,
                      ),
                      Divider(height: 1, color: colorScheme.outlineVariant),
                      _SettingsTile(
                        icon: Icons.delete_outline,
                        title: 'Excluir conta',
                        subtitle: 'Remove permanentemente sua conta',
                        iconColor: colorScheme.error,
                        titleColor: colorScheme.error,
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: colorScheme.outline)
          : null,
      onTap: onTap,
    );
  }
}
