import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'core/constants/app_constants.dart';
import 'core/exceptions/app_exceptions.dart';
import 'core/theme/theme.dart';
import 'core/theme/util.dart';
import 'core/di/service_locator.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/competition_service.dart';
import 'core/services/weight_service.dart';
import 'core/services/user_service.dart';
import 'core/utils/invite_code_validator.dart';
import 'core/utils/snackbar_helper.dart';
import 'core/widgets/widgets.dart';
import 'features/auth/screens/auth_wrapper.dart';

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
    Future.delayed(AppConstants.deepLinkDelay, () {
      if (!mounted) return;

      // Verifica se usuário está autenticado antes de mostrar dialog
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        // Salva o código para usar depois do login (opcional: implementar)
        return;
      }

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
    // Cria o tema com as fontes escolhidas
    // Inter para corpo (body), Poppins para títulos (display)
    final textTheme = createTextTheme(context, "Inter", "Poppins");
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'SquadFit',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
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
              ? const ButtonLoadingIndicator(size: 16)
              : const Text('Sim, entrar!'),
        ),
      ],
    );
  }

  Future<void> _joinCompetition() async {
    // Valida o código antes de tentar entrar
    if (!InviteCodeValidator.isValid(widget.inviteCode)) {
      Navigator.pop(context);
      SnackBarHelper.showError(context, 'Código de convite inválido');
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

      SnackBarHelper.showSuccess(context, 'Você entrou no desafio com sucesso!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      // Usa tratamento baseado em tipo de exceção
      String errorMessage;
      if (e is CompetitionException) {
        errorMessage = e.message;
      } else if (e is WeightException) {
        errorMessage = e.message;
      } else if (e is AuthException) {
        errorMessage = 'Você precisa estar logado para entrar em um desafio';
      } else {
        errorMessage = 'Erro ao entrar no desafio. Tente novamente.';
      }

      SnackBarHelper.showError(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
