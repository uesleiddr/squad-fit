/// Utilitario para formatacao de datas
class DateFormatter {
  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
  static const _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  /// Formata data completa com dia da semana: "Seg, 15 de Mar de 2024"
  static String formatWithWeekday(DateTime date, {bool includeYear = true}) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];

    if (includeYear) {
      return '$weekday, ${date.day} de $month de ${date.year}';
    }
    return '$weekday, ${date.day} de $month';
  }

  /// Formata data simples: "15 de Mar de 2024"
  static String format(DateTime date) {
    final month = _months[date.month - 1];
    return '${date.day} de $month de ${date.year}';
  }

  /// Verifica se a data e hoje
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}
