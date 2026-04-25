import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Tipos de toast disponíveis
enum SFToastType {
  success,
  error,
  warning,
  info,
}

/// Toast premium do Squad Fit Design System
///
/// Exemplo de uso:
/// ```dart
/// SFToast.show(
///   context,
///   message: 'Peso registrado com sucesso!',
///   type: SFToastType.success,
/// );
/// ```
class SFToast {
  SFToast._();

  static void show(
    BuildContext context, {
    required String message,
    SFToastType type = SFToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  config.icon,
                  size: 18,
                  color: config.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.surface2,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: config.color.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SFToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SFToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SFToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SFToastType.info);
  }

  static _ToastConfig _getConfig(SFToastType type) {
    switch (type) {
      case SFToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle,
          color: AppColors.lime,
        );
      case SFToastType.error:
        return _ToastConfig(
          icon: Icons.error,
          color: AppColors.error,
        );
      case SFToastType.warning:
        return _ToastConfig(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        );
      case SFToastType.info:
        return _ToastConfig(
          icon: Icons.info,
          color: AppColors.secondary,
        );
    }
  }
}

class _ToastConfig {
  final IconData icon;
  final Color color;

  const _ToastConfig({
    required this.icon,
    required this.color,
  });
}
