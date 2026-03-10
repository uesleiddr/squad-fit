import 'package:cloud_firestore/cloud_firestore.dart';

class WeightRecordModel {
  final String id;
  final String userId;
  final double weight;
  final DateTime date;
  final DateTime createdAt;

  WeightRecordModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
    required this.createdAt,
  });

  factory WeightRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      weight: data['weight']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
}
