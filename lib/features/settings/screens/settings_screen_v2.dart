import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../../auth/services/auth_service.dart';
import '../../nutrition/services/nutrition_service.dart';

class SettingsScreenV2 extends StatefulWidget {
  const SettingsScreenV2({super.key});

  @override
  State<SettingsScreenV2> createState() => _SettingsScreenV2State();
}

class _SettingsScreenV2State extends State<SettingsScreenV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = getIt<AuthService>();
  final _userService = getIt<UserService>();
  final _nutritionService = getIt<NutritionService>();
  final _supabase = Supabase.instance.client;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isGoogleLogin = false;
  String _email = '';

  // Goals
  UserModel? _userProfile;
  int _calorieGoal = 2000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final metadata = user.userMetadata;
    final provider = user.appMetadata['provider'] as String?;

    // Load user profile from database
    final userProfile = await _userService.getCurrentUser();

    setState(() {
      _isGoogleLogin = provider == 'google';
      _email = user.email ?? '';
      _userProfile = userProfile;
      _calorieGoal = userProfile?.calorieGoal ?? 2000;

      // Tenta pegar nome e sobrenome separados ou do full_name
      final fullName = metadata?['full_name'] as String? ??
          metadata?['name'] as String? ??
          '';
      final parts = fullName.split(' ');

      _firstNameController.text = metadata?['first_name'] as String? ??
          (parts.isNotEmpty ? parts.first : '');
      _lastNameController.text = metadata?['last_name'] as String? ??
          (parts.length > 1 ? parts.sublist(1).join(' ') : '');
    });
  }

  Future<void> _editWeightGoal() async {
    final newGoal = await SFWeightGoalModal.show(
      context,
      currentGoal: _userProfile?.goalWeight,
      currentWeight: null, // Could fetch latest weight here
    );

    if (newGoal != null && mounted) {
      try {
        await _userService.updateUser(goalWeight: newGoal);
        await _loadUserData();
        if (mounted) {
          SFToast.success(context, 'Meta de peso atualizada para ${newGoal.toStringAsFixed(1)} kg');
        }
      } catch (e) {
        if (mounted) {
          SFToast.error(context, 'Erro ao atualizar meta de peso');
        }
      }
    }
  }

  Future<void> _editCalorieGoal() async {
    final newGoal = await SFCalorieGoalModal.show(
      context,
      currentGoal: _calorieGoal,
    );

    if (newGoal != null && mounted) {
      try {
        await _nutritionService.updateCalorieGoal(newGoal);
        await _loadUserData();
        if (mounted) {
          SFToast.success(context, 'Meta de calorias atualizada para $newGoal kcal');
        }
      } catch (e) {
        if (mounted) {
          SFToast.error(context, 'Erro ao atualizar meta de calorias');
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      SFToast.error(context, 'Nome é obrigatório');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'full_name': '$firstName $lastName'.trim(),
          },
        ),
      );

      if (mounted) {
        SFToast.success(context, 'Perfil atualizado!');
      }
    } catch (e) {
      if (mounted) {
        SFToast.error(context, 'Erro ao atualizar perfil');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      SFToast.error(context, 'Preencha todos os campos');
      return;
    }

    if (newPassword.length < 6) {
      SFToast.error(context, 'A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (newPassword != confirmPassword) {
      SFToast.error(context, 'As senhas não conferem');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        SFToast.success(context, 'Senha alterada!');
      }
    } catch (e) {
      if (mounted) {
        SFToast.error(context, 'Erro ao alterar senha');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await SFConfirmationDialog.show(
      context,
      title: 'Excluir conta',
      message:
          'Tem certeza que deseja excluir sua conta?\n\nEssa ação é irreversível e todos os seus dados serão perdidos.',
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
        SFToast.error(context, 'Não foi possível excluir a conta. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: SFLoading())
            : Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEditProfileTab(),
                        _buildAccountTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        children: [
          // Botão voltar
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AppColors.textHighContrast,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Título
          Text(
            'Configurações',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.glowOrange,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondaryDark,
        labelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Editar Perfil'),
          Tab(text: 'Conta'),
        ],
      ),
    );
  }

  Widget _buildEditProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Nome
          SFInput(
            label: 'Nome',
            controller: _firstNameController,
            placeholder: 'Seu nome',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          // Sobrenome
          SFInput(
            label: 'Sobrenome',
            controller: _lastNameController,
            placeholder: 'Seu sobrenome',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          // Email (readonly)
          _buildLabel('Email'),
          const SizedBox(height: 8),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppColors.textTertiaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _email,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
                if (_isGoogleLogin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.g_mobiledata_rounded,
                          size: 16,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Google',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Botão salvar perfil
          SFButton(
            variant: SFButtonVariant.primary,
            size: SFButtonSize.lg,
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveProfile,
            child: const Text('Salvar alterações'),
          ),

          // Seção de metas
          const SizedBox(height: 32),

          Container(
            height: 1,
            color: AppColors.borderDark,
          ),

          const SizedBox(height: 28),

          _buildLabel('Minhas Metas'),
          const SizedBox(height: 16),

          // Meta de peso
          _buildGoalTile(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.lime,
            label: 'Meta de peso',
            value: _userProfile?.goalWeight != null
                ? '${_userProfile!.goalWeight!.toStringAsFixed(1)} kg'
                : 'Não definida',
            onTap: _editWeightGoal,
          ),

          const SizedBox(height: 12),

          // Meta de calorias
          _buildGoalTile(
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.primary,
            label: 'Meta de calorias',
            value: '$_calorieGoal kcal/dia',
            onTap: _editCalorieGoal,
          ),

          // Alterar senha (só para login com email)
          if (!_isGoogleLogin) ...[
            const SizedBox(height: 32),

            Container(
              height: 1,
              color: AppColors.borderDark,
            ),

            const SizedBox(height: 28),

            _buildLabel('Alterar Senha'),
            const SizedBox(height: 16),

            SFInput(
              controller: _currentPasswordController,
              placeholder: 'Senha atual',
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 12),

            SFInput(
              controller: _newPasswordController,
              placeholder: 'Nova senha',
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 12),

            SFInput(
              controller: _confirmPasswordController,
              placeholder: 'Confirmar nova senha',
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 20),

            SFButton(
              variant: SFButtonVariant.secondary,
              size: SFButtonSize.lg,
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _changePassword,
              child: const Text('Alterar senha'),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Aviso
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zona de perigo',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As ações abaixo são permanentes e não podem ser desfeitas.',
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
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Botão excluir conta
          SFButton(
            variant: SFButtonVariant.destructive,
            size: SFButtonSize.lg,
            fullWidth: true,
            icon: Icons.delete_outline,
            onPressed: _confirmDeleteAccount,
            child: const Text('Excluir minha conta'),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Ao excluir sua conta, todos os seus dados serão\npermanentemente removidos do sistema.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textSecondaryDark,
      ),
    );
  }

  Widget _buildGoalTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
