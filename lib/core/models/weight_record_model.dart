import 'package:equatable/equatable.dart';

class WeightRecordModel extends Equatable {
  final String id;
  final String userId;
  final double weight;
  final DateTime date;
  final DateTime createdAt;

  const WeightRecordModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
    required this.createdAt,
  });

  factory WeightRecordModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return WeightRecordModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : now,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  WeightRecordModel copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return WeightRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, weight, date, createdAt];
}
