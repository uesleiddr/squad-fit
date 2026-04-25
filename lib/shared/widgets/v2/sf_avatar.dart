import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Avatar premium do Squad Fit
///
/// Exemplo:
/// ```dart
/// SFAvatar(
///   initials: 'MA',
///   size: 40,
///   showRing: true,
/// )
/// ```
class SFAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Gradient? gradient;
  final bool showRing;
  final IconData? badge;
  final String? imageUrl;

  const SFAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.gradient,
    this.showRing = false,
    this.badge,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final avatarGradient = gradient ?? AppGradients.squad;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: avatarGradient,
              shape: BoxShape.circle,
              boxShadow: showRing
                  ? [
                      BoxShadow(
                        color: AppColors.backgroundDark,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: AppColors.primary,
                        spreadRadius: 5,
                      ),
                      ...AppShadows.glowOrange,
                    ]
                  : AppShadows.insetHighlight,
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(),
                    ),
                  )
                : _buildInitials(),
          ),

          // Badge
          if (badge != null)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundDark,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    badge,
                    size: size * 0.28,
                    color: AppColors.deep,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTypography.fontDisplay,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
