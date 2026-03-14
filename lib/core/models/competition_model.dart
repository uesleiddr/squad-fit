import 'package:cloud_firestore/cloud_firestore.dart';

/// Regra de vitória da competição
enum VictoryRule {
  /// Vence quem perder mais peso em kg
  totalWeightLoss,
  /// Vence quem perder maior percentual de peso
  percentageLoss,
}

class CompetitionModel {
  final String id;
  final String name;
  final String? description;
  final String adminId;
  final DateTime startDate;
  final DateTime endDate;
  final String inviteCode;
  final VictoryRule victoryRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompetitionModel({
    required this.id,
    required this.name,
    this.description,
    required this.adminId,
    required this.startDate,
    required this.endDate,
    required this.inviteCode,
    required this.victoryRule,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get hasEnded => DateTime.now().isAfter(endDate);

  bool get hasStarted => DateTime.now().isAfter(startDate);

  factory CompetitionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompetitionModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      adminId: data['adminId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      inviteCode: data['inviteCode'] ?? '',
      victoryRule: VictoryRule.values.firstWhere(
        (e) => e.name == data['victoryRule'],
        orElse: () => VictoryRule.totalWeightLoss,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'inviteCode': inviteCode,
      'victoryRule': victoryRule.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CompetitionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
    String? inviteCode,
    VictoryRule? victoryRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompetitionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      inviteCode: inviteCode ?? this.inviteCode,
      victoryRule: victoryRule ?? this.victoryRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
