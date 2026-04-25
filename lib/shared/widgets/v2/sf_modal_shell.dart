import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Shell padrão para modais bottom sheet do Squad Fit
///
/// Exemplo:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => SFModalShell(
///     child: YourContent(),
///   ),
/// );
/// ```
class SFModalShell extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final bool showHandle;
  final EdgeInsets? padding;

  const SFModalShell({
    super.key,
    required this.child,
    this.maxHeight,
    this.showHandle = true,
    this.padding,
  });

  /// Helper para mostrar um modal com SFModalShell
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
    bool showHandle = true,
    EdgeInsets? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => SFModalShell(
        maxHeight: maxHeight,
        showHandle: showHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          if (showHandle)
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

          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: padding != null
                  ? Padding(padding: padding!, child: child)
                  : child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shell para modais centralizados (alerts/confirmações)
///
/// Exemplo:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => SFCenteredModal(
///     child: YourContent(),
///   ),
/// );
/// ```
class SFCenteredModal extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const SFCenteredModal({
    super.key,
    required this.child,
    this.maxWidth,
  });

  /// Helper para mostrar um modal centralizado
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => SFCenteredModal(
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
          ),
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
            child: child,
          ),
        ),
      ),
    );
  }
}
