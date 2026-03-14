import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/deep_link_service.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/home/screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SquadFitApp extends StatefulWidget {
  const SquadFitApp({super.key});

  @override
  State<SquadFitApp> createState() => _SquadFitAppState();
}

class _SquadFitAppState extends State<SquadFitApp> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _deepLinkService.onInviteCodeReceived = _handleInviteCode;
    await _deepLinkService.init();
  }

  void _handleInviteCode(String inviteCode) {
    // Aguarda um pouco para garantir que o app está pronto
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        _showJoinConfirmationDialog(ctx, inviteCode);
      }
    });
  }

  void _showJoinConfirmationDialog(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (context) => _JoinConfirmationDialog(inviteCode: inviteCode),
    );
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SquadFit',
      navigatorKey: navigatorKey,
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

class _JoinConfirmationDialog extends StatefulWidget {
  final String inviteCode;

  const _JoinConfirmationDialog({required this.inviteCode});

  @override
  State<_JoinConfirmationDialog> createState() =>
      _JoinConfirmationDialogState();
}

class _JoinConfirmationDialogState extends State<_JoinConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.emoji_events, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Convite Recebido'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Voce foi convidado para participar de um desafio!'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Codigo: '),
                Text(
                  widget.inviteCode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Deseja entrar neste desafio?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Nao'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _joinCompetition,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Sim, entrar!'),
        ),
      ],
    );
  }

  Future<void> _joinCompetition() async {
    setState(() => _isLoading = true);

    try {
      // Import do service seria necessário aqui
      // Por enquanto, apenas fecha o dialog
      // O usuário pode entrar manualmente pela tela de competição
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Use o codigo ${widget.inviteCode} na tela de Desafio para entrar'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
