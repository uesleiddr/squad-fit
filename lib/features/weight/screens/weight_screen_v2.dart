import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/widgets/v2/v2.dart';

class WeightScreenV2 extends StatefulWidget {
  const WeightScreenV2({super.key});

  @override
  State<WeightScreenV2> createState() => _WeightScreenV2State();
}

class _WeightScreenV2State extends State<WeightScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _weightService = getIt<WeightService>();
  final _userService = getIt<UserService>();
  final _weightController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Key _streamKey = UniqueKey();
  UserModel? _user;
  double? _latestWeight;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _streamKey = UniqueKey();
    });
    await _loadUserData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data da pesagem',
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
              backgroundColor: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final weight = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );

      await _weightService.addWeight(weight, date: _selectedDate);

      if (mounted) {
        SFToast.show(
          context,
          title: 'Peso registrado',
          message: '${weight.toStringAsFixed(1)} kg em ${DateFormatter.format(_selectedDate)}',
          type: SFToastType.success,
        );
        _weightController.clear();
        setState(() {
          _selectedDate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        SFToast.error(context, 'Não foi possível registrar o peso');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editWeightGoal() async {
    final newGoal = await SFWeightGoalModal.show(
      context,
      currentGoal: _user?.goalWeight,
      currentWeight: _latestWeight,
    );

    if (newGoal != null && mounted) {
      try {
        await _userService.updateUser(goalWeight: newGoal);
        await _loadUserData();
        if (mounted) {
          SFToast.success(context, 'Meta atualizada para ${newGoal.toStringAsFixed(1)} kg');
        }
      } catch (e) {
        if (mounted) {
          SFToast.error(context, 'Erro ao atualizar meta');
        }
      }
    }
  }

  Future<void> _deleteWeight(WeightRecordModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir registro',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Deseja excluir o registro de ${record.weight.toStringAsFixed(1)} kg do dia ${DateFormatter.formatWithWeekday(record.date, includeYear: false)}?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          SFButton(
            variant: SFButtonVariant.destructive,
            size: SFButtonSize.sm,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _weightService.deleteWeight(record.id);
        if (mounted) {
          SFToast.success(context, 'Registro excluído');
        }
      } catch (e) {
        if (mounted) {
          SFToast.error(context, 'Não foi possível excluir o registro');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SafeArea(
        child: Stack(
          children: [
            // Background glows
            _buildBackgroundGlows(),

            // Content
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceDark,
              child: CustomScrollView(
                key: _streamKey,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App bar
                  SliverToBoxAdapter(
                    child: _buildAppBar(context),
                  ),

                  // Body
                  SliverPadding(
                    padding: context.screenPadding.copyWith(top: 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Goal card
                          _buildGoalCard(),
                          const SizedBox(height: 16),

                          // Registration form
                          _buildRegistrationForm(),
                          const SizedBox(height: 24),

                          // History section
                          _buildHistorySection(),
                          const SizedBox(height: 100),
                        ],
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

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.lime.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Title
          Text(
            'Peso',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final goalWeight = _user?.goalWeight;
    final hasGoal = goalWeight != null;
    final diff = hasGoal && _latestWeight != null
        ? _latestWeight! - goalWeight
        : null;

    return GestureDetector(
      onTap: _editWeightGoal,
      child: SFCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lime.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.flag_rounded,
                size: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'META DE PESO',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasGoal)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          goalWeight.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kg',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Definir meta',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                ],
              ),
            ),

            // Diff badge or edit icon
            if (diff != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (diff > 0 ? AppColors.lime : AppColors.secondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (diff > 0 ? AppColors.lime : AppColors.secondary)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      diff > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 14,
                      color: diff > 0 ? AppColors.lime : AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${diff.abs().toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: diff > 0 ? AppColors.lime : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textSecondaryDark,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SFCard(
      variant: SFCardVariant.elevated,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          // Glow effect
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppGradients.squad,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.glowBlue,
                      ),
                      child: const Icon(
                        Icons.monitor_weight_outlined,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Registrar Peso',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date selector
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormatter.isToday(_selectedDate)
                                ? 'Hoje'
                                : DateFormatter.formatWithWeekday(_selectedDate),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
                const SizedBox(height: 14),

                // Weight input and button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PESO',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontDisplay,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: '75.5',
                              hintStyle: TextStyle(
                                fontFamily: AppTypography.fontDisplay,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textTertiaryDark,
                              ),
                              suffixText: 'kg',
                              suffixStyle: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondaryDark,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.borderDark),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.borderDark),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.error),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o peso';
                              }
                              final weight =
                                  double.tryParse(value.replaceAll(',', '.'));
                              if (weight == null || weight <= 0 || weight > 500) {
                                return 'Peso inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 27),
                      child: SizedBox(
                        height: 52,
                        child: SFButton(
                          variant: SFButtonVariant.primary,
                          isLoading: _isLoading,
                          onPressed: _saveWeight,
                          child: const Icon(Icons.check, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Histórico',
          action: '',
          onAction: () {},
        ),
        const SizedBox(height: 12),

        StreamBuilder<List<WeightRecordModel>>(
          stream: _weightService.getWeightHistoryStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SFCard(
                padding: const EdgeInsets.all(32),
                child: const LoadingIndicator(),
              );
            }

            if (snapshot.hasError) {
              return SFCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Erro ao carregar histórico',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }

            final records = snapshot.data ?? [];

            // Update latest weight for goal card
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (records.isNotEmpty && _latestWeight != records.first.weight) {
                setState(() {
                  _latestWeight = records.first.weight;
                });
              }
            });

            if (records.isEmpty) {
              return SFCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 48,
                      color: AppColors.textTertiaryDark,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum registro ainda',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registre seu primeiro peso acima!',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: records.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;

                // Calculate difference with previous record
                double? diff;
                if (index < records.length - 1) {
                  diff = record.weight - records[index + 1].weight;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WeightCardV2(
                    record: record,
                    diff: diff,
                    onDelete: () => _deleteWeight(record),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _WeightCardV2 extends StatelessWidget {
  final WeightRecordModel record;
  final double? diff;
  final VoidCallback onDelete;

  const _WeightCardV2({
    required this.record,
    this.diff,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color diffColor = AppColors.textSecondaryDark;
    IconData diffIcon = Icons.remove;
    String diffText = '';

    if (diff != null) {
      if (diff! < 0) {
        diffColor = AppColors.lime;
        diffIcon = Icons.arrow_downward;
        diffText = '${diff!.toStringAsFixed(1)} kg';
      } else if (diff! > 0) {
        diffColor = AppColors.error;
        diffIcon = Icons.arrow_upward;
        diffText = '+${diff!.toStringAsFixed(1)} kg';
      } else {
        diffColor = AppColors.textTertiaryDark;
        diffIcon = Icons.remove;
        diffText = '0 kg';
      }
    }

    return SFCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Weight
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatWithWeekday(record.date, includeYear: false),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ),

          // Difference badge
          if (diff != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: diffColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(diffIcon, size: 14, color: diffColor),
                  const SizedBox(width: 4),
                  Text(
                    diffText,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: diffColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 8),

          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
