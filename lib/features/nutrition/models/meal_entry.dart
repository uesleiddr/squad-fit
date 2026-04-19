import 'package:equatable/equatable.dart';

import 'meal_item.dart';
import 'meal_type.dart';

class MealEntry extends Equatable {
  final String id;
  final String userId;
  final MealType mealType;
  final String description;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealItem> items;
  final DateTime recordedAt;
  final DateTime createdAt;

  const MealEntry({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.description,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.items = const [],
    required this.recordedAt,
    required this.createdAt,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json, {List<MealItem>? items}) {
    return MealEntry(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      mealType: MealType.fromString(json['meal_type'] ?? 'snack'),
      description: json['description'] ?? '',
      totalCalories: json['total_calories'] ?? 0,
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
      items: items ?? [],
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_type': mealType.name,
      'description': description,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  MealEntry copyWith({
    String? id,
    String? userId,
    MealType? mealType,
    String? description,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    List<MealItem>? items,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return MealEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      items: items ?? this.items,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        mealType,
        description,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        items,
        recordedAt,
        createdAt,
      ];
}
