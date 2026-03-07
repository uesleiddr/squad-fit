class Competition {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final List<String> participantIds;

  Competition({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.participantIds,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get durationInDays => endDate.difference(startDate).inDays;
}
