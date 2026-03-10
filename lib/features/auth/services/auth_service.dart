import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  // Stream para ouvir mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Inicializar Google Sign In
  Future<void> _initializeGoogleSignIn() async {
    if (_initialized) return;
    await _googleSignIn.initialize();
    _initialized = true;
  }

  // Login com email e senha
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Cadastro com email e senha
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    // Verificar se authenticate é suportado
    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception('Google Sign In nao e suportado nesta plataforma');
    }

    try {
      // Autenticar com Google
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // Obter idToken da autenticacao
      final String? idToken = account.authentication.idToken;

      if (idToken == null) {
        throw Exception('Falha ao obter token do Google');
      }

      // Criar credencial para Firebase (so precisa do idToken)
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Log do erro para debug
      print('Erro Google Sign In: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    if (_initialized) {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
