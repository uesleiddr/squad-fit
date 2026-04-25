import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/user_service.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/screens/home_screen_v2.dart';
import '../../profile/screens/profile_setup_screen.dart';
import 'login_screen_v2.dart';

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
            body: LoadingIndicator(),
          );
        }

        // Verifica se há sessão ativa
        final session = Supabase.instance.client.auth.currentSession;

        // Logado -> verifica perfil
        if (session != null) {
          return const _ProfileChecker();
        }

        // Nao logado -> Login
        return const LoginScreenV2();
      },
    );
  }
}

class _ProfileChecker extends StatelessWidget {
  const _ProfileChecker();

  @override
  Widget build(BuildContext context) {
    final userService = getIt<UserService>();

    // Usa FutureBuilder para verificação inicial (mais confiável que stream)
    return FutureBuilder(
      future: userService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }

        final user = snapshot.data;
        final hasProfile = user != null &&
            user.firstName.isNotEmpty &&
            user.initialWeight != null;

        if (hasProfile) {
          return const HomeScreenV2();
        }

        return const ProfileSetupScreen();
      },
    );
  }
}
