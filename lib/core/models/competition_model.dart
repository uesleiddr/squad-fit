import 'package:equatable/equatable.dart';

/// Regra de vitória da competição
enum VictoryRule {
  /// Vence quem perder mais peso em kg
  totalWeightLoss,
  /// Vence quem perder maior percentual de peso
  percentageLoss,
}

class CompetitionModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String adminId;
  final DateTime startDate;
  final DateTime endDate;
  final String inviteCode;
  final VictoryRule victoryRule;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompetitionModel({
    required this.id,
    required this.name,
    this.description,
    required this.adminId,
    required this.startDate,
    required this.endDate,
    required this.inviteCode,
    required this.victoryRule,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && status == 'active';
  }

  bool get hasEnded => DateTime.now().isAfter(endDate);

  bool get hasStarted => DateTime.now().isAfter(startDate);

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return CompetitionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      adminId: json['admin_id'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : now,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : now.add(const Duration(days: 30)),
      inviteCode: json['invite_code'] ?? '',
      victoryRule: VictoryRule.values.firstWhere(
        (e) => e.name == json['victory_rule'],
        orElse: () => VictoryRule.totalWeightLoss,
      ),
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'admin_id': adminId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'invite_code': inviteCode,
      'victory_rule': victoryRule.name,
      'status': status,
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
    String? status,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        adminId,
        startDate,
        endDate,
        inviteCode,
        victoryRule,
        status,
        createdAt,
        updatedAt,
      ];
}
