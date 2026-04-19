import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

/// Indicador de loading centralizado seguindo Material Design 3 Expressive.
///
/// Usa LoadingIndicatorM3E com efeito de morphing entre formas.
class LoadingIndicator extends StatelessWidget {
  final double? size;

  const LoadingIndicator({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicatorSize = size ?? 48.0;

    return Center(
      child: LoadingIndicatorM3E(
        constraints: BoxConstraints.tight(Size(indicatorSize, indicatorSize)),
        color: colorScheme.primary,
      ),
    );
  }
}

/// Indicador de loading para uso dentro de botões.
///
/// Tamanho compacto com o indicador M3E.
class ButtonLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: LoadingIndicatorM3E(
        constraints: BoxConstraints.tight(Size(size, size)),
        color: color ?? Colors.white,
      ),
    );
  }
}
