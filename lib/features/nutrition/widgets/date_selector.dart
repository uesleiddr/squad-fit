import 'package:flutter/material.dart';

/// Widget para navegação entre datas
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  String get _dateLabel {
    if (_isToday) {
      return 'Hoje';
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (selectedDate.year == yesterday.year &&
        selectedDate.month == yesterday.month &&
        selectedDate.day == yesterday.day) {
      return 'Ontem';
    }

    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return '${selectedDate.day} ${months[selectedDate.month - 1]}';
  }

  void _goToPreviousDay() {
    onDateChanged(selectedDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    final tomorrow = selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();

    // Não permite ir para o futuro
    if (tomorrow.isBefore(now) ||
        (tomorrow.year == now.year &&
            tomorrow.month == now.month &&
            tomorrow.day == now.day)) {
      onDateChanged(tomorrow);
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoForward = !_isToday;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousDay,
          tooltip: 'Dia anterior',
        ),
        GestureDetector(
          onTap: () => _openDatePicker(context),
          child: Text(
            _dateLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoForward ? _goToNextDay : null,
          tooltip: 'Próximo dia',
        ),
      ],
    );
  }
}
