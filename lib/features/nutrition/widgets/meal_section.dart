import 'package:flutter/material.dart';
import '../models/models.dart';
import 'food_item_tile.dart';

/// Widget que exibe uma seção de refeição (café, almoço, jantar, lanche)
class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<MealItem> items;
  final int totalCalories;
  final VoidCallback? onTap;
  final VoidCallback? onAddMeal;
  final Function(MealItem)? onDeleteItem;

  const MealSection({
    super.key,
    required this.mealType,
    required this.items,
    required this.totalCalories,
    this.onTap,
    this.onAddMeal,
    this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header clicável para adicionar refeição
          InkWell(
            onTap: onAddMeal,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    mealType.icon,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mealType.label,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$totalCalories kcal',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: totalCalories > 0
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // Lista de itens ou "vazio"
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(
                'Toque para adicionar',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Column(
                  children: items
                      .map(
                        (item) => FoodItemTile(
                          item: item,
                          onDelete: onDeleteItem != null
                              ? () => onDeleteItem!(item)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
