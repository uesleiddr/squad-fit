import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final double? initialWeight;
  final double? goalWeight;
  final int? height; // em cm
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.initialWeight,
    this.goalWeight,
    this.height,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return UserModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photo_url'],
      initialWeight: json['initial_weight']?.toDouble(),
      goalWeight: json['goal_weight']?.toDouble(),
      height: json['height']?.toInt(),
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
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
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'photo_url': photoUrl,
      'initial_weight': initialWeight,
      'goal_weight': goalWeight,
      'height': height,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    double? initialWeight,
    double? goalWeight,
    int? height,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      initialWeight: initialWeight ?? this.initialWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        photoUrl,
        initialWeight,
        goalWeight,
        height,
        birthDate,
        createdAt,
        updatedAt,
      ];
}
