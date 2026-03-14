import 'package:flutter/material.dart';

/// Window Size Classes seguindo Material Design 3
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  /// < 600dp - Celulares em portrait
  compact,

  /// 600dp - 840dp - Tablets em portrait, foldables
  medium,

  /// >= 840dp - Tablets em landscape, desktop
  expanded,
}

/// Classe utilitaria para responsive design
class Responsive {
  // Breakpoints Material Design 3
  static const double compactMaxWidth = 600;
  static const double mediumMaxWidth = 840;

  /// Retorna o WindowSizeClass baseado na largura da tela
  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < compactMaxWidth) {
      return WindowSizeClass.compact;
    } else if (width < mediumMaxWidth) {
      return WindowSizeClass.medium;
    } else {
      return WindowSizeClass.expanded;
    }
  }

  /// Verifica se a tela e compact (celular)
  static bool isCompact(BuildContext context) {
    return getWindowSizeClass(context) == WindowSizeClass.compact;
  }

  /// Verifica se a tela e medium ou maior (tablet+)
  static bool isMediumOrLarger(BuildContext context) {
    return getWindowSizeClass(context) != WindowSizeClass.compact;
  }

  /// Verifica se esta em landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Retorna padding responsivo baseado no tamanho da tela
  static EdgeInsets screenPadding(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return const EdgeInsets.all(16);
      case WindowSizeClass.medium:
        return const EdgeInsets.all(24);
      case WindowSizeClass.expanded:
        return const EdgeInsets.all(32);
    }
  }

  /// Retorna espacamento entre cards baseado no tamanho da tela
  static double cardSpacing(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return 6;
      case WindowSizeClass.medium:
        return 12;
      case WindowSizeClass.expanded:
        return 16;
    }
  }
}

/// Extension methods para acesso facil via context
extension ResponsiveExtension on BuildContext {
  /// Retorna o WindowSizeClass atual
  WindowSizeClass get windowSizeClass => Responsive.getWindowSizeClass(this);

  /// Verifica se e compact (celular)
  bool get isCompact => Responsive.isCompact(this);

  /// Verifica se e medium ou maior (tablet+)
  bool get isMediumOrLarger => Responsive.isMediumOrLarger(this);

  /// Verifica se esta em landscape
  bool get isLandscape => Responsive.isLandscape(this);

  /// Padding responsivo da tela
  EdgeInsets get screenPadding => Responsive.screenPadding(this);

  /// Espacamento entre cards
  double get cardSpacing => Responsive.cardSpacing(this);

  /// Largura da tela
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Altura da tela
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
