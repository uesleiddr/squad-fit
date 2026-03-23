class AppConstants {
  AppConstants._();

  // Validação de peso
  static const double minWeight = 1.0;
  static const double maxWeight = 500.0;

  // Invite code
  static const int inviteCodeLength = 8;
  static const int maxInviteCodeAttempts = 5;

  // Firestore batch limits
  static const int firestoreWhereInLimit = 30;

  // Debounce
  static const Duration rankingDebounce = Duration(milliseconds: 300);
  static const Duration deepLinkDelay = Duration(milliseconds: 500);

  // Datas
  static const int minBirthYear = 1920;
  static const int minWeightYear = 2020;

  // UI
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration shortSnackBarDuration = Duration(seconds: 2);
}
