import 'package:equatable/equatable.dart';

enum ParticipantStatus {
  active,    // Participando ativamente
  removed,   // Saiu/foi removido (pode entrar novamente)
  archived,  // Competição encerrada e arquivada (histórico)
}

class CompetitionParticipantModel extends Equatable {
  final String id;
  final String competitionId;
  final String userId;
  final double initialWeight; // peso ao entrar na competição
  final DateTime joinedAt;
  final ParticipantStatus status;

  const CompetitionParticipantModel({
    required this.id,
    required this.competitionId,
    required this.userId,
    required this.initialWeight,
    required this.joinedAt,
    required this.status,
  });

  /// Calcula a porcentagem de peso perdido
  double calculateWeightLossPercentage(double currentWeight) {
    if (initialWeight <= 0) return 0;
    return ((initialWeight - currentWeight) / initialWeight) * 100;
  }

  factory CompetitionParticipantModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return CompetitionParticipantModel(
      id: json['id'] ?? '',
      competitionId: json['competition_id'] ?? '',
      userId: json['user_id'] ?? '',
      initialWeight: json['initial_weight']?.toDouble() ?? 0.0,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : now,
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParticipantStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competition_id': competitionId,
      'user_id': userId,
      'initial_weight': initialWeight,
      'status': status.name,
    };
  }

  CompetitionParticipantModel copyWith({
    String? id,
    String? competitionId,
    String? userId,
    double? initialWeight,
    DateTime? joinedAt,
    ParticipantStatus? status,
  }) {
    return CompetitionParticipantModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      userId: userId ?? this.userId,
      initialWeight: initialWeight ?? this.initialWeight,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        competitionId,
        userId,
        initialWeight,
        joinedAt,
        status,
      ];
}
