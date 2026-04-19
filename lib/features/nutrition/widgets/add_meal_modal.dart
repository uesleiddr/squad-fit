import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'food_quantity_modal.dart';
import 'food_search_field.dart';

/// FAB com transição Container Transform para adicionar refeição
class AddMealFab extends StatelessWidget {
  final void Function(MealEntry?)? onMealAdded;

  const AddMealFab({super.key, this.onMealAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OpenContainer<MealEntry>(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 400),
      openBuilder: (context, closeContainer) {
        return AddMealScreen(onClose: closeContainer);
      },
      closedElevation: 6,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      closedColor: colorScheme.primaryContainer,
      closedBuilder: (context, openContainer) {
        return FloatingActionButton(
          onPressed: openContainer,
          elevation: 0,
          child: const Icon(Icons.add),
        );
      },
      onClosed: onMealAdded,
    );
  }
}

/// Tela de adicionar refeição (usada com Container Transform)
class AddMealScreen extends StatefulWidget {
  final void Function({MealEntry? returnValue}) onClose;
  final MealType? initialMealType;

  const AddMealScreen({
    super.key,
    required this.onClose,
    this.initialMealType,
  });

  /// Abre a tela como modal (Navigator.push)
  static Future<MealEntry?> open(BuildContext context, {MealType? mealType}) {
    return Navigator.of(context).push<MealEntry>(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          onClose: ({MealEntry? returnValue}) => Navigator.of(context).pop(returnValue),
          initialMealType: mealType,
        ),
      ),
    );
  }

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _nutritionService = getIt<NutritionService>();
  MealType _selectedMealType = MealType.breakfast;
  final List<FoodWithQuantity> _selectedFoods = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? _suggestMealType();
  }

  MealType _suggestMealType() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return MealType.breakfast;
    } else if (hour >= 10 && hour < 14) {
      return MealType.lunch;
    } else if (hour >= 14 && hour < 18) {
      return MealType.snack;
    } else {
      return MealType.dinner;
    }
  }

  Future<void> _onFoodSelected(BrazilianFood food) async {
    final result = await FoodQuantityModal.show(context, food);
    if (result != null) {
      setState(() => _selectedFoods.add(result));
    }
  }

  void _removeFood(int index) {
    setState(() => _selectedFoods.removeAt(index));
  }

  Future<void> _submitMeal() async {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um alimento')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final description = _selectedFoods.map((f) => f.name).join(', ');

      final items = _selectedFoods.asMap().entries.map((entry) {
        return MealItem(
          id: '',
          mealEntryId: '',
          name: entry.value.name,
          quantity: entry.value.quantity,
          unit: entry.value.unit,
          calories: entry.value.calories.round(),
          protein: entry.value.protein,
          carbs: entry.value.carbs,
          fat: entry.value.fat,
          createdAt: now,
        );
      }).toList();

      final savedEntry = await _nutritionService.saveMealEntry(
        mealType: _selectedMealType,
        description: description,
        items: items,
      );

      widget.onClose(returnValue: savedEntry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  double get _totalCalories =>
      _selectedFoods.fold<double>(0, (sum, f) => sum + f.calories);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => widget.onClose(),
        ),
        title: Text(
          'Adicionar Refeição',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tipo de refeição
                  Text(
                    'Tipo de Refeição',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Chips de seleção
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MealType.values.map((type) {
                      final isSelected = type == _selectedMealType;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon, size: 18),
                            const SizedBox(width: 6),
                            Text(type.label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedMealType = type);
                        },
                        selectedColor: colorScheme.secondaryContainer,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Campo de busca
                  Text(
                    'Buscar Alimento',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  FoodSearchField(
                    onFoodSelected: _onFoodSelected,
                    hintText: 'Digite o nome do alimento...',
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Lista de alimentos selecionados
                  if (_selectedFoods.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alimentos (${_selectedFoods.length})',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_totalCalories.toStringAsFixed(0)} kcal',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    ...List.generate(_selectedFoods.length, (index) {
                      final food = _selectedFoods[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${food.quantity} ${food.unit} • ${food.calories.toStringAsFixed(0)} kcal',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: colorScheme.error,
                            onPressed: () => _removeFood(index),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Botão de registrar (fixo no bottom)
          if (_selectedFoods.isNotEmpty)
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitMeal,
                    child: _isSaving
                        ? const ButtonLoadingIndicator()
                        : Text(
                            'Registrar Refeição (${_totalCalories.toStringAsFixed(0)} kcal)',
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modal para adicionar uma nova refeição (versão bottom sheet - deprecated)
@Deprecated('Use AddMealFab com Container Transform')
class AddMealModal extends StatefulWidget {
  const AddMealModal({super.key});

  /// Método estático para exibir o modal
  static Future<MealEntry?> show(BuildContext context) {
    return showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMealModal(),
    );
  }

  @override
  State<AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends State<AddMealModal> {
  final _descriptionController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _suggestMealType();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Sugere o tipo de refeição com base no horário atual
  MealType _suggestMealType() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return MealType.breakfast;
    } else if (hour >= 10 && hour < 14) {
      return MealType.lunch;
    } else if (hour >= 14 && hour < 18) {
      return MealType.snack;
    } else {
      return MealType.dinner;
    }
  }

  Future<void> _submitMeal() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva o que você comeu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Integrar com Gemini + FatSecret
      // Por enquanto, retorna um MealEntry mockado
      await Future.delayed(const Duration(seconds: 1)); // Simula processamento

      final now = DateTime.now();
      final mockEntry = MealEntry(
        id: 'mock_${now.millisecondsSinceEpoch}',
        userId: 'user1',
        mealType: _selectedMealType,
        description: description,
        totalCalories: 300, // Mock
        totalProtein: 15,
        totalCarbs: 30,
        totalFat: 10,
        items: [
          MealItem(
            id: 'item_${now.millisecondsSinceEpoch}',
            mealEntryId: 'mock_${now.millisecondsSinceEpoch}',
            name: description,
            quantity: 1,
            calories: 300,
            createdAt: now,
          ),
        ],
        recordedAt: now,
        createdAt: now,
      );

      if (mounted) {
        Navigator.of(context).pop(mockEntry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar: $e')),
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
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.modal,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle do modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Adicionar Refeição',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Tipo de refeição
            Text(
              'Tipo de Refeição',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Chips de seleção
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((type) {
                final isSelected = type == _selectedMealType;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 18),
                      const SizedBox(width: 6),
                      Text(type.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedMealType = type);
                  },
                  selectedColor: colorScheme.secondaryContainer,
                  backgroundColor: colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Campo de descrição
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Descreva o que você comeu...\nEx: 2 ovos fritos com pão integral',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de registrar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMeal,
                child: _isLoading
                    ? const ButtonLoadingIndicator()
                    : const Text('Registrar Refeição'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
