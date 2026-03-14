import 'package:flutter/material.dart';
import '../../../core/models/weight_record_model.dart';
import '../../../core/services/weight_service.dart';
import '../../../core/utils/responsive.dart';
import 'add_weight_screen.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  final _weightService = WeightService();

  String _formatDate(DateTime date) {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    return '${weekdays[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]}';
  }

  Future<void> _deleteWeight(WeightRecordModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text(
          'Deseja excluir o registro de ${record.weight.toStringAsFixed(1)} kg do dia ${_formatDate(record.date)}?',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro excluido'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToAddWeight() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddWeightScreen()),
    );

    if (result == true) {
      setState(() {}); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico de Peso'),
      ),
      body: StreamBuilder<List<WeightRecordModel>>(
        stream: _weightService.getWeightHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar dados: ${snapshot.error}'),
                ],
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro de peso',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registre seu primeiro peso!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddWeight,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Peso'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: context.screenPadding,
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];

              // Calcula diferença com registro anterior (mais antigo)
              double? diff;
              if (index < records.length - 1) {
                diff = record.weight - records[index + 1].weight;
              }

              return _WeightCard(
                record: record,
                diff: diff,
                formatDate: _formatDate,
                onDelete: () => _deleteWeight(record),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWeight,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  final WeightRecordModel record;
  final double? diff;
  final String Function(DateTime) formatDate;
  final VoidCallback onDelete;

  const _WeightCard({
    required this.record,
    this.diff,
    required this.formatDate,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Peso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${record.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatDate(record.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Diferença
            if (diff != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: diffColor?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(diffIcon, size: 16, color: diffColor),
                    const SizedBox(width: 4),
                    Text(
                      diffText,
                      style: TextStyle(
                        color: diffColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Botão deletar
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.grey,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
