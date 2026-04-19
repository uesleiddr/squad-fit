import 'package:flutter/material.dart';
import '../models/meal_item.dart';

/// Widget que exibe um item de alimento individual
class FoodItemTile extends StatelessWidget {
  final MealItem item;
  final VoidCallback? onDelete;

  const FoodItemTile({
    super.key,
    required this.item,
    this.onDelete,
  });

  String get _quantityText {
    final qty = item.quantity;
    // Remove decimais desnecessários (2.0 -> 2)
    final qtyStr = qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toStringAsFixed(1);
    return '$qtyStr ${item.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          // Quantidade + unidade
          Text(
            _quantityText,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 8),

          // Nome do item
          Expanded(
            child: Text(
              item.name,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Calorias
          Text(
            '${item.calories}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    // Se tiver callback de delete, adiciona swipe
    if (onDelete != null) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: colorScheme.error,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDelete!(),
        child: tile,
      );
    }

    return tile;
  }
}
