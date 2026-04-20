import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';

class EditCalorieGoalModal extends StatefulWidget {
  final int currentGoal;

  const EditCalorieGoalModal({super.key, required this.currentGoal});

  static Future<bool?> show(BuildContext context, int currentGoal) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCalorieGoalModal(currentGoal: currentGoal),
    );
  }

  @override
  State<EditCalorieGoalModal> createState() => _EditCalorieGoalModalState();
}

class _EditCalorieGoalModalState extends State<EditCalorieGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _userService = getIt<UserService>();
  late TextEditingController _calorieController;
  bool _isLoading = false;

  // Presets comuns
  static const _presets = [1500, 1800, 2000, 2200, 2500, 3000];

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController(
      text: widget.currentGoal.toString(),
    );
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  void _selectPreset(int value) {
    setState(() {
      _calorieController.text = value.toString();
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final goal = int.parse(_calorieController.text);
      await _userService.updateCalorieGoal(goal);

      if (mounted) {
        Navigator.pop(context, true);
        SnackBarHelper.showSuccess(context, 'Meta de calorias atualizada!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Nao foi possivel atualizar a meta. Tente novamente.',
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
    final colorScheme = Theme.of(context).colorScheme;
    final currentValue = int.tryParse(_calorieController.text) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.modal,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Meta de Calorias',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Defina sua meta diaria de calorias',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Campo de calorias
              TextFormField(
                controller: _calorieController,
                decoration: InputDecoration(
                  labelText: 'Calorias por dia',
                  suffixText: 'kcal',
                  prefixIcon: const Icon(Icons.local_fire_department_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a meta';
                  }
                  final calories = int.tryParse(value);
                  if (calories == null || calories < 500 || calories > 10000) {
                    return 'Informe um valor entre 500 e 10000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Presets
              Text(
                'Valores sugeridos:',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  final isSelected = currentValue == preset;
                  return ChoiceChip(
                    label: Text('$preset'),
                    selected: isSelected,
                    onSelected: (_) => _selectPreset(preset),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botoes
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
