/// Configuração de variáveis de ambiente em tempo de compilação.
///
/// As variáveis são passadas via --dart-define durante o build:
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
class EnvConfig {
  // Supabase (Auth + Database)
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // APIs de Nutrição
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const fatsecretClientId = String.fromEnvironment('FATSECRET_CLIENT_ID');
  static const fatsecretClientSecret = String.fromEnvironment('FATSECRET_CLIENT_SECRET');
}
