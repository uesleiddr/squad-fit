import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_avatar.dart';

/// Linha de ranking premium do Squad Fit
///
/// Exibe:
/// - Posição com medalha (ouro, prata, bronze para top 3)
/// - Avatar do usuário
/// - Nome com badge "você" se for o usuário atual
/// - Subtítulo (ex: "Líder há 4 dias")
/// - Delta (ex: "-3.8kg")
/// - Trend opcional (seta up/down)
///
/// Exemplo:
/// ```dart
/// SFRankingRow(
///   position: 1,
///   name: 'Ueslei D.',
///   initials: 'UD',
///   delta: '-3.8kg',
///   subtitle: 'Líder há 4 dias',
///   isMe: false,
/// )
/// ```
class SFRankingRow extends StatelessWidget {
  final int position;
  final String name;
  final String initials;
  final String delta;
  final String? subtitle;
  final bool isMe;
  final Gradient? avatarGradient;
  final RankingTrend? trend;
  final VoidCallback? onTap;

  const SFRankingRow({
    super.key,
    required this.position,
    required this.name,
    required this.initials,
    required this.delta,
    this.subtitle,
    this.isMe = false,
    this.avatarGradient,
    this.trend,
    this.onTap,
  });

  // Cores das medalhas
  static const _goldColor = Color(0xFFFFD166);
  static const _silverColor = Color(0xFFD9D9E0);
  static const _bronzeColor = Color(0xFFE09460);

  Color? get _medalColor {
    if (position == 1) return _goldColor;
    if (position == 2) return _silverColor;
    if (position == 3) return _bronzeColor;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final medalColor = _medalColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? null
              : AppColors.surfaceDark,
          gradient: isMe
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.02),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.borderDark,
          ),
          boxShadow: isMe
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                  ...AppShadows.insetHighlight,
                ]
              : AppShadows.insetHighlight,
        ),
        child: Row(
          children: [
            // Posição
            _buildPositionBadge(medalColor),
            const SizedBox(width: 12),

            // Avatar
            SFAvatar(
              initials: initials,
              size: 40,
              gradient: avatarGradient ?? AppGradients.squad,
            ),
            const SizedBox(width: 12),

            // Nome e subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHighContrast,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        _buildYouBadge(),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Delta e trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  delta,
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isMe
                        ? AppColors.lime
                        : (position <= 3 ? AppColors.lime : AppColors.textHighContrast),
                    letterSpacing: -0.5,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(height: 2),
                  _buildTrend(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionBadge(Color? medalColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: medalColor != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  medalColor,
                  medalColor.withValues(alpha: 0.53),
                ],
              )
            : null,
        color: medalColor == null ? AppColors.surface2 : null,
        borderRadius: BorderRadius.circular(10),
        border: medalColor == null
            ? Border.all(color: AppColors.borderDark)
            : null,
        boxShadow: medalColor != null
            ? [
                BoxShadow(
                  color: medalColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$position',
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: medalColor != null
                ? AppColors.deep
                : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildYouBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'você',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTrend() {
    final isDown = trend == RankingTrend.down;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDown ? Icons.arrow_downward : Icons.arrow_upward,
          size: 11,
          color: AppColors.textTertiaryDark,
        ),
        const SizedBox(width: 2),
        Text(
          'vs ontem',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.textTertiaryDark,
          ),
        ),
      ],
    );
  }
}

enum RankingTrend {
  up,
  down,
}
