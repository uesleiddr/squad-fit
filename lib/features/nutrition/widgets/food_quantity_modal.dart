import 'package:flutter/material.dart';
import '../services/services.dart';

/// Item de alimento com quantidade definida pelo usuário
class FoodWithQuantity {
  final String name;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodWithQuantity({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

/// Modal para definir a quantidade do alimento selecionado
class FoodQuantityModal extends StatefulWidget {
  final BrazilianFood food;

  const FoodQuantityModal({super.key, required this.food});

  static Future<FoodWithQuantity?> show(
    BuildContext context,
    BrazilianFood food,
  ) {
    return showModalBottomSheet<FoodWithQuantity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodQuantityModal(food: food),
    );
  }

  @override
  State<FoodQuantityModal> createState() => _FoodQuantityModalState();
}

class _FoodQuantityModalState extends State<FoodQuantityModal> {
  late final TextEditingController _quantityController;
  late String _selectedUnit;

  // Unidades para sólidos
  static const _solidUnits = {
    'g': 1.0,
    'porção (50g)': 50.0,
    'unidade (30g)': 30.0,
    'fatia (25g)': 25.0,
    'colher sopa (15g)': 15.0,
    'colher chá (5g)': 5.0,
  };

  // Unidades para líquidos
  static const _liquidUnits = {
    'ml': 1.0,
    'xícara (200ml)': 200.0,
    'copo (250ml)': 250.0,
    'copo americano (190ml)': 190.0,
    'colher sopa (15ml)': 15.0,
  };

  Map<String, double> get _units => widget.food.isBeverage ? _liquidUnits : _solidUnits;

  @override
  void initState() {
    super.initState();
    // Define valores padrão baseado se é bebida ou não
    if (widget.food.isBeverage) {
      _quantityController = TextEditingController(text: '200');
      _selectedUnit = 'ml';
    } else {
      _quantityController = TextEditingController(text: '100');
      _selectedUnit = 'g';
    }
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 0;

  double get _gramsMultiplier {
    if (_selectedUnit == 'g' || _selectedUnit == 'ml') {
      return _quantity / 100;
    }
    final unitGrams = _units[_selectedUnit] ?? 1.0;
    return (_quantity * unitGrams) / 100;
  }

  double get _totalCalories => widget.food.calories * _gramsMultiplier;
  double get _totalProtein => widget.food.protein * _gramsMultiplier;
  double get _totalCarbs => widget.food.carbs * _gramsMultiplier;
  double get _totalFat => widget.food.fat * _gramsMultiplier;

  void _confirm() {
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida')),
      );
      return;
    }

    final result = FoodWithQuantity(
      name: widget.food.name,
      quantity: _quantity,
      unit: _selectedUnit,
      calories: _totalCalories,
      protein: _totalProtein,
      carbs: _totalCarbs,
      fat: _totalFat,
    );

    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nome do alimento
            Text(
              widget.food.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.food.calories.toStringAsFixed(0)} kcal/100g',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Quantidade
            Row(
              children: [
                // Campo de quantidade
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),

                // Dropdown de unidade
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        isDense: true,
                        items: _units.keys.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedUnit = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview nutricional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${_totalCalories.toStringAsFixed(0)} kcal',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MacroChip(
                        label: 'Proteína',
                        value: '${_totalProtein.toStringAsFixed(1)}g',
                        color: Colors.red.shade300,
                      ),
                      _MacroChip(
                        label: 'Carbs',
                        value: '${_totalCarbs.toStringAsFixed(1)}g',
                        color: Colors.amber.shade300,
                      ),
                      _MacroChip(
                        label: 'Gordura',
                        value: '${_totalFat.toStringAsFixed(1)}g',
                        color: Colors.blue.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão confirmar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _confirm,
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
