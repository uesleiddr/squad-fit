import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/v2/v2.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Modal V2 para adicionar alimento a uma refeição
class AddMealModalV2 extends StatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;
  final void Function(MealEntry entry)? onMealAdded;

  const AddMealModalV2({
    super.key,
    required this.mealType,
    required this.selectedDate,
    this.onMealAdded,
  });

  /// Abre o modal e retorna o MealEntry criado
  static Future<MealEntry?> show(
    BuildContext context, {
    required MealType mealType,
    required DateTime selectedDate,
  }) {
    return showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMealModalV2(
        mealType: mealType,
        selectedDate: selectedDate,
      ),
    );
  }

  @override
  State<AddMealModalV2> createState() => _AddMealModalV2State();
}

/// Item de alimento selecionado com quantidade
class _SelectedFoodItem {
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const _SelectedFoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _AddMealModalV2State extends State<AddMealModalV2> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _ragService = getIt<RagFoodSearchService>();
  final _nutritionService = getIt<NutritionService>();
  final _supabase = Supabase.instance.client;

  List<BrazilianFood> _searchResults = [];
  List<_RecentFood> _recentFoods = [];
  final List<_SelectedFoodItem> _selectedItems = []; // Lista de itens selecionados

  // Estado para edição de quantidade (alimento sendo editado)
  BrazilianFood? _editingFood;
  _RecentFood? _editingRecentFood;
  int _quantity = 100;
  String _unit = 'g';

  bool _isSearching = false;
  bool _isSaving = false;
  bool _isLoadingRecent = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRecentFoods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Carrega alimentos usados recentemente pelo usuário
  Future<void> _loadRecentFoods() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoadingRecent = false);
      return;
    }

    try {
      final response = await _supabase
          .from('meal_items')
          .select('name, calories, protein, carbs, fat, unit')
          .order('created_at', ascending: false)
          .limit(20);

      final Map<String, _RecentFood> uniqueFoods = {};
      for (final json in response) {
        final name = json['name'] as String;
        if (!uniqueFoods.containsKey(name)) {
          uniqueFoods[name] = _RecentFood(
            name: name,
            calories: ((json['calories'] ?? 0) as num).toDouble(),
            protein: ((json['protein'] ?? 0) as num).toDouble(),
            carbs: ((json['carbs'] ?? 0) as num).toDouble(),
            fat: ((json['fat'] ?? 0) as num).toDouble(),
            unit: json['unit'] ?? 'g',
          );
        }
        if (uniqueFoods.length >= 6) break;
      }

      if (mounted) {
        setState(() {
          _recentFoods = uniqueFoods.values.toList();
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecent = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchFoods(query);
    });
  }

  Future<void> _searchFoods(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _ragService.search(query, limit: 10);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  /// Inicia edição de quantidade para um alimento da busca
  void _startEditingFood(BrazilianFood food) {
    setState(() {
      _editingFood = food;
      _editingRecentFood = null;
      _quantity = 100;
      // Define a unidade baseado no tipo de alimento (ml para bebidas, g para sólidos)
      _unit = food.isBeverage ? 'ml' : 'g';
    });
  }

  /// Inicia edição de quantidade para um alimento recente
  void _startEditingRecentFood(_RecentFood food) {
    setState(() {
      _editingRecentFood = food;
      _editingFood = null;
      _quantity = 100;
      _unit = food.unit;
    });
  }

  /// Adiciona o alimento com a quantidade selecionada à lista
  void _confirmAddFood() {
    if (_editingFood == null && _editingRecentFood == null) return;

    final item = _SelectedFoodItem(
      name: _editingFood?.name ?? _editingRecentFood!.name,
      quantity: _quantity.toDouble(),
      unit: _unit,
      calories: _currentCalories.round(),
      protein: _currentProtein,
      carbs: _currentCarbs,
      fat: _currentFat,
    );

    setState(() {
      _selectedItems.add(item);
      _editingFood = null;
      _editingRecentFood = null;
      _searchController.clear();
      _searchResults = [];
    });

    _focusNode.requestFocus();
  }

  /// Cancela a edição de quantidade
  void _cancelEditing() {
    setState(() {
      _editingFood = null;
      _editingRecentFood = null;
    });
    _focusNode.requestFocus();
  }

  /// Remove um item da lista
  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _incrementQuantity() {
    setState(() => _quantity += 10);
  }

  void _decrementQuantity() {
    if (_quantity > 10) {
      setState(() => _quantity -= 10);
    }
  }

  void _setUnit(String unit, int? defaultQty) {
    setState(() {
      _unit = unit;
      if (defaultQty != null) {
        _quantity = defaultQty;
      }
    });
  }

  /// Retorna os chips de unidade baseado no tipo de alimento (bebida ou sólido)
  List<Widget> _buildUnitChips() {
    final isBeverage = _editingFood?.isBeverage ?? false;

    if (isBeverage) {
      // Unidades para bebidas
      return [
        _buildUnitChip('ml', null),
        const SizedBox(width: 6),
        _buildUnitChip('copo', 200),
        const SizedBox(width: 6),
        _buildUnitChip('xícara', 240),
        const SizedBox(width: 6),
        _buildUnitChip('colher', 15),
      ];
    } else {
      // Unidades para sólidos
      return [
        _buildUnitChip('g', null),
        const SizedBox(width: 6),
        _buildUnitChip('porção', 100),
        const SizedBox(width: 6),
        _buildUnitChip('fatia', 25),
        const SizedBox(width: 6),
        _buildUnitChip('colher', 15),
      ];
    }
  }

  // Getters para o alimento sendo editado
  double get _baseCalories => _editingFood?.calories ?? _editingRecentFood?.calories ?? 0;
  double get _baseProtein => _editingFood?.protein ?? _editingRecentFood?.protein ?? 0;
  double get _baseCarbs => _editingFood?.carbs ?? _editingRecentFood?.carbs ?? 0;
  double get _baseFat => _editingFood?.fat ?? _editingRecentFood?.fat ?? 0;

  double get _currentCalories => _baseCalories * _quantity / 100;
  double get _currentProtein => _baseProtein * _quantity / 100;
  double get _currentCarbs => _baseCarbs * _quantity / 100;
  double get _currentFat => _baseFat * _quantity / 100;

  String get _editingFoodName => _editingFood?.name ?? _editingRecentFood?.name ?? '';
  bool get _isEditing => _editingFood != null || _editingRecentFood != null;

  // Totais da lista de itens selecionados
  int get _totalCalories => _selectedItems.fold(0, (sum, item) => sum + item.calories);
  double get _totalProtein => _selectedItems.fold(0.0, (sum, item) => sum + item.protein);
  double get _totalCarbs => _selectedItems.fold(0.0, (sum, item) => sum + item.carbs);
  double get _totalFat => _selectedItems.fold(0.0, (sum, item) => sum + item.fat);

  Future<void> _saveMeal() async {
    if (_selectedItems.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Usa a data selecionada, mantendo a hora atual
      final now = DateTime.now();
      final recordedAt = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );
      final description = _selectedItems.map((f) => f.name).join(', ');

      final items = _selectedItems.map((item) {
        return MealItem(
          id: '',
          mealEntryId: '',
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          createdAt: recordedAt,
        );
      }).toList();

      final savedEntry = await _nutritionService.saveMealEntry(
        mealType: widget.mealType,
        description: description,
        items: items,
        recordedAt: recordedAt,
      );

      if (mounted) {
        Navigator.of(context).pop(savedEntry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  String _inferCategory(BrazilianFood food) {
    final nameLower = food.name.toLowerCase();

    if (nameLower.contains('frango') ||
        nameLower.contains('carne') ||
        nameLower.contains('boi') ||
        nameLower.contains('peixe') ||
        nameLower.contains('ovo') ||
        nameLower.contains('atum') ||
        nameLower.contains('camarão') ||
        nameLower.contains('porco')) {
      return 'Proteína';
    }

    if (nameLower.contains('arroz') ||
        nameLower.contains('pão') ||
        nameLower.contains('macarrão') ||
        nameLower.contains('batata') ||
        nameLower.contains('mandioca') ||
        nameLower.contains('cereal')) {
      return 'Carboidrato';
    }

    if (nameLower.contains('salada') ||
        nameLower.contains('alface') ||
        nameLower.contains('brócolis') ||
        nameLower.contains('couve') ||
        nameLower.contains('espinafre') ||
        nameLower.contains('legume')) {
      return 'Vegetal';
    }

    if (nameLower.contains('banana') ||
        nameLower.contains('maçã') ||
        nameLower.contains('laranja') ||
        nameLower.contains('fruta') ||
        nameLower.contains('morango') ||
        nameLower.contains('abacate')) {
      return 'Fruta';
    }

    if (food.protein > food.carbs && food.protein > food.fat) {
      return 'Proteína';
    }
    if (food.carbs > food.protein && food.carbs > food.fat) {
      return 'Carboidrato';
    }
    if (food.fat > food.protein && food.fat > food.carbs) {
      return 'Gordura';
    }

    return 'Alimento';
  }

  String _inferCategoryFromName(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('frango') ||
        nameLower.contains('carne') ||
        nameLower.contains('boi') ||
        nameLower.contains('peixe') ||
        nameLower.contains('ovo') ||
        nameLower.contains('atum') ||
        nameLower.contains('camarão') ||
        nameLower.contains('porco')) {
      return 'Proteína';
    }

    if (nameLower.contains('arroz') ||
        nameLower.contains('pão') ||
        nameLower.contains('macarrão') ||
        nameLower.contains('batata') ||
        nameLower.contains('mandioca') ||
        nameLower.contains('cereal')) {
      return 'Carboidrato';
    }

    if (nameLower.contains('salada') ||
        nameLower.contains('alface') ||
        nameLower.contains('brócolis') ||
        nameLower.contains('couve') ||
        nameLower.contains('espinafre') ||
        nameLower.contains('legume')) {
      return 'Vegetal';
    }

    if (nameLower.contains('banana') ||
        nameLower.contains('maçã') ||
        nameLower.contains('laranja') ||
        nameLower.contains('fruta') ||
        nameLower.contains('morango') ||
        nameLower.contains('abacate')) {
      return 'Fruta';
    }

    return 'Alimento';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'proteína':
      case 'proteina':
        return AppColors.protein;
      case 'carboidrato':
        return AppColors.carbs;
      case 'gordura':
        return AppColors.fat;
      case 'vegetal':
        return AppColors.lime;
      case 'fruta':
        return AppColors.magenta;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardPadding = mediaQuery.viewInsets.bottom;
    final systemNavPadding = mediaQuery.viewPadding.bottom;
    final bottomPadding = keyboardPadding > 0 ? keyboardPadding : systemNavPadding;
    final screenHeight = mediaQuery.size.height;
    final minHeight = screenHeight * 0.55;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.94,
        minHeight: minHeight,
      ),
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

          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 4,
                bottom: bottomPadding + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista de itens já adicionados
                  if (_selectedItems.isNotEmpty) ...[
                    _buildSelectedItemsList(),
                    const SizedBox(height: 16),
                  ],

                  // Se está editando quantidade, mostra seção de edição
                  if (_isEditing) ...[
                    _buildQuantityEditor(),
                  ] else ...[
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 8),

                    // Search hint
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColors.lime,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Busca inteligente',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Results
                    _buildSearchResults(),
                  ],
                ],
              ),
            ),
          ),

          // Bottom bar com botão de salvar (só aparece se tem itens)
          if (_selectedItems.isNotEmpty && !_isEditing)
            _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: AppColors.textHighContrast,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Adicionar ao ${widget.mealType.label.toLowerCase()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.01,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.lime.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ITENS (${_selectedItems.length})',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.textSecondaryDark,
              ),
            ),
            Text(
              '$_totalCalories kcal',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...List.generate(_selectedItems.length, (index) {
          final item = _selectedItems[index];
          final category = _inferCategoryFromName(item.name);
          final categoryColor = _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHighContrast,
                          ),
                        ),
                        Text(
                          '${item.quantity.toInt()} ${item.unit} • ${item.calories} kcal',
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
                  GestureDetector(
                    onTap: () => _removeItem(index),
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar() {
    final hasFocus = _focusNode.hasFocus;
    final hasText = _searchController.text.isNotEmpty;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFocus || hasText ? AppColors.primary : AppColors.borderDark,
          width: hasFocus || hasText ? 1.5 : 1,
        ),
        boxShadow: hasFocus || hasText
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
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
            Icons.search,
            size: 20,
            color: hasFocus || hasText ? AppColors.primary : AppColors.textSecondaryDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textHighContrast,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiaryDark,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_isSearching)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else if (hasText)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchResults = []);
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textTertiaryDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return _buildRecentFoodsSection();
    }

    if (_searchResults.isEmpty) {
      if (_searchController.text.length >= 2 && !_isSearching) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.textTertiaryDark,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum alimento encontrado',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return _buildRecentFoodsSection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} resultados',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.textTertiaryDark,
          ),
        ),
        const SizedBox(height: 8),

        ...List.generate(_searchResults.length, (index) {
          final food = _searchResults[index];
          final category = _inferCategory(food);
          final categoryColor = _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _startEditingFood(food),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                  boxShadow: AppShadows.insetHighlight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${food.calories.toStringAsFixed(0)} kcal/100g',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: AppColors.textTertiaryDark,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentFoodsSection() {
    if (_isLoadingRecent) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_recentFoods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: AppColors.textTertiaryDark,
              ),
              const SizedBox(height: 12),
              Text(
                'Busque por um alimento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Digite o nome do alimento acima',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              size: 14,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              'USADOS RECENTEMENTE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...List.generate(_recentFoods.length, (index) {
          final food = _recentFoods[index];
          final category = _inferCategoryFromName(food.name);
          final categoryColor = _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _startEditingRecentFood(food),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                  boxShadow: AppShadows.insetHighlight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${food.calories.toStringAsFixed(0)} kcal/100g',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: AppColors.textTertiaryDark,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantityEditor() {
    final String category;
    if (_editingFood != null) {
      category = _inferCategory(_editingFood!);
    } else {
      category = _inferCategoryFromName(_editingRecentFood!.name);
    }
    final categoryColor = _getCategoryColor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com nome do alimento
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _editingFoodName,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: _cancelEditing,
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quantity controls
        Row(
          children: [
            GestureDetector(
              onTap: _decrementQuantity,
              child: Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Icon(
                  Icons.remove,
                  size: 20,
                  color: AppColors.textHighContrast,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                  boxShadow: AppShadows.insetHighlight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _unit,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: _incrementQuantity,
              child: Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: AppColors.textHighContrast,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Unit chips - diferentes para bebidas vs sólidos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _buildUnitChips(),
          ),
        ),

        const SizedBox(height: 14),

        // Nutrition preview card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.magenta.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
                        '${_currentCalories.round()}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'kcal',
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
              ),
              const Spacer(),
              _buildMacroPreview('Prot', _currentProtein, AppColors.protein),
              const SizedBox(width: 10),
              _buildMacroPreview('Carb', _currentCarbs, AppColors.carbs),
              const SizedBox(width: 10),
              _buildMacroPreview('Gord', _currentFat, AppColors.fat),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add to list button
        SFButton(
          variant: SFButtonVariant.primary,
          size: SFButtonSize.lg,
          fullWidth: true,
          icon: Icons.add,
          onPressed: _confirmAddFood,
          child: const Text('Adicionar à lista'),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedItems.length} ${_selectedItems.length == 1 ? 'item' : 'itens'}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  Row(
                    children: [
                      _buildMiniMacro('P', _totalProtein, AppColors.protein),
                      const SizedBox(width: 8),
                      _buildMiniMacro('C', _totalCarbs, AppColors.carbs),
                      const SizedBox(width: 8),
                      _buildMiniMacro('G', _totalFat, AppColors.fat),
                      const SizedBox(width: 12),
                      Text(
                        '$_totalCalories kcal',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Save button
            SFButton(
              variant: SFButtonVariant.primary,
              size: SFButtonSize.lg,
              fullWidth: true,
              icon: Icons.check,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveMeal,
              child: Text('Registrar refeição ($_totalCalories kcal)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacro(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${value.toStringAsFixed(0)}$label',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitChip(String unit, int? defaultQty) {
    final isSelected = _unit == unit;

    return GestureDetector(
      onTap: () => _setUnit(unit, defaultQty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
          ),
        ),
        child: Text(
          defaultQty != null ? '$unit ($defaultQty g)' : unit,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroPreview(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'g',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Modelo simples para alimentos recentes
class _RecentFood {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String unit;

  const _RecentFood({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.unit,
  });
}
