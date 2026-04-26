import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Item de ação para o SFActionSheet
class SFActionSheetItem {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isHighlight;
  final Color? color;

  const SFActionSheetItem({
    required this.icon,
    required this.label,
    this.description,
    required this.onTap,
    this.isDestructive = false,
    this.isHighlight = false,
    this.color,
  });
}

/// Bottom sheet de opções premium do Squad Fit Design System
///
/// Features:
/// - Header com contexto (ícone, título, subtítulo)
/// - Lista de ações com ícone + label + descrição
/// - Suporte a `isDestructive` (vermelho)
/// - Suporte a `isHighlight` (lime)
/// - Botão cancelar no final
///
/// Exemplo:
/// ```dart
/// SFActionSheet.show(
///   context,
///   title: 'Almoço de hoje',
///   subtitle: '3 itens · 520 kcal',
///   icon: Icons.rice_bowl,
///   iconColor: AppColors.success,
///   actions: [
///     SFActionSheetItem(
///       icon: Icons.edit,
///       label: 'Editar refeição',
///       description: 'Altere itens ou quantidade',
///       onTap: () {},
///     ),
///     SFActionSheetItem(
///       icon: Icons.delete_outline,
///       label: 'Excluir refeição',
///       description: 'Essa ação não pode ser desfeita',
///       isDestructive: true,
///       onTap: () {},
///     ),
///   ],
/// );
/// ```
class SFActionSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final List<SFActionSheetItem> actions;
  final bool showCancel;
  final String cancelLabel;

  const SFActionSheet({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.actions,
    this.showCancel = true,
    this.cancelLabel = 'Cancelar',
  });

  /// Mostra o action sheet
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    required List<SFActionSheetItem> actions,
    bool showCancel = true,
    String cancelLabel = 'Cancelar',
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SFActionSheet(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        actions: actions,
        showCancel: showCancel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Header (se tiver título)
          if (title != null) _buildHeader(),

          // Actions
          Builder(
            builder: (context) {
              final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
              return Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 10, showCancel ? 6 : 16 + bottomPadding),
                child: Column(
                  children: actions.map((action) => _buildActionItem(context, action)).toList(),
                ),
              );
            },
          ),

          // Cancel button com SafeArea
          if (showCancel)
            Builder(
              builder: (context) {
                final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPadding),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Center(
                        child: Text(
                          cancelLabel,
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
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final color = iconColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, SFActionSheetItem action) {
    final Color itemColor;
    final Color bgColor;
    final Color borderColor;

    if (action.isDestructive) {
      itemColor = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.1);
      borderColor = AppColors.error.withValues(alpha: 0.25);
    } else if (action.isHighlight) {
      itemColor = AppColors.lime;
      bgColor = AppColors.lime.withValues(alpha: 0.12);
      borderColor = AppColors.lime.withValues(alpha: 0.25);
    } else {
      itemColor = action.color ?? AppColors.textHighContrast;
      bgColor = AppColors.surface2;
      borderColor = AppColors.borderDark;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                action.icon,
                size: 20,
                color: itemColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: action.isDestructive ? AppColors.error : Colors.white,
                    ),
                  ),
                  if (action.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      action.description!,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
