import 'package:equatable/equatable.dart';

import 'meal_entry.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final int totalCalories;
  final int calorieGoal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealEntry> meals;

  const DailySummary({
    required this.date,
    this.totalCalories = 0,
    this.calorieGoal = 2000,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.meals = const [],
  });

  double get calorieProgress =>
      calorieGoal > 0 ? totalCalories / calorieGoal : 0;

  int get remainingCalories => calorieGoal - totalCalories;

  bool get isOverGoal => totalCalories > calorieGoal;

  double get totalMacros => totalProtein + totalCarbs + totalFat;

  double get proteinPercentage =>
      totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;

  double get carbsPercentage =>
      totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;

  double get fatPercentage =>
      totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

  factory DailySummary.fromMeals({
    required DateTime date,
    required List<MealEntry> meals,
    required int calorieGoal,
  }) {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final meal in meals) {
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalCarbs += meal.totalCarbs;
      totalFat += meal.totalFat;
    }

    return DailySummary(
      date: date,
      totalCalories: totalCalories,
      calorieGoal: calorieGoal,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      meals: meals,
    );
  }

  DailySummary copyWith({
    DateTime? date,
    int? totalCalories,
    int? calorieGoal,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    List<MealEntry>? meals,
  }) {
    return DailySummary(
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object?> get props => [
        date,
        totalCalories,
        calorieGoal,
        totalProtein,
        totalCarbs,
        totalFat,
        meals,
      ];
}
