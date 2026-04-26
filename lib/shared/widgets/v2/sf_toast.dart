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
/// Suporta dois modos:
/// 1. Simples - apenas mensagem
/// 2. Completo - título, descrição, action button
///
/// Exemplo simples:
/// ```dart
/// SFToast.success(context, 'Peso registrado com sucesso!');
/// ```
///
/// Exemplo completo:
/// ```dart
/// SFToast.show(
///   context,
///   title: 'Alimento adicionado',
///   message: 'Frango grelhado, 150g · +248 kcal',
///   type: SFToastType.success,
///   action: 'Ver',
///   onAction: () {},
/// );
/// ```
class SFToast {
  SFToast._();

  static void show(
    BuildContext context, {
    String? title,
    required String message,
    SFToastType type = SFToastType.info,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onAction,
    IconData? icon,
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _ToastContent(
          title: title,
          message: message,
          config: config,
          action: action,
          onAction: onAction,
          customIcon: icon,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: SFToastType.success);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: SFToastType.error);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: SFToastType.warning);
  }

  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: SFToastType.info);
  }

  static _ToastConfig _getConfig(SFToastType type) {
    switch (type) {
      case SFToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle,
          color: AppColors.success,
          glowColor: const Color(0x4D22C55E), // 30% opacity
        );
      case SFToastType.error:
        return _ToastConfig(
          icon: Icons.error,
          color: AppColors.error,
          glowColor: const Color(0x4DEF4444),
        );
      case SFToastType.warning:
        return _ToastConfig(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          glowColor: const Color(0x4DF59E0B),
        );
      case SFToastType.info:
        return _ToastConfig(
          icon: Icons.info,
          color: AppColors.secondary,
          glowColor: const Color(0x4D256AD2),
        );
    }
  }
}

class _ToastConfig {
  final IconData icon;
  final Color color;
  final Color glowColor;

  const _ToastConfig({
    required this.icon,
    required this.color,
    required this.glowColor,
  });
}

class _ToastContent extends StatelessWidget {
  final String? title;
  final String message;
  final _ToastConfig config;
  final String? action;
  final VoidCallback? onAction;
  final IconData? customIcon;

  const _ToastContent({
    this.title,
    required this.message,
    required this.config,
    this.action,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: config.color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: config.glowColor,
            blurRadius: 24,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: title != null ? 50 : 38,
            decoration: BoxDecoration(
              color: config.color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: config.color.withValues(alpha: 0.25)),
            ),
            child: Icon(
              customIcon ?? config.icon,
              size: 20,
              color: config.color,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.1,
                    ),
                  ),
                if (title != null) const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: title != null ? 11 : 14,
                    fontWeight: FontWeight.w500,
                    color: title != null
                        ? AppColors.textSecondaryDark
                        : Colors.white,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action button
          if (action != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onAction!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  action!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: config.color,
                  ),
                ),
              ),
            ),
          ],

          // Close button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
