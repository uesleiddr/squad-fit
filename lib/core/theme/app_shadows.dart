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
  // SOMBRAS DARK THEME (mais sutis)
  // ============================================

  /// Sombra pequena para dark theme
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x40000000), // 25% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra média para dark theme
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x40000000), // 25% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Sombra grande para dark theme
  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x4D000000), // 30% opacity
      blurRadius: 16,
      offset: Offset(0, 8),
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
