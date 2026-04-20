import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/invite_code_validator.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';

class JoinCompetitionModal extends StatefulWidget {
  const JoinCompetitionModal({super.key});

  /// Mostra o modal e retorna true se entrou com sucesso
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JoinCompetitionModal(),
    );
  }

  @override
  State<JoinCompetitionModal> createState() => _JoinCompetitionModalState();
}

class _JoinCompetitionModalState extends State<JoinCompetitionModal> {
  final _codeController = TextEditingController();
  final _competitionService = getIt<CompetitionService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinCompetition() async {
    final code = InviteCodeValidator.normalize(_codeController.text);
    if (code.isEmpty) {
      SnackBarHelper.showError(context, 'Digite o código de convite');
      return;
    }

    if (!InviteCodeValidator.isValid(code)) {
      SnackBarHelper.showError(context, 'Código inválido. Deve ter 8 caracteres alfanuméricos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final weightService = getIt<WeightService>();
      final userService = getIt<UserService>();
      final user = await userService.getCurrentUser();
      final currentWeight = await weightService.getCurrentWeight(user?.initialWeight);

      await _competitionService.joinCompetitionByCode(
        code,
        currentWeight: currentWeight,
      );

      if (mounted) {
        Navigator.pop(context, true);
        SnackBarHelper.showSuccess(context, 'Você entrou no desafio!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Não foi possível entrar no desafio. Verifique o código e tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.modal,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Entrar em um Desafio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Digite o código de convite que você recebeu',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Campo de código
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Código de Convite',
                hintText: 'Ex: ABC12345',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),

            // Botão entrar
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinCompetition,
                child: _isLoading
                    ? const ButtonLoadingIndicator()
                    : const Text(
                        'Entrar no Desafio',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
