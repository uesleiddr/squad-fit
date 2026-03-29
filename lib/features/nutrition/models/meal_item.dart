import 'package:equatable/equatable.dart';

class MealItem extends Equatable {
  final String id;
  final String mealEntryId;
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? fatsecretFoodId;
  final DateTime createdAt;

  const MealItem({
    required this.id,
    required this.mealEntryId,
    required this.name,
    required this.quantity,
    this.unit = 'porção',
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fatsecretFoodId,
    required this.createdAt,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] ?? '',
      mealEntryId: json['meal_entry_id'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 1).toDouble(),
      unit: json['unit'] ?? 'porção',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fatsecretFoodId: json['fatsecret_food_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_entry_id': mealEntryId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fatsecret_food_id': fatsecretFoodId,
    };
  }

  MealItem copyWith({
    String? id,
    String? mealEntryId,
    String? name,
    double? quantity,
    String? unit,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? fatsecretFoodId,
    DateTime? createdAt,
  }) {
    return MealItem(
      id: id ?? this.id,
      mealEntryId: mealEntryId ?? this.mealEntryId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fatsecretFoodId: fatsecretFoodId ?? this.fatsecretFoodId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealEntryId,
        name,
        quantity,
        unit,
        calories,
        protein,
        carbs,
        fat,
        fatsecretFoodId,
        createdAt,
      ];
}
