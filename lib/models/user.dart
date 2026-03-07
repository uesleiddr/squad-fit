class User {
  final String id;
  final String name;
  final String email;
  final double? initialWeight;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.initialWeight,
    this.createdAt,
  });
}
