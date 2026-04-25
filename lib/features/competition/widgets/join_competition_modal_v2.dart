import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/invite_code_validator.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/v2/v2.dart';

/// Modal V2 para entrar em um desafio com código
class JoinCompetitionModalV2 extends StatefulWidget {
  const JoinCompetitionModalV2({super.key});

  /// Mostra o modal e retorna true se entrou com sucesso
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JoinCompetitionModalV2(),
    );
  }

  @override
  State<JoinCompetitionModalV2> createState() => _JoinCompetitionModalV2State();
}

class _JoinCompetitionModalV2State extends State<JoinCompetitionModalV2> {
  final _competitionService = getIt<CompetitionService>();
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Focus no primeiro campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _fullCode {
    return _codeControllers.map((c) => c.text).join('').toUpperCase();
  }

  bool get _isCodeComplete {
    return _codeControllers.every((c) => c.text.isNotEmpty);
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      // Move para o próximo campo
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Volta para o campo anterior se apagou
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});

    // Auto-submit quando completo
    if (_isCodeComplete) {
      _joinCompetition();
    }
  }

  Future<void> _joinCompetition() async {
    final code = _fullCode;

    if (code.length < 4) {
      SnackBarHelper.showError(context, 'Digite o código completo');
      return;
    }

    // O código real é de 8 caracteres, mas o design mostra 4 dígitos
    // Vamos adaptar para funcionar com ambos formatos
    final normalizedCode = InviteCodeValidator.normalize(code);

    setState(() => _isLoading = true);

    try {
      final weightService = getIt<WeightService>();
      final userService = getIt<UserService>();
      final user = await userService.getCurrentUser();
      final currentWeight =
          await weightService.getCurrentWeight(user?.initialWeight);

      await _competitionService.joinCompetitionByCode(
        normalizedCode,
        currentWeight: currentWeight,
      );

      if (mounted) {
        Navigator.pop(context, true);
        SnackBarHelper.showSuccess(context, 'Você entrou no desafio!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Código inválido ou expirado. Verifique e tente novamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  // Icon
                  _buildIcon(),
                  const SizedBox(height: 14),

                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Code input
                  _buildCodeInput(),
                  const SizedBox(height: 18),

                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 18),

                  // QR scan option
                  _buildQrScanOption(),
                  const SizedBox(height: 20),

                  // Join button
                  SFButton(
                    variant: SFButtonVariant.primary,
                    size: SFButtonSize.lg,
                    fullWidth: true,
                    icon: Icons.login,
                    isLoading: _isLoading,
                    onPressed:
                        _isLoading || !_isCodeComplete ? null : _joinCompetition,
                    child: const Text('Entrar no desafio'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: AppGradients.squad,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.vpn_key,
        size: 34,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'ENTRAR NO DESAFIO',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Digite o código',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Pede pra quem criou o desafio o código de 4 dígitos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDark,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final hasValue = _codeControllers[index].text.isNotEmpty;
        final hasFocus = _focusNodes[index].hasFocus;

        return Container(
          width: 56,
          height: 68,
          margin: EdgeInsets.only(left: index > 0 ? 10 : 0),
          decoration: BoxDecoration(
            gradient: hasValue
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surface2, AppColors.surfaceDark],
                  )
                : null,
            color: hasValue ? null : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasValue || hasFocus
                  ? AppColors.primary
                  : AppColors.borderDark,
              width: hasValue || hasFocus ? 1.5 : 1.5,
            ),
            boxShadow: hasValue || hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                    ...AppShadows.insetHighlight,
                  ]
                : AppShadows.insetHighlight,
          ),
          child: Center(
            child: TextField(
              controller: _codeControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: hasValue ? Colors.white : AppColors.textTertiaryDark,
                letterSpacing: -0.2,
              ),
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: hasValue ? null : '·',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textTertiaryDark,
                ),
              ),
              onChanged: (value) => _onCodeChanged(index, value),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OU',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQrScanOption() {
    return GestureDetector(
      onTap: () {
        SnackBarHelper.showInfo(context, 'Scanner QR em desenvolvimento');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: AppShadows.insetHighlight,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 22,
                color: AppColors.lime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escanear QR code',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Abre a câmera pra ler um convite',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
