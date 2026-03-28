import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/user_service.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_setup_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Verifica se há sessão ativa
        final session = Supabase.instance.client.auth.currentSession;

        // Logado -> verifica perfil
        if (session != null) {
          return const _ProfileChecker();
        }

        // Nao logado -> Login
        return const LoginScreen();
      },
    );
  }
}

class _ProfileChecker extends StatelessWidget {
  const _ProfileChecker();

  @override
  Widget build(BuildContext context) {
    final userService = getIt<UserService>();

    return StreamBuilder(
      stream: userService.getCurrentUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        final hasProfile = user != null &&
            user.firstName.isNotEmpty &&
            user.initialWeight != null;

        if (hasProfile) {
          return const HomeScreen();
        }

        return const ProfileSetupScreen();
      },
    );
  }
}
