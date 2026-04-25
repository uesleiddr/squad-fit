import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Header de seção do Squad Fit
///
/// Exemplo:
/// ```dart
/// SectionHeader(
///   title: 'Refeições',
///   action: 'Ver todas',
///   onAction: () {},
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.actionIcon = Icons.chevron_right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    actionIcon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
