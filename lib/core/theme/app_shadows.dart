import 'package:flutter/material.dart';

/// Constantes de sombras (elevation) do Squad Fit
///
/// Como usar:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppShadows.sm,
///   ),
/// )
/// ```
abstract class AppShadows {
  // ============================================
  // SOMBRAS LIGHT THEME
  // ============================================

  /// Sem sombra
  static const List<BoxShadow> none = [];

  /// Sombra extra pequena - para elementos sutis
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Sombra pequena - para cards e botões
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra média - para cards elevados
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra grande - para modais e dropdowns
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Sombra extra grande - para elementos flutuantes
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x26000000), // 15% opacity
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // ============================================
  // SOMBRAS DARK THEME (mais profundas para premium)
  // ============================================

  /// Sombra xs para dark theme
  static const List<BoxShadow> xsDark = [
    BoxShadow(
      color: Color(0x66000000), // 40% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Sombra pequena para dark theme
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x73000000), // 45% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra média para dark theme
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x80000000), // 50% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x59000000), // 35% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra grande para dark theme
  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x8C000000), // 55% opacity
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x59000000), // 35% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Sombra xl para dark theme
  static const List<BoxShadow> xlDark = [
    BoxShadow(
      color: Color(0xA6000000), // 65% opacity
      blurRadius: 60,
      offset: Offset(0, 24),
    ),
  ];

  // ============================================
  // GLOW EFFECTS (Premium)
  // ============================================

  /// Glow laranja para botões primários
  static const List<BoxShadow> glowOrange = [
    BoxShadow(
      color: Color(0x73FA8038), // 45% opacity
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xE6FA8038), // 90% opacity
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  /// Glow lime para vitórias/conquistas
  static const List<BoxShadow> glowLime = [
    BoxShadow(
      color: Color(0x73D6FF3B), // 45% opacity
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Glow azul para squads
  static const List<BoxShadow> glowBlue = [
    BoxShadow(
      color: Color(0x73256AD2), // 45% opacity
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Glow magenta para social/challenges
  static const List<BoxShadow> glowMagenta = [
    BoxShadow(
      color: Color(0x66FF3B8B), // 40% opacity
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // INNER BORDERS (Premium cards)
  // ============================================

  /// Highlight interno sutil para cards
  static const List<BoxShadow> insetHighlight = [
    BoxShadow(
      color: Color(0x0FFFFFFF), // 6% white
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  /// Ring interno para cards premium
  static const List<BoxShadow> insetRing = [
    BoxShadow(
      color: Color(0x0AFFFFFF), // 4% white
      blurRadius: 0,
      spreadRadius: 1,
    ),
  ];

  // ============================================
  // PRESETS ESPECÍFICOS
  // ============================================

  /// Sombra para cards
  static const List<BoxShadow> card = sm;

  /// Sombra para cards elevados (hover/active)
  static const List<BoxShadow> cardHover = md;

  /// Sombra para botões
  static const List<BoxShadow> button = xs;

  /// Sombra para FAB
  static const List<BoxShadow> fab = md;

  /// Sombra para bottom navigation
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  /// Sombra para app bar
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // ============================================
  // HELPER
  // ============================================

  /// Retorna sombra apropriada para o tema
  static List<BoxShadow> adaptive(BuildContext context, {bool elevated = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return elevated ? mdDark : smDark;
    }
    return elevated ? md : sm;
  }
}
