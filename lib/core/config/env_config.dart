/// Configuração de variáveis de ambiente em tempo de compilação.
///
/// As variáveis são passadas via --dart-define durante o build:
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
class EnvConfig {
  // Firebase Android
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  // Outras APIs (adicione suas keys sensíveis aqui)
  // static const mySecretApiKey = String.fromEnvironment('MY_SECRET_API_KEY');
}
