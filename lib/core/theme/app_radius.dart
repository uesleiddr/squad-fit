import 'package:flutter/material.dart';

/// Constantes de BorderRadius do Squad Fit
///
/// Como usar:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.md,
///   ),
/// )
///
/// ClipRRect(
///   borderRadius: AppRadius.lg,
///   child: Image(...),
/// )
/// ```
abstract class AppRadius {
  // ============================================
  // VALORES BASE
  // ============================================

  /// 0px - Sem arredondamento
  static const double none = 0;

  /// 4px - Mínimo
  static const double xs = 4;

  /// 8px - Pequeno
  static const double sm = 8;

  /// 12px - Médio (padrão para cards)
  static const double md = 12;

  /// 16px - Grande
  static const double lg = 16;

  /// 20px - Extra grande
  static const double xl = 20;

  /// 24px - Muito grande
  static const double xxl = 24;

  /// 9999px - Totalmente redondo (pílula)
  static const double full = 9999;

  // ============================================
  // BORDER RADIUS PRESETS
  // ============================================

  /// Sem arredondamento
  static const BorderRadius zero = BorderRadius.zero;

  /// Border radius extra pequeno (4px)
  static BorderRadius get radiusXs => BorderRadius.circular(xs);

  /// Border radius pequeno (8px)
  static BorderRadius get radiusSm => BorderRadius.circular(sm);

  /// Border radius médio (12px) - padrão para cards
  static BorderRadius get radiusMd => BorderRadius.circular(md);

  /// Border radius grande (16px)
  static BorderRadius get radiusLg => BorderRadius.circular(lg);

  /// Border radius extra grande (20px)
  static BorderRadius get radiusXl => BorderRadius.circular(xl);

  /// Border radius muito grande (24px)
  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);

  /// Border radius completo (pílula)
  static BorderRadius get radiusFull => BorderRadius.circular(full);

  // ============================================
  // PRESETS ESPECÍFICOS
  // ============================================

  /// Para cards
  static BorderRadius get card => radiusMd;

  /// Para botões
  static BorderRadius get button => radiusSm;

  /// Para chips/tags
  static BorderRadius get chip => radiusFull;

  /// Para inputs
  static BorderRadius get input => radiusSm;

  /// Para imagens/avatares
  static BorderRadius get image => radiusMd;

  /// Para modais/bottom sheets
  static BorderRadius get modal => const BorderRadius.vertical(
        top: Radius.circular(xl),
      );

  /// Para bottom sheet handle
  static BorderRadius get sheetHandle => radiusFull;

  // ============================================
  // BORDER RADIUS PARCIAIS
  // ============================================

  /// Apenas topo arredondado
  static BorderRadius topMd = const BorderRadius.vertical(
    top: Radius.circular(md),
  );

  /// Apenas base arredondada
  static BorderRadius bottomMd = const BorderRadius.vertical(
    bottom: Radius.circular(md),
  );

  /// Apenas esquerda arredondada
  static BorderRadius leftMd = const BorderRadius.horizontal(
    left: Radius.circular(md),
  );

  /// Apenas direita arredondada
  static BorderRadius rightMd = const BorderRadius.horizontal(
    right: Radius.circular(md),
  );
}
