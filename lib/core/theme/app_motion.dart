import 'package:flutter/animation.dart';

/// Constantes de animação do Squad Fit Design System
///
/// Como usar:
/// ```dart
/// AnimatedContainer(
///   duration: AppMotion.durationBase,
///   curve: AppMotion.easeOut,
///   // ...
/// )
/// ```
abstract class AppMotion {
  // ============================================
  // CURVAS DE ANIMAÇÃO
  // ============================================

  /// Saída padrão - suave e natural
  static const Curve easeOut = Cubic(0.2, 0.8, 0.2, 1);

  /// Spring/bounce - playful, estilo Duolingo
  static const Curve easeSpring = Cubic(0.34, 1.56, 0.64, 1);

  /// Suave - para transições sutis
  static const Curve easeSmooth = Cubic(0.4, 0, 0.2, 1);

  /// Entrada rápida, saída lenta
  static const Curve easeInOut = Curves.easeInOut;

  /// Linear - para progress bars
  static const Curve linear = Curves.linear;

  // ============================================
  // DURAÇÕES
  // ============================================

  /// 120ms - Micro interações (hover, tap feedback)
  static const Duration durationFast = Duration(milliseconds: 120);

  /// 200ms - Interações padrão (toggle, expand)
  static const Duration durationBase = Duration(milliseconds: 200);

  /// 380ms - Transições mais elaboradas
  static const Duration durationSlow = Duration(milliseconds: 380);

  /// 600ms - Reveals, aparições dramáticas
  static const Duration durationReveal = Duration(milliseconds: 600);

  /// 1000ms - Animações longas (onboarding, celebração)
  static const Duration durationLong = Duration(milliseconds: 1000);

  // ============================================
  // PRESETS COMBINADOS
  // ============================================

  /// Para botões e elementos interativos
  static const Duration buttonDuration = durationFast;
  static const Curve buttonCurve = easeSpring;

  /// Para cards e containers
  static const Duration cardDuration = durationBase;
  static const Curve cardCurve = easeOut;

  /// Para modais e overlays
  static const Duration modalDuration = durationSlow;
  static const Curve modalCurve = easeOut;

  /// Para listas e stagger animations
  static const Duration listItemDuration = durationBase;
  static const Curve listItemCurve = easeOut;
  static const Duration listStaggerDelay = Duration(milliseconds: 50);

  /// Para progress indicators
  static const Duration progressDuration = Duration(milliseconds: 800);
  static const Curve progressCurve = easeOut;

  // ============================================
  // DELAYS
  // ============================================

  /// Delay mínimo entre animações em sequência
  static const Duration staggerXs = Duration(milliseconds: 30);

  /// Delay pequeno
  static const Duration staggerSm = Duration(milliseconds: 50);

  /// Delay médio
  static const Duration staggerMd = Duration(milliseconds: 80);

  /// Delay grande
  static const Duration staggerLg = Duration(milliseconds: 120);
}
