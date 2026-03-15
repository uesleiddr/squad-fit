import 'package:cloud_firestore/cloud_firestore.dart';

enum ParticipantStatus {
  active,    // Participando ativamente
  removed,   // Saiu/foi removido (pode entrar novamente)
  archived,  // Competição encerrada e arquivada (histórico)
}

class CompetitionParticipantModel {
  final String id;
  final String competitionId;
  final String userId;
  final double initialWeight; // peso ao entrar na competição
  final DateTime joinedAt;
  final ParticipantStatus status;

  CompetitionParticipantModel({
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

  factory CompetitionParticipantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompetitionParticipantModel(
      id: doc.id,
      competitionId: data['competitionId'] ?? '',
      userId: data['userId'] ?? '',
      initialWeight: data['initialWeight']?.toDouble() ?? 0.0,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ParticipantStatus.active,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'competitionId': competitionId,
      'userId': userId,
      'initialWeight': initialWeight,
      'joinedAt': Timestamp.fromDate(joinedAt),
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
}
