import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Ilustração decorativa para empty states do Squad Fit
///
/// Inclui:
/// - Glow radial colorido
/// - Círculos concêntricos (dashed e solid)
/// - Dots de accent nas bordas
/// - Tile central com ícone
///
/// Exemplo:
/// ```dart
/// SFEmptyIllustration(
///   icon: Icons.group_add,
///   glowColor: AppColors.magenta,
///   accentColor: AppColors.magenta,
/// )
/// ```
class SFEmptyIllustration extends StatelessWidget {
  final IconData icon;
  final Color? glowColor;
  final Color? accentColor;
  final double size;

  const SFEmptyIllustration({
    super.key,
    required this.icon,
    this.glowColor,
    this.accentColor,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? AppColors.primary;
    final accent = accentColor ?? AppColors.primary;
    final scale = size / 200;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Soft glow background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    glow.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Concentric rings
          Positioned.fill(
            child: CustomPaint(
              painter: _RingsPainter(
                borderColor: AppColors.borderDark,
                scale: scale,
              ),
            ),
          ),

          // Floating accent dots
          _buildDot(
            top: 20 * scale,
            right: 26 * scale,
            size: 8 * scale,
            color: accent,
            withGlow: true,
          ),
          _buildDot(
            bottom: 32 * scale,
            left: 30 * scale,
            size: 5 * scale,
            color: AppColors.lime,
            withGlow: true,
          ),
          _buildDot(
            top: 60 * scale,
            left: 14 * scale,
            size: 4 * scale,
            color: AppColors.secondary,
            withGlow: false,
            opacity: 0.7,
          ),
          _buildDot(
            bottom: 60 * scale,
            right: 10 * scale,
            size: 6 * scale,
            color: AppColors.magenta,
            withGlow: true,
            opacity: 0.6,
          ),

          // Center icon tile
          Center(
            child: Container(
              width: 96 * scale,
              height: 96 * scale,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface2,
                    AppColors.surfaceDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(28 * scale),
                border: Border.all(color: AppColors.borderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: glow.withValues(alpha: 0.4),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 44 * scale,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    bool withGlow = false,
    double opacity = 1.0,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: withGlow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: size * 1.2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Color borderColor;
  final double scale;

  _RingsPainter({
    required this.borderColor,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer dashed ring
    final dashedPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final outerRadius = 86 * scale;
    _drawDashedCircle(canvas, center, outerRadius, dashedPaint, 2, 6);

    // Inner solid ring
    final solidPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerRadius = 64 * scale;
    canvas.drawCircle(center, innerRadius, solidPaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final dashAngle = (dashWidth / circumference) * 2 * math.pi;
    final spaceAngle = (dashSpace / circumference) * 2 * math.pi;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashAngle + spaceAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
