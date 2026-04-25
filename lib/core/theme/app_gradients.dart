import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradientes do Squad Fit Design System
///
/// Como usar:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     gradient: AppGradients.primary,
///   ),
/// )
/// ```
abstract class AppGradients {
  // ============================================
  // GRADIENTES PRINCIPAIS
  // ============================================

  /// Gradiente primário - botões principais, CTAs
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFFA8038), Color(0xFFE06820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente secundário (squad/blue)
  static const LinearGradient squad = LinearGradient(
    colors: [Color(0xFF256AD2), Color(0xFF1A4FA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de vitória/sucesso
  static const LinearGradient victory = LinearGradient(
    colors: [Color(0xFFD6FF3B), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // GRADIENTES PREMIUM (Hype moments)
  // ============================================

  /// Gradiente "hype" - momentos especiais, conquistas
  static const LinearGradient hype = LinearGradient(
    colors: [Color(0xFFFF3B8B), Color(0xFFFA8038), Color(0xFFD6FF3B)],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // GRADIENTES DE EFEITO (Overlays)
  // ============================================

  /// Gradiente para streak/destaque vertical
  static const LinearGradient streak = LinearGradient(
    colors: [
      Color(0x38FA8038), // 22% opacity
      Color(0x00FA8038), // 0% opacity
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradiente sutil para cards
  static const LinearGradient cardOverlay = LinearGradient(
    colors: [
      Color(0x08FFFFFF), // 3% white
      Color(0x00FFFFFF), // 0% white
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradiente para efeito de profundidade em cards
  static const LinearGradient cardDepth = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x33000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================
  // GRADIENTES PARA MACROS
  // ============================================

  /// Proteína
  static const LinearGradient protein = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Carboidratos
  static const LinearGradient carbs = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gorduras
  static const LinearGradient fat = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // RADIAL GRADIENTS (Glow effects)
  // ============================================

  /// Glow laranja para botões e destaques
  static RadialGradient orangeGlow({double opacity = 0.4}) => RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: opacity),
          AppColors.primary.withValues(alpha: 0),
        ],
        radius: 1.5,
      );

  /// Glow lime para vitórias
  static RadialGradient limeGlow({double opacity = 0.4}) => RadialGradient(
        colors: [
          AppColors.lime.withValues(alpha: opacity),
          AppColors.lime.withValues(alpha: 0),
        ],
        radius: 1.5,
      );

  /// Glow azul para squads
  static RadialGradient blueGlow({double opacity = 0.4}) => RadialGradient(
        colors: [
          AppColors.secondary.withValues(alpha: opacity),
          AppColors.secondary.withValues(alpha: 0),
        ],
        radius: 1.5,
      );
}
