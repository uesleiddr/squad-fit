import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_logo.dart';

/// Top bar customizada do Squad Fit
///
/// Suporta:
/// - Leading icon (menu, back, close)
/// - Title com subtitle opcional
/// - Logo no centro (showLogo: true)
/// - Trailing widget
/// - Background transparente
///
/// Exemplo:
/// ```dart
/// SFAppBar(
///   title: 'Perfil',
///   leading: Icons.arrow_back,
///   trailing: Icon(Icons.settings),
///   onLeading: () => Navigator.pop(context),
/// )
/// ```
class SFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final IconData leading;
  final Widget? trailing;
  final VoidCallback? onLeading;
  final bool showLogo;
  final bool transparent;

  const SFAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading = Icons.menu,
    this.trailing,
    this.onLeading,
    this.showLogo = false,
    this.transparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: transparent ? Colors.transparent : AppColors.backgroundDark,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Leading button
            _buildIconButton(
              icon: leading,
              onTap: onLeading,
            ),

            // Center content
            Expanded(
              child: Center(
                child: showLogo
                    ? const SFLogo(width: 110)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: TextStyle(
                                fontFamily: AppTypography.fontDisplay,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 1),
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
            ),

            // Trailing widget or placeholder
            if (trailing != null)
              SizedBox(
                width: 44,
                height: 44,
                child: Center(child: trailing),
              )
            else
              const SizedBox(width: 44, height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
