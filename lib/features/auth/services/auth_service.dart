import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Web Client ID do Google Cloud Console (público por design)
  static const _webClientId =
      '489573537640-52f5ded6pgs58tp1463kh3tarlg39eka.apps.googleusercontent.com';

  // Stream para ouvir mudanças de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  // Session atual
  Session? get currentSession => _supabase.auth.currentSession;

  // Login com email e senha
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cadastro com email e senha
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Login com Google (nativo)
  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Login cancelado pelo usuário');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw Exception('Access Token não encontrado');
    }
    if (idToken == null) {
      throw Exception('ID Token não encontrado');
    }

    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  // Logout
  Future<void> signOut() async {
    // Faz logout do Google também
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    await _supabase.auth.signOut();
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
