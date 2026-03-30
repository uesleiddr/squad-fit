import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/services/competition_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';

class CreateCompetitionModal extends StatefulWidget {
  const CreateCompetitionModal({super.key});

  /// Mostra o modal e retorna a competição criada ou null se cancelado
  static Future<CompetitionModel?> show(BuildContext context) {
    return showModalBottomSheet<CompetitionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCompetitionModal(),
    );
  }

  @override
  State<CreateCompetitionModal> createState() => _CreateCompetitionModalState();
}

class _CreateCompetitionModalState extends State<CreateCompetitionModal> {
  final _formKey = GlobalKey<FormState>();
  final _competitionService = getIt<CompetitionService>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _endDate;
  VictoryRule? _selectedRule;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectEndDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: tomorrow,
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

  Future<void> _createCompetition() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDate == null) {
      SnackBarHelper.showError(context, 'Selecione a data de término');
      return;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (_endDate!.isBefore(todayOnly) || _endDate!.isAtSameMomentAs(todayOnly)) {
      SnackBarHelper.showError(context, 'A data de término deve ser no futuro');
      return;
    }

    if (_selectedRule == null) {
      SnackBarHelper.showError(context, 'Selecione a regra de vitória');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final competition = await _competitionService.createCompetition(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: DateTime.now(),
        endDate: _endDate!,
        victoryRule: _selectedRule!,
      );

      if (mounted) {
        Navigator.pop(context, competition);
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao criar competição: $e');
      debugPrint('StackTrace: $stackTrace');
      if (mounted) {
        SnackBarHelper.showError(context, 'Não foi possível criar o desafio. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                'Criar Desafio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Nome do desafio
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Desafio',
                  hintText: 'Ex: Desafio de Verao 2024',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do desafio';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição (opcional)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descricao (opcional)',
                  hintText: 'Descreva o desafio...',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Data de término
              Text(
                'Data de Termino',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectEndDate,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _endDate == null
                          ? Colors.grey.shade300
                          : Theme.of(context).primaryColor,
                      width: _endDate == null ? 1 : 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _endDate == null
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _endDate == null
                              ? 'Selecione a data'
                              : DateFormatter.format(_endDate!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _endDate == null
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color:
                                _endDate == null ? Colors.grey.shade600 : null,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Regra de vitória
              Text(
                'Regra de Vitoria',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _buildRuleOption(
                context,
                rule: VictoryRule.totalWeightLoss,
                title: 'Perda Total de Peso',
                description: 'Vence quem perder mais quilos',
                icon: Icons.fitness_center,
              ),
              const SizedBox(height: 8),
              _buildRuleOption(
                context,
                rule: VictoryRule.percentageLoss,
                title: 'Percentual Perdido',
                description: 'Vence quem perder maior % do peso inicial',
                icon: Icons.percent,
              ),
              const SizedBox(height: 24),

              // Botão criar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCompetition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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
                      : const Text(
                          'Criar Desafio',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleOption(
    BuildContext context, {
    required VictoryRule rule,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRule == rule;

    return InkWell(
      onTap: () => setState(() => _selectedRule = rule),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
