import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory WeightRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = DateTime.now();

    // Helper para converter Timestamp com null safety
    DateTime parseTimestamp(dynamic value, DateTime fallback) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return fallback;
    }

    return WeightRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      weight: data['weight']?.toDouble() ?? 0.0,
      date: parseTimestamp(data['date'], now),
      createdAt: parseTimestamp(data['createdAt'], now),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weight': weight,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
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
