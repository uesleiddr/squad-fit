import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/home/screens/home_screen.dart';

class SquadFitApp extends StatelessWidget {
  const SquadFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SquadFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
