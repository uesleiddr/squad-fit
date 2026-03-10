import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_setup_screen.dart';
import '../../../core/services/user_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Logado -> verifica perfil
        if (snapshot.hasData) {
          return const _ProfileChecker();
        }

        // Nao logado -> Login
        return const LoginScreen();
      },
    );
  }
}

class _ProfileChecker extends StatefulWidget {
  const _ProfileChecker();

  @override
  State<_ProfileChecker> createState() => _ProfileCheckerState();
}

class _ProfileCheckerState extends State<_ProfileChecker> {
  final _userService = UserService();
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final hasProfile = await _userService.hasCompletedProfile();
      if (mounted) {
        setState(() {
          _hasProfile = hasProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasProfile = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasProfile) {
      return const HomeScreen();
    }

    return const ProfileSetupScreen();
  }
}
