import 'package:flutter/material.dart';

/// Constantes de espaçamento do Squad Fit
///
/// Baseado em uma escala de 4px (4, 8, 12, 16, 20, 24, 32, 40, 48, 64)
///
/// Como usar:
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// SizedBox(height: AppSpacing.sm)
/// Gap(AppSpacing.lg)
/// ```
abstract class AppSpacing {
  // ============================================
  // ESCALA DE ESPAÇAMENTO
  // ============================================

  /// 4px - Micro espaçamento
  static const double xxs = 4;

  /// 8px - Extra pequeno
  static const double xs = 8;

  /// 12px - Pequeno
  static const double sm = 12;

  /// 16px - Médio (padrão)
  static const double md = 16;

  /// 20px - Médio-grande
  static const double lg = 20;

  /// 24px - Grande
  static const double xl = 24;

  /// 32px - Extra grande
  static const double xxl = 32;

  /// 40px - Enorme
  static const double xxxl = 40;

  /// 48px - Gigante
  static const double huge = 48;

  /// 64px - Máximo
  static const double massive = 64;

  // ============================================
  // ÍCONES
  // ============================================

  /// Tamanho de ícone pequeno
  static const double iconSm = 16;

  /// Tamanho de ícone médio (padrão)
  static const double iconMd = 24;

  /// Tamanho de ícone grande
  static const double iconLg = 32;

  /// Tamanho de ícone extra grande
  static const double iconXl = 48;

  // ============================================
  // PADDING PRESETS
  // ============================================

  /// Padding para cards
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Padding para telas/páginas
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  /// Padding horizontal de tela
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  /// Padding para itens de lista
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding para botões
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: sm,
  );

  /// Padding para chips/tags
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  /// Padding para inputs
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding para modais/bottom sheets
  static const EdgeInsets modalPadding = EdgeInsets.fromLTRB(md, sm, md, md);

  // ============================================
  // GAP PRESETS (para usar com Column/Row)
  // ============================================

  /// Gap vertical pequeno
  static const SizedBox gapVerticalXs = SizedBox(height: xs);

  /// Gap vertical médio
  static const SizedBox gapVerticalSm = SizedBox(height: sm);

  /// Gap vertical padrão
  static const SizedBox gapVerticalMd = SizedBox(height: md);

  /// Gap vertical grande
  static const SizedBox gapVerticalLg = SizedBox(height: lg);

  /// Gap vertical extra grande
  static const SizedBox gapVerticalXl = SizedBox(height: xl);

  /// Gap horizontal pequeno
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);

  /// Gap horizontal médio
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);

  /// Gap horizontal padrão
  static const SizedBox gapHorizontalMd = SizedBox(width: md);

  /// Gap horizontal grande
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);

  /// Gap horizontal extra grande
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
}
