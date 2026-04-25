import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Tela principal de nutrição com resumo diário - Versão V2
class NutritionScreenV2 extends StatefulWidget {
  const NutritionScreenV2({super.key});

  @override
  State<NutritionScreenV2> createState() => _NutritionScreenV2State();
}

class _NutritionScreenV2State extends State<NutritionScreenV2> {
  final _nutritionService = getIt<NutritionService>();

  DateTime _selectedDate = DateTime.now();
  DailySummary? _summary;
  bool _isLoading = true;
  String? _error;

  // Para scroll horizontal de datas
  late List<DateTime> _weekDates;
  int _selectedDateIndex = 3; // Hoje no centro

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    _loadData();
  }

  void _generateWeekDates() {
    final today = DateTime.now();
    _weekDates = List.generate(7, (i) {
      return today.subtract(Duration(days: 3 - i));
    });
    _selectedDateIndex = 3;
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

  void _onDateSelected(int index) {
    setState(() {
      _selectedDateIndex = index;
      _selectedDate = _weekDates[index];
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

  Future<void> _openAddMealScreen(MealType mealType) async {
    final result = await AddMealModalV2.show(context, mealType: mealType);
    _onMealAdded(result);
  }

  List<MealItem> _getItemsForMealType(MealType type) {
    if (_summary == null) return [];
    final entries = _summary!.meals.where((m) => m.mealType == type).toList();
    if (entries.isEmpty) return [];
    return entries.expand((e) => e.items).toList();
  }

  int _getCaloriesForMealType(MealType type) {
    if (_summary == null) return 0;
    final entries = _summary!.meals.where((m) => m.mealType == type).toList();
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, e) => sum + e.totalCalories);
  }

  List<MealEntry> _getMealEntriesForType(MealType type) {
    if (_summary == null) return [];
    return _summary!.meals.where((m) => m.mealType == type).toList();
  }

  Future<void> _deleteMealEntry(MealEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir refeição?',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Deseja excluir "${entry.description}"?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondaryDark)),
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
      backgroundColor: AppColors.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDarkStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Excluir refeição',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                entry.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
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

  void _showMealSelectionDialog(List<MealEntry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDarkStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecione a refeição',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            ...entries.map((entry) => ListTile(
                  leading: Icon(Icons.restaurant,
                      color: AppColors.textSecondaryDark),
                  title: Text(
                    entry.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text('${entry.totalCalories} kcal',
                      style: TextStyle(color: AppColors.textSecondaryDark)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteMealEntry(entry);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary ?? DailySummary(date: _selectedDate);

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SafeArea(
            child: _isLoading
                ? const LoadingIndicator()
                : _error != null
                    ? _buildErrorState()
                    : CustomScrollView(
                        slivers: [
                          // Header
                          SliverToBoxAdapter(child: _buildHeader()),

                          // Date selector
                          SliverToBoxAdapter(child: _buildDateStrip()),

                          // Content
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                // Hero card with calorie ring
                                _buildHeroCard(summary),
                                const SizedBox(height: 16),

                                // Meal sections
                                ...MealType.values.map((type) =>
                                    _buildMealCard(type)),

                                const SizedBox(height: 100),
                              ]),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildHeader() {
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final monthNames = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    final dateStr =
        '${dayNames[_selectedDate.weekday % 7]}, ${_selectedDate.day} ${monthNames[_selectedDate.month - 1]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Diário',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              SnackBarHelper.showInfo(
                context,
                'Filtros em desenvolvimento',
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.tune,
                size: 20,
                color: AppColors.textHighContrast,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _weekDates.length,
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final date = _weekDates[index];
            final isSelected = index == _selectedDateIndex;
            final isToday = date.day == today.day &&
                date.month == today.month &&
                date.year == today.year;

            return GestureDetector(
              onTap: () => _onDateSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected ? null : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.borderDark),
                  boxShadow: isSelected ? AppShadows.glowOrange : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Hoje' : dayNames[date.weekday % 7],
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textHighContrast,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (isToday && !isSelected) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(DailySummary summary) {
    final consumed = summary.totalCalories;
    final goal = summary.calorieGoal;
    final remaining = goal - consumed;
    final progress = goal > 0 ? (consumed / goal * 100).clamp(0.0, 100.0) : 0.0;

    final protein = summary.totalProtein;
    final carbs = summary.totalCarbs;
    final fat = summary.totalFat;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface2, AppColors.surfaceDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow laranja no canto superior direito
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Ring and stats
              Row(
                children: [
                  ProgressRing(
                    value: progress,
                    size: 130,
                    label: 'de $goal',
                    bigLabel: '$consumed',
                    strokeWidth: 10,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          'Restante',
                          '${remaining.abs()}',
                          'kcal',
                          remaining >= 0 ? AppColors.lime : AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Macros row
              Row(
                children: [
                  _buildMacroCard('Proteína', protein.toInt(), AppColors.protein),
                  const SizedBox(width: 8),
                  _buildMacroCard('Carbs', carbs.toInt(), AppColors.carbs),
                  const SizedBox(width: 8),
                  _buildMacroCard('Gordura', fat.toInt(), AppColors.fat),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'g',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MealType mealType) {
    final items = _getItemsForMealType(mealType);
    final calories = _getCaloriesForMealType(mealType);
    final entries = _getMealEntriesForType(mealType);
    final color = _getMealColor(mealType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SFCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      mealType.icon,
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items.isEmpty
                              ? 'Nenhum registro'
                              : '${items.length} ${items.length == 1 ? 'item' : 'itens'}',
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        calories > 0 ? '$calories' : '—',
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: calories > 0
                              ? Colors.white
                              : AppColors.textTertiaryDark,
                        ),
                      ),
                      Text(
                        'KCAL',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items
            if (items.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderDark),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    if (entries.length == 1) {
                      _showMealOptions(entries.first);
                    } else if (entries.length > 1) {
                      _showMealSelectionDialog(entries);
                    }
                  },
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Container(
                        decoration: BoxDecoration(
                          border: index > 0
                              ? Border(
                                  top: BorderSide(color: AppColors.borderDark),
                                )
                              : null,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textHighContrast,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${item.quantity} ${item.unit}',
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
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: AppTypography.fontDisplay,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondaryDark,
                                ),
                                children: [
                                  TextSpan(text: '${item.calories}'),
                                  TextSpan(
                                    text: ' kcal',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textTertiaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Add button
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark),
                ),
              ),
              child: InkWell(
                onTap: () => _openAddMealScreen(mealType),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ADICIONAR ALIMENTO',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppColors.warning;
      case MealType.lunch:
        return AppColors.success;
      case MealType.snack:
        return AppColors.magenta;
      case MealType.dinner:
        return const Color(0xFF6366F1);
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textTertiaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          SFButton(
            variant: SFButtonVariant.primary,
            onPressed: _loadData,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
