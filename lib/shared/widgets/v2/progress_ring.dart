import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:squad_fit/core/theme/design_system.dart';

/// Anel de progresso premium do Squad Fit
///
/// Exemplo:
/// ```dart
/// ProgressRing(
///   value: 75,
///   size: 140,
///   label: 'META',
///   bigLabel: '1044',
///   unit: 'kcal',
/// )
/// ```
class ProgressRing extends StatefulWidget {
  /// Valor de 0 a 100
  final double value;

  /// Tamanho do anel em pixels
  final double size;

  /// Label inferior (ex: "META", "RESTANTE")
  final String? label;

  /// Número grande central (se null, mostra o value)
  final String? bigLabel;

  /// Unidade ao lado do número (ex: "kcal", "kg")
  final String? unit;

  /// Espessura do anel
  final double strokeWidth;

  /// Cores do gradiente do anel
  final List<Color> gradientColors;

  /// Cor do fundo do anel
  final Color? trackColor;

  /// Duração da animação
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 140,
    this.label,
    this.bigLabel,
    this.unit,
    this.strokeWidth = 10,
    this.gradientColors = const [Color(0xFFFA8038), Color(0xFFFF3B8B)],
    this.trackColor,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  gradientColors: widget.gradientColors,
                  trackColor: widget.trackColor ?? AppColors.surface2,
                ),
              );
            },
          ),

          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Big number
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final displayValue =
                          widget.bigLabel ?? _animation.value.toInt().toString();
                      return Text(
                        widget.bigLabel ?? displayValue,
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: widget.size * 0.26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      );
                    },
                  ),
                  if (widget.unit != null) ...[
                    const SizedBox(width: 3),
                    Text(
                      widget.unit!,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ],
              ),

              // Label
              if (widget.label != null) ...[
                SizedBox(height: widget.size * 0.04),
                Text(
                  widget.label!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryDark,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color trackColor;

  _ProgressRingPainter({
    required this.value,
    required this.strokeWidth,
    required this.gradientColors,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (value.clamp(0, 100) / 100);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
