import 'package:flutter/material.dart';

/// Paleta de cores centralizada do Squad Fit
///
/// Como usar:
/// ```dart
/// Container(color: AppColors.primary)
/// Container(color: AppColors.success)
/// ```
///
/// Para cores que mudam com o tema (light/dark), use o ColorScheme:
/// ```dart
/// Theme.of(context).colorScheme.primary
/// ```
abstract class AppColors {
  // ============================================
  // CORES PRINCIPAIS (Brand)
  // ============================================

  /// Cor primária do app - usada em botões principais, links, destaques
  static const Color primary = Color(0xFFFA8038);       // Laranja vibrante
  static const Color primaryLight = Color(0xFFFFAB6B);  // Laranja claro
  static const Color primaryDark = Color(0xFFE06820);   // Laranja escuro

  /// Cor secundária - usada para elementos de apoio, gráficos, links secundários
  static const Color secondary = Color(0xFF256AD2);     // Azul
  static const Color secondaryLight = Color(0xFF5A8FE0); // Azul claro
  static const Color secondaryDark = Color(0xFF1A4FA0); // Azul escuro

  // ============================================
  // CORES SEMÂNTICAS (Feedback)
  // ============================================

  /// Sucesso - confirmações, ações completadas
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  /// Erro - erros, ações destrutivas, alertas críticos
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  /// Aviso - alertas, atenção necessária
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Info - informações, dicas
  static const Color info = Color(0xFF256AD2);      // Mesmo azul da secondary
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1A4FA0);

  // ============================================
  // CORES NEUTRAS (Backgrounds & Surfaces)
  // ============================================

  // Light Theme
  static const Color backgroundLight = Color(0xFFE6E6E8);  // Cinza claro
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Cards brancos
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF111214);  // Fundo principal
  static const Color surfaceDark = Color(0xFF383B42);     // Cards, containers
  static const Color cardDark = Color(0xFF383B42);        // Cards

  // ============================================
  // CORES DE TEXTO
  // ============================================

  // Light Theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);   // Branco
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Cinza claro
  static const Color textTertiaryDark = Color(0xFF6B7280);  // Cinza médio
  static const Color textDisabledDark = Color(0xFF4B5563);  // Cinza escuro

  // ============================================
  // CORES DE BORDA
  // ============================================

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF4B5563);  // Borda visível no dark

  // ============================================
  // CORES ESPECÍFICAS DO APP
  // ============================================

  /// Cores para tipos de refeição (Nutrition feature)
  static const Color breakfast = Color(0xFFF59E0B);  // Amarelo/Laranja - Café
  static const Color lunch = Color(0xFF22C55E);      // Verde - Almoço
  static const Color dinner = Color(0xFF6366F1);     // Índigo - Jantar
  static const Color snack = Color(0xFFEC4899);      // Rosa - Lanche

  /// Cores para macros nutricionais
  static const Color protein = Color(0xFFEF4444);    // Vermelho
  static const Color carbs = Color(0xFF3B82F6);      // Azul
  static const Color fat = Color(0xFFF59E0B);        // Amarelo

  /// Cores para progresso de calorias
  static const Color calorieGood = Color(0xFF22C55E);     // Verde - dentro da meta
  static const Color calorieWarning = Color(0xFFF59E0B);  // Amarelo - próximo do limite
  static const Color calorieOver = Color(0xFFEF4444);     // Vermelho - passou da meta

  // ============================================
  // GRADIENTES
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // HELPERS
  // ============================================

  /// Retorna cor de texto baseado no tema
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }
}
