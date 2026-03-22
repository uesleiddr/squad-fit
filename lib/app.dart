import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/competition_service.dart';
import 'core/services/weight_service.dart';
import 'core/services/user_service.dart';
import 'core/utils/invite_code_validator.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/home/screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SquadFitApp extends StatefulWidget {
  const SquadFitApp({super.key});

  @override
  State<SquadFitApp> createState() => _SquadFitAppState();
}

class _SquadFitAppState extends State<SquadFitApp> {
  final _deepLinkService = getIt<DeepLinkService>();

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
          const Text('Você foi convidado para participar de um desafio!'),
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
                const Text('Código: '),
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
          child: const Text('Não'),
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
    // Valida o código antes de tentar entrar
    if (!InviteCodeValidator.isValid(widget.inviteCode)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de convite inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final weightService = getIt<WeightService>();
      final userService = getIt<UserService>();
      final user = await userService.getCurrentUser();
      final currentWeight = await weightService.getCurrentWeight(user?.initialWeight);

      final competitionService = getIt<CompetitionService>();
      await competitionService.joinCompetitionByCode(
        widget.inviteCode,
        currentWeight: currentWeight,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você entrou no desafio com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      String errorMessage = 'Erro ao entrar no desafio';
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('não encontrada') || errorStr.contains('nao encontrada')) {
        errorMessage = 'Código de convite inválido';
      } else if (errorStr.contains('ja esta') || errorStr.contains('já está') || errorStr.contains('já participa')) {
        errorMessage = 'Você já está neste desafio';
      } else if (errorStr.contains('registrar seu peso')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
