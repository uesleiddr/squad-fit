import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/design_system.dart';
import '../../../features/nutrition/models/meal_entry.dart';
import '../../../features/nutrition/models/meal_item.dart';
import '../../../features/nutrition/models/meal_type.dart';
import '../../../features/nutrition/services/nutrition_service.dart';
import 'sf_button.dart';
import 'sf_modal_shell.dart';
import 'sf_toast.dart';

/// Modal para editar itens de uma refeição
///
/// Permite:
/// - Alterar quantidade de cada item
/// - Excluir itens individuais
/// - Ver macros de cada item
/// - Trabalhar com múltiplas entries do mesmo tipo (dados legados)
class SFEditMealModal extends StatefulWidget {
  final MealType mealType;
  final List<MealEntry> entries;

  const SFEditMealModal({
    super.key,
    required this.mealType,
    required this.entries,
  });

  /// Mostra o modal para múltiplas entries e retorna true se houve alterações
  static Future<bool?> showForEntries(
    BuildContext context,
    MealType mealType,
    List<MealEntry> entries,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SFEditMealModal(
        mealType: mealType,
        entries: entries,
      ),
    );
  }

  @override
  State<SFEditMealModal> createState() => _SFEditMealModalState();
}

class _SFEditMealModalState extends State<SFEditMealModal> {
  final _nutritionService = getIt<NutritionService>();

  // Mapa de entryId -> lista de items
  Map<String, List<MealItem>> _itemsByEntry = {};
  List<MealItem> _allItems = [];

  bool _isLoading = true;
  bool _hasChanges = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    final Map<String, List<MealItem>> itemsByEntry = {};
    final List<MealItem> allItems = [];

    for (final entry in widget.entries) {
      final items = await _nutritionService.getMealItems(entry.id);
      itemsByEntry[entry.id] = items;
      allItems.addAll(items);
    }

    setState(() {
      _itemsByEntry = itemsByEntry;
      _allItems = allItems;
      _isLoading = false;

      // Inicializa controllers
      for (final item in allItems) {
        _controllers[item.id] = TextEditingController(
          text: item.quantity.toString().replaceAll(RegExp(r'\.0$'), ''),
        );
      }
    });
  }

  Future<void> _updateItemQuantity(MealItem item, double newQuantity) async {
    if (newQuantity <= 0) return;

    try {
      final updatedItem = await _nutritionService.updateMealItemQuantity(item, newQuantity);
      await _nutritionService.recalculateMealTotals(item.mealEntryId);

      setState(() {
        _hasChanges = true;

        // Atualiza no mapa
        final entryItems = _itemsByEntry[item.mealEntryId];
        if (entryItems != null) {
          final index = entryItems.indexWhere((i) => i.id == item.id);
          if (index >= 0) {
            entryItems[index] = updatedItem;
          }
        }

        // Atualiza na lista geral
        final allIndex = _allItems.indexWhere((i) => i.id == item.id);
        if (allIndex >= 0) {
          _allItems[allIndex] = updatedItem;
        }
      });
    } catch (e) {
      if (mounted) {
        SFToast.error(context, 'Erro ao atualizar quantidade');
      }
    }
  }

  Future<void> _deleteItem(MealItem item) async {
    // Não permite excluir último item geral
    if (_allItems.length <= 1) {
      SFToast.error(context, 'Uma refeição deve ter pelo menos um item');
      return;
    }

    try {
      await _nutritionService.deleteMealItem(item.id);
      await _nutritionService.recalculateMealTotals(item.mealEntryId);

      setState(() {
        _hasChanges = true;

        // Remove do mapa
        final entryItems = _itemsByEntry[item.mealEntryId];
        if (entryItems != null) {
          entryItems.removeWhere((i) => i.id == item.id);
        }

        // Remove da lista geral
        _allItems.removeWhere((i) => i.id == item.id);
        _controllers.remove(item.id);
      });

      if (mounted) {
        SFToast.success(context, 'Item removido');
      }
    } catch (e) {
      if (mounted) {
        SFToast.error(context, 'Erro ao remover item');
      }
    }
  }

  int get _totalCalories => _allItems.fold<int>(0, (sum, item) => sum + item.calories);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return SFModalShell(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  'Editar ${widget.mealType.label}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_allItems.length} ${_allItems.length == 1 ? 'item' : 'itens'} · $_totalCalories kcal',
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

          // Loading ou lista
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _allItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildItemTile(_allItems[index]),
              ),
            ),

          const SizedBox(height: 24),

          // Botão fechar
          SFButton(
            variant: SFButtonVariant.primary,
            size: SFButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.pop(context, _hasChanges),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(MealItem item) {
    final controller = _controllers[item.id]!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome e calorias
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.calories} kcal',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Macros
          Row(
            children: [
              _buildMacro('P', item.protein, AppColors.info),
              const SizedBox(width: 12),
              _buildMacro('C', item.carbs, AppColors.warning),
              const SizedBox(width: 12),
              _buildMacro('G', item.fat, AppColors.error),
            ],
          ),

          const SizedBox(height: 14),

          // Quantidade e ações
          Row(
            children: [
              // Input de quantidade
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    // Menos
                    GestureDetector(
                      onTap: () {
                        final current = double.tryParse(controller.text) ?? item.quantity;
                        if (current > 1) {
                          final newQty = current - 1;
                          controller.text = newQty.toStringAsFixed(0);
                          _updateItemQuantity(item, newQty);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                    // Input
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                        ],
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          final newQty = double.tryParse(value.replaceAll(',', '.'));
                          if (newQty != null && newQty > 0) {
                            _updateItemQuantity(item, newQty);
                          } else {
                            controller.text = item.quantity.toString().replaceAll(RegExp(r'\.0$'), '');
                          }
                        },
                      ),
                    ),
                    // Mais
                    GestureDetector(
                      onTap: () {
                        final current = double.tryParse(controller.text) ?? item.quantity;
                        final newQty = current + 1;
                        controller.text = newQty.toStringAsFixed(0);
                        _updateItemQuantity(item, newQty);
                      },
                      child: Container(
                        width: 32,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Unidade
              Text(
                item.unit,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),

              const Spacer(),

              // Botão excluir
              GestureDetector(
                onTap: () => _showDeleteConfirmation(item),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacro(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${value.toStringAsFixed(1)}g',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(MealItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir item',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Deseja excluir "${item.name}" da refeição?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
            child: Text(
              'Excluir',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
