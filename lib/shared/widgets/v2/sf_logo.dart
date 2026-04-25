import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Logo oficial do Squad Fit - wordmark com double chevron italic
///
/// Exemplo de uso:
/// ```dart
/// SFLogo(width: 220)
/// SFLogo.mark(size: 48) // Apenas o ícone
/// ```
class SFLogo extends StatelessWidget {
  final double width;
  final bool onOrange;

  const SFLogo({
    super.key,
    this.width = 220,
    this.onOrange = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * (88 / 300);
    final wordColor = onOrange ? Colors.white : const Color(0xFFF5F6F8);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SFLogoPainter(
          onOrange: onOrange,
          wordColor: wordColor,
        ),
      ),
    );
  }

  /// Logo mark - apenas o ícone chevron
  static Widget mark({double size = 48, bool onOrange = false}) {
    return _SFLogoMark(size: size, onOrange: onOrange);
  }
}

class _SFLogoPainter extends CustomPainter {
  final bool onOrange;
  final Color wordColor;

  _SFLogoPainter({
    required this.onOrange,
    required this.wordColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 300;
    final scaleY = size.height / 88;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Gradient for chevrons
    final chevronGradient = onOrange
        ? const LinearGradient(colors: [Colors.white, Colors.white])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFAB6B), Color(0xFFFA8038)],
          );

    final chevronPaint = Paint()
      ..shader = chevronGradient.createShader(
        const Rect.fromLTWH(0, 0, 60, 70),
      );


    // Transform for skew and translate
    canvas.save();
    canvas.translate(0, 12);

    // Skew matrix for -14 degrees
    final skewMatrix = Matrix4.identity()..setEntry(0, 1, -0.249); // tan(-14deg)
    canvas.transform(skewMatrix.storage);

    // First chevron
    final path1 = Path()
      ..moveTo(6, 32)
      ..lineTo(22, 8)
      ..lineTo(32, 8)
      ..lineTo(16, 32)
      ..lineTo(32, 56)
      ..lineTo(22, 56)
      ..close();
    canvas.drawPath(path1, chevronPaint);

    // Second chevron (with opacity)
    final path2 = Path()
      ..moveTo(30, 32)
      ..lineTo(46, 8)
      ..lineTo(56, 8)
      ..lineTo(40, 32)
      ..lineTo(56, 56)
      ..lineTo(46, 56)
      ..close();

    if (onOrange) {
      canvas.drawPath(path2, Paint()..color = Colors.white.withValues(alpha: 0.55));
    } else {
      final paint2 = Paint()
        ..shader = chevronGradient.createShader(const Rect.fromLTWH(30, 8, 30, 50));
      canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: 0.6));
      canvas.drawPath(path2, paint2);
      canvas.restore();
    }

    canvas.restore();

    // Text - SQUAD and FIT
    // We'll use a text painter for the wordmark
    canvas.save();

    // Skew for text (-8 degrees)
    final textSkew = Matrix4.identity()..setEntry(0, 1, -0.14); // tan(-8deg)
    canvas.transform(textSkew.storage);

    final squadStyle = TextStyle(
      fontFamily: AppTypography.fontDisplay,
      fontSize: 38,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      color: wordColor,
    );

    final squadPainter = TextPainter(
      text: TextSpan(text: 'SQUAD', style: squadStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    squadPainter.paint(canvas, const Offset(86, 24));

    // FIT with gradient
    if (onOrange) {
      final fitPainter = TextPainter(
        text: TextSpan(
          text: 'FIT',
          style: squadStyle.copyWith(color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      fitPainter.paint(canvas, const Offset(196, 24));
    } else {
      // Draw FIT with gradient shader
      final fitGradient = const LinearGradient(
        colors: [Color(0xFFFFAB6B), Color(0xFFFA8038)],
      ).createShader(const Rect.fromLTWH(196, 24, 80, 40));

      final fitPainter = TextPainter(
        text: TextSpan(
          text: 'FIT',
          style: squadStyle.copyWith(
            foreground: Paint()..shader = fitGradient,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      fitPainter.paint(canvas, const Offset(196, 24));
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SFLogoMark extends StatelessWidget {
  final double size;
  final bool onOrange;

  const _SFLogoMark({
    required this.size,
    this.onOrange = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * (72 / 68),
      child: CustomPaint(
        painter: _SFLogoMarkPainter(onOrange: onOrange),
      ),
    );
  }
}

class _SFLogoMarkPainter extends CustomPainter {
  final bool onOrange;

  _SFLogoMarkPainter({required this.onOrange});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 68;
    final scaleY = size.height / 72;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    canvas.translate(4, 8);

    final gradient = onOrange
        ? const LinearGradient(colors: [Colors.white, Colors.white])
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFAB6B), Color(0xFFFA8038)],
          );

    final paint = Paint()
      ..shader = gradient.createShader(const Rect.fromLTWH(0, 0, 50, 50));

    // First chevron
    final path1 = Path()
      ..moveTo(6, 26)
      ..lineTo(20, 4)
      ..lineTo(28, 4)
      ..lineTo(14, 26)
      ..lineTo(28, 48)
      ..lineTo(20, 48)
      ..close();
    canvas.drawPath(path1, paint);

    // Second chevron with opacity
    final path2 = Path()
      ..moveTo(26, 26)
      ..lineTo(40, 4)
      ..lineTo(48, 4)
      ..lineTo(34, 26)
      ..lineTo(48, 48)
      ..lineTo(40, 48)
      ..close();

    if (onOrange) {
      canvas.drawPath(path2, Paint()..color = Colors.white.withValues(alpha: 0.55));
    } else {
      canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: 0.6));
      canvas.drawPath(path2, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
