import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Spinner premium do Squad Fit Design System
///
/// Features:
/// - Ring 80px com gradiente laranja→magenta (animação rotate)
/// - Glow radial animado
/// - Centro com ícone
/// - Dots pulsantes opcionais
/// - Mensagem e submensagem opcionais
///
/// Exemplo:
/// ```dart
/// SFLoadingSpinner(
///   message: 'Carregando...',
///   subMessage: 'Sincronizando seu squad',
///   showDots: true,
/// )
/// ```
class SFLoadingSpinner extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final bool showDots;
  final double size;
  final IconData? centerIcon;

  const SFLoadingSpinner({
    super.key,
    this.message,
    this.subMessage,
    this.showDots = true,
    this.size = 80,
    this.centerIcon = Icons.fitness_center,
  });

  @override
  State<SFLoadingSpinner> createState() => _SFLoadingSpinnerState();
}

class _SFLoadingSpinnerState extends State<SFLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spinner com glow
          SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo
                Container(
                  width: widget.size + 40,
                  height: widget.size + 40,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),

                // Ring animado
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _SpinnerPainter(),
                      ),
                    );
                  },
                ),

                // Centro com ícone
                Container(
                  width: widget.size * 0.35,
                  height: widget.size * 0.35,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glowOrange,
                  ),
                  child: widget.centerIcon != null
                      ? Icon(
                          widget.centerIcon,
                          size: widget.size * 0.175,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),

          // Mensagem
          if (widget.message != null || widget.subMessage != null) ...[
            const SizedBox(height: 20),
            if (widget.message != null)
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            if (widget.subMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.subMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ],

          // Dots pulsantes
          if (widget.showDots) ...[
            const SizedBox(height: 16),
            _PulsingDots(),
          ],
        ],
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.5;
    const strokeWidth = 5.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surface2
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient ring (arc)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 2,
        colors: [
          Color(0xFFFA8038), // Laranja
          Color(0xFFFF3B8B), // Magenta
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi / 3, // 60 graus
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calcular opacidade baseada no tempo + delay
            final delay = i * 0.15;
            final value = (_controller.value + delay) % 1.0;
            final opacity = 0.3 + (0.7 * _pulse(value));

            return Container(
              margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  double _pulse(double t) {
    // Função de pulse: sobe e desce suavemente
    return (math.sin(t * 2 * math.pi - math.pi / 2) + 1) / 2;
  }
}
