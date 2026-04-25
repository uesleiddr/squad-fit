import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia padronizada do Squad Fit
///
/// Como usar:
/// ```dart
/// Text('1044', style: AppTypography.statNumber(context))
/// Text('kcal restantes', style: AppTypography.unit(context))
/// ```
///
/// Fontes utilizadas:
/// - Inter: corpo de texto, labels, buttons
/// - Space Grotesk: displays, números de destaque, títulos principais
abstract class AppTypography {
  // ============================================
  // FONTES (via Google Fonts)
  // ============================================

  /// Fonte principal para corpo de texto (Inter)
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  /// Fonte para displays e números de destaque (Space Grotesk)
  static String get fontDisplay => GoogleFonts.spaceGrotesk().fontFamily!;

  /// Fonte para números tabulares (Space Grotesk)
  static String get fontNumeric => GoogleFonts.spaceGrotesk().fontFamily!;

  // ============================================
  // TAMANHOS (Scale)
  // ============================================

  static const double sizeXs = 12;
  static const double sizeSm = 14;
  static const double sizeMd = 16;
  static const double sizeLg = 18;
  static const double sizeXl = 20;
  static const double size2xl = 24;
  static const double size3xl = 30;
  static const double size4xl = 36;
  static const double size5xl = 48;
  static const double size6xl = 60;
  static const double size7xl = 84; // Para números hero gigantes

  // ============================================
  // PESOS
  // ============================================

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtrabold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;

  // ============================================
  // DISPLAY STYLES (Space Grotesk)
  // ============================================

  /// Display XL - hero screens, onboarding, victory
  static TextStyle displayXl(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontDisplay,
      fontSize: 72,
      fontWeight: weightBlack,
      letterSpacing: -2.5,
      height: 0.92,
      color: color ?? Colors.white,
    );
  }

  /// Display LG - títulos principais
  static TextStyle displayLg(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontDisplay,
      fontSize: size6xl,
      fontWeight: weightBold,
      letterSpacing: -1.8,
      height: 0.95,
      color: color ?? Colors.white,
    );
  }

  /// Display MD - subtítulos importantes
  static TextStyle displayMd(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontDisplay,
      fontSize: size5xl,
      fontWeight: weightBold,
      letterSpacing: -1.2,
      height: 1.0,
      color: color ?? Colors.white,
    );
  }

  // ============================================
  // ESTILOS ESPECIAIS (Números/Stats) - Space Grotesk
  // ============================================

  /// Stat XL - números hero (84px)
  static TextStyle statXl(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontNumeric,
      fontSize: 84,
      fontWeight: weightBlack,
      letterSpacing: -3,
      height: 0.9,
      color: color ?? Colors.white,
    );
  }

  /// Número grande de destaque (ex: 1044 kcal)
  /// Cor padrão: branco (como na referência Sandow)
  static TextStyle statNumber(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontNumeric,
      fontSize: size5xl,
      fontWeight: weightBlack,
      letterSpacing: -2,
      height: 1.0,
      color: color ?? Colors.white,
    );
  }

  /// Número médio (ex: 256 kcal em cards menores)
  static TextStyle statNumberMedium(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontNumeric,
      fontSize: size3xl,
      fontWeight: weightBold,
      letterSpacing: -1,
      height: 1.05,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Número pequeno (ex: 180 em lista de itens)
  static TextStyle statNumberSmall(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontNumeric,
      fontSize: sizeXl,
      fontWeight: weightSemibold,
      letterSpacing: -0.5,
      height: 1.2,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  // ============================================
  // TÍTULOS
  // ============================================

  /// Título de página/seção principal (Space Grotesk)
  static TextStyle pageTitle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontDisplay,
      fontSize: size2xl,
      fontWeight: weightBold,
      letterSpacing: -0.5,
      height: 1.15,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Título de card/seção
  static TextStyle sectionTitle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeLg,
      fontWeight: weightSemibold,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Título de item (ex: nome da refeição)
  static TextStyle itemTitle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeMd,
      fontWeight: weightMedium,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  // ============================================
  // CORPO DE TEXTO
  // ============================================

  /// Texto padrão
  static TextStyle body(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeMd,
      fontWeight: weightRegular,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Texto secundário (menor destaque)
  static TextStyle bodySecondary(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeSm,
      fontWeight: weightRegular,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }

  /// Texto pequeno (labels, captions)
  static TextStyle caption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeXs,
      fontWeight: weightRegular,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }

  // ============================================
  // LABELS E BUTTONS
  // ============================================

  /// Label de botão
  static TextStyle button(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeMd,
      fontWeight: weightSemibold,
      letterSpacing: 0.5,
      color: color ?? Theme.of(context).colorScheme.onPrimary,
    );
  }

  /// Label pequena (chips, badges)
  static TextStyle label(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeXs,
      fontWeight: weightMedium,
      letterSpacing: 0.5,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Unidade de medida (kcal, kg, etc)
  static TextStyle unit(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizeMd,
      fontWeight: weightRegular,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }
}
