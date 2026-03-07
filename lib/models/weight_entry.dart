class WeightEntry {
  final String id;
  final String userId;
  final String competitionId;
  final double weight;
  final DateTime date;
  final String? photoUrl;

  WeightEntry({
    required this.id,
    required this.userId,
    required this.competitionId,
    required this.weight,
    required this.date,
    this.photoUrl,
  });
}
