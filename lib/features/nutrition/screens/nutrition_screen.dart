import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Tela principal de nutrição com resumo diário
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simula carregamento de dados do backend
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Dados mockados para desenvolvimento
  DailySummary get _mockSummary {
    final now = DateTime.now();

    final breakfastItems = [
      MealItem(
        id: '1',
        mealEntryId: 'entry1',
        name: 'Ovo frito',
        quantity: 2,
        unit: 'unidade',
        calories: 180,
        protein: 12,
        carbs: 1,
        fat: 14,
        createdAt: now,
      ),
      MealItem(
        id: '2',
        mealEntryId: 'entry1',
        name: 'Pão integral',
        quantity: 1,
        unit: 'fatia',
        calories: 76,
        protein: 3,
        carbs: 14,
        fat: 1,
        createdAt: now,
      ),
    ];

    final snackItems = [
      MealItem(
        id: '3',
        mealEntryId: 'entry2',
        name: 'Açaí 500ml',
        quantity: 1,
        unit: 'porção',
        calories: 650,
        protein: 4,
        carbs: 80,
        fat: 30,
        createdAt: now,
      ),
      MealItem(
        id: '4',
        mealEntryId: 'entry2',
        name: 'Banana',
        quantity: 1,
        unit: 'unidade',
        calories: 50,
        protein: 1,
        carbs: 12,
        fat: 0,
        createdAt: now,
      ),
    ];

    final meals = [
      MealEntry(
        id: 'entry1',
        userId: 'user1',
        mealType: MealType.breakfast,
        description: '2 ovos fritos e pão integral',
        totalCalories: 256,
        totalProtein: 15,
        totalCarbs: 15,
        totalFat: 15,
        items: breakfastItems,
        recordedAt: _selectedDate,
        createdAt: _selectedDate,
      ),
      MealEntry(
        id: 'entry2',
        userId: 'user1',
        mealType: MealType.snack,
        description: 'Açaí com banana',
        totalCalories: 700,
        totalProtein: 5,
        totalCarbs: 92,
        totalFat: 30,
        items: snackItems,
        recordedAt: _selectedDate,
        createdAt: _selectedDate,
      ),
    ];

    return DailySummary(
      date: _selectedDate,
      totalCalories: 956,
      calorieGoal: 2000,
      totalProtein: 20,
      totalCarbs: 107,
      totalFat: 45,
      meals: meals,
    );
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onMealAdded(MealEntry? result) {
    if (result != null && mounted) {
      // TODO: Salvar no banco e atualizar estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refeição adicionada: ${result.description}')),
      );
    }
  }

  List<MealItem> _getItemsForMealType(MealType type) {
    final entry = _mockSummary.meals.where((m) => m.mealType == type).toList();

    if (entry.isEmpty) return [];
    return entry.first.items;
  }

  int _getCaloriesForMealType(MealType type) {
    final entry = _mockSummary.meals.where((m) => m.mealType == type).toList();

    if (entry.isEmpty) return 0;
    return entry.first.totalCalories;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _mockSummary;

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
      body: SingleChildScrollView(
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
                            // TODO: Expandir ou navegar para detalhes
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
