import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/v2/v2.dart';

/// Modal V2 para criar um novo desafio/squad
class CreateCompetitionModalV2 extends StatefulWidget {
  const CreateCompetitionModalV2({super.key});

  /// Mostra o modal e retorna a competição criada ou null se cancelado
  static Future<CompetitionModel?> show(BuildContext context) {
    return showModalBottomSheet<CompetitionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCompetitionModalV2(),
    );
  }

  @override
  State<CreateCompetitionModalV2> createState() =>
      _CreateCompetitionModalV2State();
}

class _CreateCompetitionModalV2State extends State<CreateCompetitionModalV2> {
  final _competitionService = getIt<CompetitionService>();
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  int _selectedGradientIndex = 0;
  DateTime? _endDate;
  VictoryRule? _selectedRule;
  bool _isLoading = false;

  final List<List<Color>> _gradients = [
    [const Color(0xFFFA8038), const Color(0xFFFF3B8B)],
    [const Color(0xFF6366F1), const Color(0xFF256AD2)],
    [const Color(0xFF22C55E), const Color(0xFFD6FF3B)],
    [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    [const Color(0xFF8B5CF6), const Color(0xFFFF3B8B)],
    [const Color(0xFF0EA5E9), const Color(0xFF6366F1)],
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '??';

    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _autoTag {
    final name = _nameController.text.trim().toLowerCase();
    return name
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  Future<void> _selectEndDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data de término',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface2,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _createCompetition() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      SnackBarHelper.showError(context, 'Informe o nome do desafio');
      return;
    }

    if (name.length < 3) {
      SnackBarHelper.showError(context, 'Nome muito curto');
      return;
    }

    if (_endDate == null) {
      SnackBarHelper.showError(context, 'Selecione a data de término');
      return;
    }

    if (_selectedRule == null) {
      SnackBarHelper.showError(context, 'Selecione a regra de vitória');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final competition = await _competitionService.createCompetition(
        name: name,
        description: null,
        startDate: DateTime.now(),
        endDate: _endDate!,
        victoryRule: _selectedRule!,
      );

      if (mounted) {
        Navigator.pop(context, competition);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Não foi possível criar o desafio. Tente novamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardPadding = mediaQuery.viewInsets.bottom;
    final systemNavPadding = mediaQuery.viewPadding.bottom;
    final bottomPadding = keyboardPadding > 0 ? keyboardPadding : systemNavPadding;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Avatar picker
                  _buildAvatarPicker(),
                  const SizedBox(height: 16),

                  // Gradient swatches
                  _buildGradientSwatches(),
                  const SizedBox(height: 20),

                  // Name input
                  _buildNameInput(),
                  const SizedBox(height: 20),

                  // End date
                  _buildEndDatePicker(),
                  const SizedBox(height: 20),

                  // Victory rule
                  _buildVictoryRules(),
                  const SizedBox(height: 16),

                  // Tip card
                  _buildTipCard(),
                  const SizedBox(height: 16),

                  // Create button
                  SFButton(
                    variant: SFButtonVariant.primary,
                    size: SFButtonSize.lg,
                    fullWidth: true,
                    iconRight: Icons.arrow_forward,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _createCompetition,
                    child: const Text('Criar desafio'),
                  ),

                  const SizedBox(height: 10),

                  // Cancel
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'NOVO DESAFIO',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bora criar um desafio',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Você vira líder e pode convidar até 19 amigos',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _gradients[_selectedGradientIndex],
    );

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _gradients[_selectedGradientIndex][0]
                      .withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.surfaceDark,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_camera,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientSwatches() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_gradients.length, (index) {
        final isSelected = _selectedGradientIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedGradientIndex = index),
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradients[index],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 0,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNameInput() {
    final hasFocus = _nameFocus.hasFocus;
    final hasText = _nameController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOME DO DESAFIO',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFocus || hasText
                  ? AppColors.primary
                  : AppColors.borderDark,
              width: hasFocus || hasText ? 1.5 : 1,
            ),
            boxShadow: hasFocus || hasText
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                    ...AppShadows.insetHighlight,
                  ]
                : AppShadows.insetHighlight,
          ),
          child: Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: hasFocus || hasText
                    ? AppColors.primary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Desafio Verão 2026',
                    hintStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiaryDark,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              Text(
                '${_nameController.text.length}/30',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
        if (_nameController.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Tag automática: @$_autoTag',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEndDatePicker() {
    final hasDate = _endDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA DE TÉRMINO',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectEndDate,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasDate ? AppColors.primary : AppColors.borderDark,
                width: hasDate ? 1.5 : 1,
              ),
              boxShadow: AppShadows.insetHighlight,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: hasDate
                      ? AppColors.primary
                      : AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasDate
                        ? _formatDate(_endDate!)
                        : 'Selecione a data',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.w500,
                      color: hasDate
                          ? Colors.white
                          : AppColors.textTertiaryDark,
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
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Widget _buildVictoryRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REGRA DE VITÓRIA',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 8),
        _buildRuleOption(
          rule: VictoryRule.percentageLoss,
          title: 'Percentual Perdido',
          description: 'Vence quem perder maior % do peso inicial',
          icon: Icons.percent,
        ),
        const SizedBox(height: 8),
        _buildRuleOption(
          rule: VictoryRule.totalWeightLoss,
          title: 'Perda Total de Peso',
          description: 'Vence quem perder mais quilos',
          icon: Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildRuleOption({
    required VictoryRule rule,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRule == rule;

    return GestureDetector(
      onTap: () => setState(() => _selectedRule = rule),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: AppShadows.insetHighlight,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textTertiaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lime.withValues(alpha: 0.08),
            AppColors.success.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb,
              size: 16,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Depois de criar, você pode convidar amigos para participar do desafio.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
