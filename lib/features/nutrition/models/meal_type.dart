import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Café da Manhã';
      case MealType.lunch:
        return 'Almoço';
      case MealType.dinner:
        return 'Jantar';
      case MealType.snack:
        return 'Lanche';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Symbols.coffee_rounded;
      case MealType.lunch:
        return Symbols.restaurant_rounded;
      case MealType.dinner:
        return Symbols.restaurant_rounded;
      case MealType.snack:
        return Symbols.nutrition_rounded;
    }
  }

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MealType.snack,
    );
  }
}
