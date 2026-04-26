import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/design_system.dart';
import 'sf_button.dart';
import 'sf_modal_shell.dart';

/// Modal para editar meta de peso
class SFWeightGoalModal extends StatefulWidget {
  final double? currentGoal;
  final double? currentWeight;

  const SFWeightGoalModal({
    super.key,
    this.currentGoal,
    this.currentWeight,
  });

  /// Mostra o modal e retorna o novo valor da meta (ou null se cancelado)
  static Future<double?> show(
    BuildContext context, {
    double? currentGoal,
    double? currentWeight,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SFWeightGoalModal(
        currentGoal: currentGoal,
        currentWeight: currentWeight,
      ),
    );
  }

  @override
  State<SFWeightGoalModal> createState() => _SFWeightGoalModalState();
}

class _SFWeightGoalModalState extends State<SFWeightGoalModal> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentGoal?.toStringAsFixed(1) ?? '',
    );
    _validateInput();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    setState(() {
      _isValid = value != null && value > 0 && value < 500;
    });
  }

  void _save() {
    if (!_isValid) return;
    final value = double.parse(_controller.text.replaceAll(',', '.'));
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.currentWeight != null && widget.currentGoal != null
        ? widget.currentWeight! - widget.currentGoal!
        : null;

    return SFModalShell(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  'Meta de Peso',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Defina seu peso objetivo',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Current weight info
          if (widget.currentWeight != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peso atual',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                        Text(
                          '${widget.currentWeight!.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (diff != null && widget.currentGoal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (diff > 0 ? AppColors.lime : AppColors.secondary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (diff > 0 ? AppColors.lime : AppColors.secondary)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        diff > 0
                            ? '${diff.toStringAsFixed(1)} kg a perder'
                            : '${diff.abs().toStringAsFixed(1)} kg a ganhar',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: diff > 0 ? AppColors.lime : AppColors.secondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Input label
          Text(
            'NOVA META',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 10),

          // Input field
          TextFormField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            textAlign: TextAlign.center,
            autofocus: true,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '70.0',
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textTertiaryDark,
              ),
              suffixText: 'kg',
              suffixStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Helper text
          Text(
            'Informe um peso entre 20 e 500 kg',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: AppColors.textTertiaryDark,
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.outline,
                  size: SFButtonSize.lg,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.primary,
                  size: SFButtonSize.lg,
                  onPressed: _isValid ? _save : null,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal para editar meta de calorias
class SFCalorieGoalModal extends StatefulWidget {
  final int currentGoal;

  const SFCalorieGoalModal({
    super.key,
    required this.currentGoal,
  });

  /// Mostra o modal e retorna o novo valor da meta (ou null se cancelado)
  static Future<int?> show(
    BuildContext context, {
    required int currentGoal,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SFCalorieGoalModal(currentGoal: currentGoal),
    );
  }

  @override
  State<SFCalorieGoalModal> createState() => _SFCalorieGoalModalState();
}

class _SFCalorieGoalModalState extends State<SFCalorieGoalModal> {
  late TextEditingController _controller;
  bool _isValid = false;
  int? _selectedPreset;

  // Presets comuns
  static const _presets = [
    {'label': 'Perda de peso', 'value': 1500, 'icon': Icons.trending_down},
    {'label': 'Manutenção', 'value': 2000, 'icon': Icons.balance},
    {'label': 'Ganho de massa', 'value': 2500, 'icon': Icons.trending_up},
    {'label': 'Bulking', 'value': 3000, 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentGoal.toString(),
    );
    _validateInput();
    _controller.addListener(_validateInput);

    // Check if current goal matches a preset
    for (int i = 0; i < _presets.length; i++) {
      if (_presets[i]['value'] == widget.currentGoal) {
        _selectedPreset = i;
        break;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final value = int.tryParse(_controller.text);
    setState(() {
      _isValid = value != null && value >= 500 && value <= 10000;
    });
  }

  void _selectPreset(int index) {
    final value = _presets[index]['value'] as int;
    setState(() {
      _selectedPreset = index;
      _controller.text = value.toString();
    });
  }

  void _save() {
    if (!_isValid) return;
    final value = int.parse(_controller.text);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return SFModalShell(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  'Meta de Calorias',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Defina sua meta diária',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Presets
          Text(
            'SUGESTÕES',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_presets.length, (index) {
              final preset = _presets[index];
              final isSelected = _selectedPreset == index;

              return GestureDetector(
                onTap: () => _selectPreset(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.primary : null,
                    color: isSelected ? null : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.borderDark),
                    boxShadow: isSelected ? AppShadows.glowOrange : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        preset['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset['label'] as String,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textHighContrast,
                            ),
                          ),
                          Text(
                            '${preset['value']} kcal',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.textTertiaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Custom input
          Text(
            'OU DEFINA MANUALMENTE',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            onChanged: (value) {
              // Clear preset selection when manually typing
              setState(() {
                _selectedPreset = null;
                for (int i = 0; i < _presets.length; i++) {
                  if (_presets[i]['value'].toString() == value) {
                    _selectedPreset = i;
                    break;
                  }
                }
              });
            },
            decoration: InputDecoration(
              hintText: '2000',
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textTertiaryDark,
              ),
              suffixText: 'kcal',
              suffixStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Informe um valor entre 500 e 10.000 kcal',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: AppColors.textTertiaryDark,
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.outline,
                  size: SFButtonSize.lg,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SFButton(
                  variant: SFButtonVariant.primary,
                  size: SFButtonSize.lg,
                  onPressed: _isValid ? _save : null,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
