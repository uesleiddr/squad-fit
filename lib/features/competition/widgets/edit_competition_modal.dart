import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/utils/date_formatter.dart';

class EditCompetitionModal extends StatefulWidget {
  final CompetitionModel competition;

  const EditCompetitionModal({super.key, required this.competition});

  /// Mostra o modal e retorna true se a competição foi atualizada
  static Future<bool?> show(BuildContext context, CompetitionModel competition) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditCompetitionModal(competition: competition),
    );
  }

  @override
  State<EditCompetitionModal> createState() => _EditCompetitionModalState();
}

class _EditCompetitionModalState extends State<EditCompetitionModal> {
  final _formKey = GlobalKey<FormState>();
  final _competitionService = getIt<CompetitionService>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.competition.name);
    _descriptionController =
        TextEditingController(text: widget.competition.description ?? '');
    _endDate = widget.competition.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data de termino',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _competitionService.updateCompetition(
        widget.competition.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        endDate: _endDate,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não foi possível atualizar o desafio. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Editar Desafio',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do desafio',
                  hintText: 'Ex: Desafio de Verao',
                  prefixIcon: const Icon(Icons.emoji_events_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do desafio';
                  }
                  if (value.trim().length < 3) {
                    return 'O nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Descreva o objetivo do desafio',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Data de término
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(6),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data de término',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormatter.format(_endDate)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A regra de vitória não pode ser alterada.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
