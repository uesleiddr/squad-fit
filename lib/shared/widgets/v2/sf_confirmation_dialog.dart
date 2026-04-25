import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';
import 'sf_button.dart';

/// Variantes do dialog de confirmação
enum SFConfirmationVariant {
  /// Ação destrutiva (vermelho)
  destructive,

  /// Ação de aviso (amarelo)
  warning,

  /// Ação normal (primária)
  normal,
}

/// Dialog de confirmação premium do Squad Fit
///
/// Exemplo:
/// ```dart
/// final confirmed = await SFConfirmationDialog.show(
///   context: context,
///   title: 'Tem certeza?',
///   message: 'Esta ação não pode ser desfeita.',
///   confirmText: 'Excluir',
///   variant: SFConfirmationVariant.destructive,
/// );
/// ```
class SFConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? infoText;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final SFConfirmationVariant variant;

  const SFConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.infoText,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.icon,
    this.variant = SFConfirmationVariant.normal,
  });

  /// Mostra o dialog e retorna true se confirmado
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? infoText,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData? icon,
    SFConfirmationVariant variant = SFConfirmationVariant.normal,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => SFConfirmationDialog(
        title: title,
        message: message,
        infoText: infoText,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        variant: variant,
      ),
    );
    return result ?? false;
  }

  Color get _accentColor {
    switch (variant) {
      case SFConfirmationVariant.destructive:
        return AppColors.error;
      case SFConfirmationVariant.warning:
        return AppColors.warning;
      case SFConfirmationVariant.normal:
        return AppColors.primary;
    }
  }

  IconData get _defaultIcon {
    switch (variant) {
      case SFConfirmationVariant.destructive:
        return Icons.delete_forever;
      case SFConfirmationVariant.warning:
        return Icons.warning_amber;
      case SFConfirmationVariant.normal:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _defaultIcon;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderDark),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 60,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative glow
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Glow behind
                      Positioned(
                        top: -50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 220,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  _accentColor.withValues(alpha: 0.22),
                                  Colors.transparent,
                                ],
                                radius: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Icon
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _accentColor.withValues(alpha: 0.2),
                                _accentColor.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _accentColor.withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accentColor.withValues(alpha: 0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            effectiveIcon,
                            size: 34,
                            color: _accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                      height: 1.5,
                    ),
                  ),

                  // Info box
                  if (infoText != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              infoText!,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textHighContrast,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Center(
                              child: Text(
                                cancelText,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHighContrast,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Confirm button
                      Expanded(
                        child: _buildConfirmButton(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    if (variant == SFConfirmationVariant.destructive) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(true),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEF4444), Color(0xFFC53030)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.delete,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                confirmText,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SFButton(
      variant: SFButtonVariant.primary,
      fullWidth: true,
      onPressed: () => Navigator.of(context).pop(true),
      child: Text(confirmText),
    );
  }
}
