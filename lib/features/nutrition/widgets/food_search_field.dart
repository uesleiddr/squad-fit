import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../services/services.dart';

/// Callback quando um alimento é selecionado
typedef OnFoodSelected = void Function(BrazilianFood food);

/// Campo de busca com autocomplete para alimentos brasileiros
class FoodSearchField extends StatefulWidget {
  final OnFoodSelected onFoodSelected;
  final String? hintText;

  const FoodSearchField({
    super.key,
    required this.onFoodSelected,
    this.hintText,
  });

  @override
  State<FoodSearchField> createState() => _FoodSearchFieldState();
}

class _FoodSearchFieldState extends State<FoodSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _ragService = getIt<RagFoodSearchService>();

  List<BrazilianFood> _suggestions = [];
  bool _isLoading = false;
  bool _isOnline = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final online = await _ragService.hasConnectivity();
    if (mounted) {
      setState(() => _isOnline = online);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchFoods(query);
    });
  }

  Future<void> _searchFoods(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Usa RAG service (automático: semântico online, local offline)
      final results = await _ragService.search(query, limit: 8);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
          _isOnline = _ragService.lastKnownConnectivity;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  void _selectFood(BrazilianFood food) {
    _controller.clear();
    setState(() => _suggestions = []);
    _focusNode.unfocus();
    widget.onFoodSelected(food);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campo de busca
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Buscar alimento...',
            prefixIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.search),
                // Indicador de modo (online/offline)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _suggestions = []);
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Lista de sugestões
        if (_suggestions.isNotEmpty || (_controller.text.length >= 2 && !_isLoading))
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    // Resultados
                    ..._suggestions.map((food) => _FoodSuggestionTile(
                          food: food,
                          onTap: () => _selectFood(food),
                        )),

                    // Mensagem se não encontrou
                    if (_suggestions.isEmpty && _controller.text.length >= 2)
                      ListTile(
                        leading: Icon(
                          Icons.search_off,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          'Nenhum alimento encontrado',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tile de sugestão de alimento
class _FoodSuggestionTile extends StatelessWidget {
  final BrazilianFood food;
  final VoidCallback onTap;

  const _FoodSuggestionTile({
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.restaurant,
          color: colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        food.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${food.calories.toStringAsFixed(0)} kcal/100g • P: ${food.protein.toStringAsFixed(0)}g • C: ${food.carbs.toStringAsFixed(0)}g • G: ${food.fat.toStringAsFixed(0)}g',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.add_circle_outline,
        color: colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
