import 'package:flutter/services.dart';

/// Helper para feedback háptico consistente no app
class Haptics {
  Haptics._();

  /// Feedback leve - para toques e seleções
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Feedback médio - para ações importantes
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Feedback pesado - para ações críticas
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Feedback de seleção - para mudanças de estado
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Feedback de sucesso - duas vibrações leves
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Feedback de erro - vibração pesada
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Feedback de warning - vibração média
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}
