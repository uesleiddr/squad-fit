import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Tela principal de nutrição com resumo diário
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _nutritionService = getIt<NutritionService>();

  DateTime _selectedDate = DateTime.now();
  DailySummary? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _nutritionService.getDailySummary(_selectedDate);
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadData();
  }

  void _onMealAdded(MealEntry? result) {
    if (result != null && mounted) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refeição adicionada: ${result.description}')),
      );
    }
  }

  List<MealItem> _getItemsForMealType(MealType type) {
    if (_summary == null) return [];
    final entry = _summary!.meals.where((m) => m.mealType == type).toList();
    if (entry.isEmpty) return [];
    return entry.first.items;
  }

  int _getCaloriesForMealType(MealType type) {
    if (_summary == null) return 0;
    final entry = _summary!.meals.where((m) => m.mealType == type).toList();
    if (entry.isEmpty) return 0;
    return entry.first.totalCalories;
  }

  MealEntry? _getMealEntryForType(MealType type) {
    if (_summary == null) return null;
    final entries = _summary!.meals.where((m) => m.mealType == type).toList();
    if (entries.isEmpty) return null;
    return entries.first;
  }

  Future<void> _deleteMealEntry(MealEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir refeição?'),
        content: Text('Deseja excluir "${entry.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _nutritionService.deleteMealEntry(entry.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refeição excluída')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  void _showMealOptions(MealEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Excluir refeição'),
              onTap: () {
                Navigator.pop(context);
                _deleteMealEntry(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary ?? DailySummary(date: _selectedDate);

    return LoadingScaffold(
      isLoading: _isLoading,
      appBar: AppBar(
        title: const Text('Diário'),
        actions: [
          DateSelector(
            selectedDate: _selectedDate,
            onDateChanged: _onDateChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AddMealFab(
        onMealAdded: _onMealAdded,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar dados'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progresso circular de calorias
            Padding(
              padding: const EdgeInsets.all(16),
              child: CircularCalorieProgress(
                consumed: summary.totalCalories,
                goal: summary.calorieGoal,
              ),
            ),

            // Card com todas as refeições
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: MealType.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final type = entry.value;
                    final isLast = index == MealType.values.length - 1;

                    return Column(
                      children: [
                        MealSection(
                          mealType: type,
                          items: _getItemsForMealType(type),
                          totalCalories: _getCaloriesForMealType(type),
                          onTap: () {
                            final entry = _getMealEntryForType(type);
                            if (entry != null) {
                              _showMealOptions(entry);
                            }
                          },
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
