import 'package:flutter/material.dart';
import '../models/models.dart';

/// Modal para adicionar uma nova refeição
class AddMealModal extends StatefulWidget {
  const AddMealModal({super.key});

  /// Método estático para exibir o modal
  static Future<MealEntry?> show(BuildContext context) {
    return showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMealModal(),
    );
  }

  @override
  State<AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends State<AddMealModal> {
  final _descriptionController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _suggestMealType();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Sugere o tipo de refeição com base no horário atual
  MealType _suggestMealType() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return MealType.breakfast;
    } else if (hour >= 10 && hour < 14) {
      return MealType.lunch;
    } else if (hour >= 14 && hour < 18) {
      return MealType.snack;
    } else {
      return MealType.dinner;
    }
  }

  Future<void> _submitMeal() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva o que você comeu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Integrar com Gemini + FatSecret
      // Por enquanto, retorna um MealEntry mockado
      await Future.delayed(const Duration(seconds: 1)); // Simula processamento

      final now = DateTime.now();
      final mockEntry = MealEntry(
        id: 'mock_${now.millisecondsSinceEpoch}',
        userId: 'user1',
        mealType: _selectedMealType,
        description: description,
        totalCalories: 300, // Mock
        totalProtein: 15,
        totalCarbs: 30,
        totalFat: 10,
        items: [
          MealItem(
            id: 'item_${now.millisecondsSinceEpoch}',
            mealEntryId: 'mock_${now.millisecondsSinceEpoch}',
            name: description,
            quantity: 1,
            calories: 300,
            createdAt: now,
          ),
        ],
        recordedAt: now,
        createdAt: now,
      );

      if (mounted) {
        Navigator.of(context).pop(mockEntry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar: $e')),
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
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle do modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Adicionar Refeição',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Tipo de refeição
            Text(
              'Tipo de Refeição',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Chips de seleção
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((type) {
                final isSelected = type == _selectedMealType;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 18),
                      const SizedBox(width: 6),
                      Text(type.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedMealType = type);
                  },
                  selectedColor: colorScheme.secondaryContainer,
                  backgroundColor: colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Campo de descrição
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Descreva o que você comeu...\nEx: 2 ovos fritos com pão integral',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de registrar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMeal,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Registrar Refeição'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
