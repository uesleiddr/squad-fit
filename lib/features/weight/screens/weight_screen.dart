import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/widgets.dart';

/// Tela unificada de peso com registro e histórico
class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightService = getIt<WeightService>();
  final _weightController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data da pesagem',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final weight = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );

      await _weightService.addWeight(weight, date: _selectedDate);

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Peso registrado com sucesso!');
        _weightController.clear();
        setState(() {
          _selectedDate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
            context, 'Não foi possível registrar o peso. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteWeight(WeightRecordModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text(
          'Deseja excluir o registro de ${record.weight.toStringAsFixed(1)} kg do dia ${DateFormatter.formatWithWeekday(record.date, includeYear: false)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _weightService.deleteWeight(record.id);
        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Registro excluído');
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(
              context, 'Não foi possível excluir o registro. Tente novamente.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peso'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Formulário de registro
              _buildRegistrationForm(colorScheme),

              const SizedBox(height: 24),

              // Histórico
              _buildHistorySection(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Registrar Peso',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Seletor de data
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormatter.isToday(_selectedDate)
                              ? 'Hoje'
                              : DateFormatter.formatWithWeekday(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campo de peso e botão
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Peso (kg)',
                        hintText: '75.5',
                        suffixText: 'kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o peso';
                        }
                        final weight =
                            double.tryParse(value.replaceAll(',', '.'));
                        if (weight == null || weight <= 0 || weight > 500) {
                          return 'Peso inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveWeight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: _isLoading
                          ? const ButtonLoadingIndicator()
                          : const Icon(Icons.check),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Histórico',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        StreamBuilder<List<WeightRecordModel>>(
          stream: _weightService.getWeightHistoryStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                elevation: 2,
                color: colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Card(
                elevation: 2,
                color: colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Erro ao carregar histórico',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return Card(
                elevation: 2,
                color: colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum registro ainda',
                        style: TextStyle(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registre seu primeiro peso acima!',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: records.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;

                // Calcula diferença com registro anterior (mais antigo)
                double? diff;
                if (index < records.length - 1) {
                  diff = record.weight - records[index + 1].weight;
                }

                return _WeightCard(
                  record: record,
                  diff: diff,
                  onDelete: () => _deleteWeight(record),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _WeightCard extends StatelessWidget {
  final WeightRecordModel record;
  final double? diff;
  final VoidCallback onDelete;

  const _WeightCard({
    required this.record,
    this.diff,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color? diffColor;
    IconData? diffIcon;
    String diffText = '';

    if (diff != null) {
      if (diff! < 0) {
        diffColor = Colors.green;
        diffIcon = Icons.arrow_downward;
        diffText = '${diff!.toStringAsFixed(1)} kg';
      } else if (diff! > 0) {
        diffColor = Colors.red;
        diffIcon = Icons.arrow_upward;
        diffText = '+${diff!.toStringAsFixed(1)} kg';
      } else {
        diffColor = Colors.grey;
        diffIcon = Icons.remove;
        diffText = '0 kg';
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Peso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatWithWeekday(record.date,
                        includeYear: false),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Diferença
            if (diff != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(diffIcon, size: 14, color: diffColor),
                    const SizedBox(width: 4),
                    Text(
                      diffText,
                      style: TextStyle(
                        fontSize: 12,
                        color: diffColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Botão deletar
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: colorScheme.outline,
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
