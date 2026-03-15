/// Modelo para representar uma entrada no ranking da competição
class RankingEntryModel {
  final int position;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double initialWeight;
  final double currentWeight;
  final double weightLost; // kg perdidos (positivo = perdeu peso)
  final double percentageLost; // % perdida (positivo = perdeu peso)
  final bool isCurrentUser;

  RankingEntryModel({
    required this.position,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.initialWeight,
    required this.currentWeight,
    required this.weightLost,
    required this.percentageLost,
    required this.isCurrentUser,
  });

  /// Retorna true se o usuário perdeu peso
  bool get hasLostWeight => weightLost > 0;
}
