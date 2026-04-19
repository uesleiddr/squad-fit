import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dados nutricionais de um alimento da base brasileira
class BrazilianFood {
  final String codigo;
  final String name;
  final String nameEn;
  final double calories; // kcal per 100g
  final double protein; // g per 100g
  final double carbs; // g per 100g
  final double fat; // g per 100g
  final String source; // 'foods' ou 'taco'

  const BrazilianFood({
    required this.codigo,
    required this.name,
    this.nameEn = '',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.source,
  });

  /// Verifica se o alimento é uma bebida (para usar ml como unidade padrão)
  bool get isBeverage {
    final nameLower = name.toLowerCase();
    return nameLower.contains('bebida') ||
        nameLower.contains('suco') ||
        nameLower.contains('leite') ||
        nameLower.contains('café') ||
        nameLower.contains('chá') ||
        nameLower.contains('infusão') ||
        nameLower.contains('refrigerante') ||
        nameLower.contains('água') ||
        nameLower.contains('vitamina') ||
        nameLower.contains('cappuccino') ||
        nameLower.contains('shake');
  }

  @override
  String toString() => 'BrazilianFood($name: ${calories}kcal/100g [$source])';
}

/// Classe auxiliar para ordenação por score
class _ScoredFood {
  final BrazilianFood food;
  final int score;

  _ScoredFood({required this.food, required this.score});
}

/// Service para busca de alimentos nas bases brasileiras (local)
///
/// Estratégia de busca em 3 níveis:
/// 1. foods.json (5.298 alimentos) - preparações e receitas
/// 2. taco.json (597 alimentos) - tabela oficial UNICAMP
/// 3. FatSecret (externo) - fallback para industrializados
class BrazilianFoodService {
  List<BrazilianFood>? _allFoods;
  bool _isLoaded = false;

  /// Carrega os dados de ambos os JSONs
  Future<void> _loadData() async {
    if (_isLoaded) return;

    final allFoods = <BrazilianFood>[];

    // 1. Carrega foods.json (base principal com preparações)
    try {
      final jsonString = await rootBundle.loadString('assets/data/foods.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      for (final entry in data.entries) {
        final code = entry.key;
        final foodData = entry.value as Map<String, dynamic>;
        final nutrients = foodData['nutrients'] as Map<String, dynamic>? ?? {};

        allFoods.add(BrazilianFood(
          codigo: code,
          name: foodData['name'] ?? '',
          nameEn: foodData['name_en'] ?? '',
          calories: _extractNutrientFromMap(nutrients, 'Energia'),
          protein: _extractNutrientFromMap(nutrients, 'Proteína'),
          carbs: _extractNutrientFromMap(nutrients, 'Carboidrato total'),
          fat: _extractNutrientFromMap(nutrients, 'Lipídios'),
          source: 'foods',
        ));
      }
      debugPrint('[BrazilianFood] ✅ foods.json: ${data.length} alimentos');
    } catch (e) {
      debugPrint('[BrazilianFood] ❌ Erro foods.json: $e');
    }

    // 2. Carrega taco.json (tabela oficial UNICAMP)
    try {
      final jsonString = await rootBundle.loadString('assets/data/taco.json');
      final List<dynamic> data = jsonDecode(jsonString);

      for (final item in data) {
        final kcal = item['energy_kcal'];
        final protein = item['protein_g'];
        final carbs = item['carbohydrate_g'];
        final fat = item['lipid_g'];

        allFoods.add(BrazilianFood(
          codigo: 'TACO_${item['id']}',
          name: item['description'] ?? '',
          nameEn: '',
          calories: _parseDouble(kcal),
          protein: _parseDouble(protein),
          carbs: _parseDouble(carbs),
          fat: _parseDouble(fat),
          source: 'taco',
        ));
      }
      debugPrint('[BrazilianFood] ✅ taco.json: ${data.length} alimentos');
    } catch (e) {
      debugPrint('[BrazilianFood] ❌ Erro taco.json: $e');
    }

    _allFoods = allFoods;
    _isLoaded = true;
    debugPrint('[BrazilianFood] ✅ Total: ${_allFoods!.length} alimentos carregados');
  }

  /// Extrai valor de nutriente do formato foods.json
  double _extractNutrientFromMap(Map<String, dynamic> nutrients, String name) {
    final nutrient = nutrients[name];
    if (nutrient == null) return 0;
    if (nutrient is Map) {
      final value = nutrient['value'];
      if (value is num) return value.toDouble();
    }
    return 0;
  }

  /// Converte valor que pode ser String, num ou "NA"/"Tr"
  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value == 'NA' || value == 'Tr' || value.isEmpty) return 0;
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Busca alimentos pelo nome (busca fuzzy em ambas as bases)
  ///
  /// [query] - nome do alimento em português
  /// [unit] - unidade (ml, g, un, fatia, etc.) para ajudar na busca
  Future<BrazilianFood?> searchFood(String query, {String? unit}) async {
    await _loadData();

    if (_allFoods == null || _allFoods!.isEmpty) {
      debugPrint('[BrazilianFood] Base de dados vazia');
      return null;
    }

    final queryLower = _normalizeText(query);
    final mainFood = _extractMainFood(queryLower);
    final queryWords = queryLower.split(' ').where((w) => w.length > 2).toList();
    final isLiquid = unit != null && ['ml', 'l', 'litro', 'litros'].contains(unit.toLowerCase());

    debugPrint('[BrazilianFood] 🔍 Buscando: "$query" (principal: "$mainFood", líquido: $isLiquid)');

    BrazilianFood? bestMatch;
    int bestScore = 0;

    for (final food in _allFoods!) {
      final nameLower = _normalizeText(food.name);
      final nameWords = nameLower.split(' ').where((w) => w.length > 2).toList();
      final firstWord = nameWords.isNotEmpty ? nameWords.first : nameLower;
      var score = 0;

      // Match exato
      if (nameLower == queryLower) {
        score += 100;
      }
      // Nome começa com a query (ex: "açúcar" -> "Açúcar, cristal")
      else if (nameLower.startsWith(queryLower) || firstWord == queryLower) {
        score += 80;
      }
      // Primeira palavra do nome == query principal
      else if (firstWord == mainFood) {
        score += 70;
      }
      // Nome contém a query completa
      else if (nameLower.contains(queryLower)) {
        score += 50;
      }
      // Query contém o nome principal do alimento
      else if (queryLower.contains(firstWord)) {
        score += 40;
      }

      // Pontos por palavras individuais (menor peso)
      for (final word in queryWords) {
        if (nameLower.contains(word)) {
          score += 5;
        }
      }

      // Bônus se o nome contém o alimento principal
      if (mainFood.isNotEmpty && nameLower.contains(mainFood)) {
        score += 15;
      }

      // Bônus para "inteiro" quando busca ovo/frango genérico
      if (nameLower.contains('inteiro') &&
          (mainFood == 'ovo' || mainFood == 'frango')) {
        score += 15;
      }

      // Penalidade para partes específicas (clara, gema) quando não mencionado
      if (nameLower.contains('clara') && !queryLower.contains('clara')) {
        score -= 20;
      }
      if (nameLower.contains('gema') && !queryLower.contains('gema')) {
        score -= 20;
      }

      // Bônus para preparações específicas
      if (queryLower.contains('mexido') && nameLower.contains('mexido')) {
        score += 30;
      }
      if (queryLower.contains('frito') && nameLower.contains('frito')) {
        score += 30;
      }
      if (queryLower.contains('cozido') && nameLower.contains('cozido')) {
        score += 30;
      }
      if (queryLower.contains('grelhado') && nameLower.contains('grelhado')) {
        score += 30;
      }

      // Bônus para alimentos cozidos/preparados (mais comum que cru)
      if (!queryLower.contains('cru')) {
        if (nameLower.contains('cozid')) score += 5;
        if (nameLower.contains('frit')) score += 3;
        if (nameLower.contains('grelh')) score += 3;
      }

      // Penalidade para nomes muito longos (receitas complexas vs ingredientes puros)
      // "Açúcar, cristal" (curto) deve ganhar de "Pizza... açúcar..." (longo)
      if (nameLower.length > 80) {
        score -= 30;
      } else if (nameLower.length > 50) {
        score -= 15;
      }

      // Para líquidos (ml), priorizar "Bebida" e penalizar "em pó"
      if (isLiquid) {
        if (nameLower.contains('bebida')) {
          score += 40;
        }
        if (nameLower.contains('em po') || nameLower.contains('po ')) {
          score -= 50;
        }
        if (nameLower.contains('infusao')) {
          score += 20;
        }
      }

      // Pequeno bônus para fonte foods (tem mais preparações)
      if (food.source == 'foods') {
        score += 2;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = food;
      }
    }

    // Só retorna se score mínimo de 20
    if (bestScore >= 20 && bestMatch != null) {
      debugPrint('[BrazilianFood] ✅ [${bestMatch.source}] "${bestMatch.name}" (score: $bestScore, ${bestMatch.calories} kcal/100g)');
      return bestMatch;
    }

    debugPrint('[BrazilianFood] ❌ Nenhum match para "$query" (melhor score: $bestScore)');
    return null;
  }

  /// Busca alimentos para autocomplete (retorna múltiplos resultados)
  ///
  /// [query] - termo de busca (mínimo 2 caracteres)
  /// [limit] - número máximo de resultados (padrão 10)
  Future<List<BrazilianFood>> searchFoods(String query, {int limit = 10}) async {
    await _loadData();

    if (_allFoods == null || _allFoods!.isEmpty || query.length < 2) {
      return [];
    }

    final queryLower = _normalizeText(query);
    // Filtra palavras com 3+ caracteres (ignora "de", "com", "e", etc.)
    final queryWords = queryLower.split(' ').where((w) => w.length >= 3).toList();
    // Converte palavras de preparação para stems (raiz) para match de gênero
    final queryStems = queryWords.map((w) => _toStem(w)).toList();

    // Detecta se usuário quer ingrediente simples ou receita
    final wantsSimpleIngredient = !_isRecipeQuery(queryLower);

    final results = <_ScoredFood>[];

    for (final food in _allFoods!) {
      final nameLower = _normalizeText(food.name);
      var score = 0;

      // Match exato
      if (nameLower == queryLower) {
        score = 100;
      }
      // Nome começa com a query completa
      else if (nameLower.startsWith(queryLower)) {
        score = 90;
      }
      // Nome contém a query completa
      else if (nameLower.contains(queryLower)) {
        score = 70;
      }

      // Pontos por cada palavra/stem da query encontrada no nome
      int matchedWords = 0;
      for (int i = 0; i < queryWords.length; i++) {
        final word = queryWords[i];
        final stem = queryStems[i];

        if (nameLower.contains(word)) {
          matchedWords++;
          score += 25;
        } else if (stem != word && nameLower.contains(stem)) {
          matchedWords++;
          score += 20;
        }
      }

      // Bônus se TODAS as palavras foram encontradas
      if (queryWords.isNotEmpty && matchedWords == queryWords.length) {
        score += 50;
      }

      // Se não encontrou nenhuma palavra, pula
      if (score == 0) continue;

      // === PENALIZAÇÕES PARA RECEITAS/COMPOSTOS ===
      if (wantsSimpleIngredient) {
        // Penalidade MUITO forte para sanduíches, pizzas, lasanhas, etc.
        if (_isRecipeFood(nameLower)) {
          score -= 100;
        }

        // Bônus para ingredientes puros (começam com categoria)
        if (nameLower.startsWith('carne') ||
            nameLower.startsWith('frango') ||
            nameLower.startsWith('peixe') ||
            nameLower.startsWith('ovo') ||
            nameLower.startsWith('arroz') ||
            nameLower.startsWith('feijao') ||
            nameLower.startsWith('leite') ||
            nameLower.startsWith('queijo') ||
            nameLower.startsWith('pao') ||
            nameLower.startsWith('fruta') ||
            nameLower.startsWith('legume') ||
            nameLower.startsWith('verdura') ||
            nameLower.startsWith('bebida') ||
            nameLower.startsWith('linguica') ||
            nameLower.startsWith('hamburguer')) {
          score += 40;
        }

        // Bônus extra para nomes curtos (ingredientes simples)
        if (nameLower.length <= 40) {
          score += 30;
        } else if (nameLower.length <= 60) {
          score += 15;
        } else if (nameLower.length > 80) {
          score -= 30;
        }
      }

      // Para bebidas, priorizar "Bebida" e penalizar "em pó"
      if (_isBeverageQuery(queryLower)) {
        if (nameLower.contains('bebida') || nameLower.contains('infusao')) {
          score += 40;
        }
        if (nameLower.contains('em po') || nameLower.contains(' po ') || nameLower.endsWith(' po')) {
          score -= 50;
        }
      }

      if (score > 0) {
        results.add(_ScoredFood(food: food, score: score));
      }
    }

    // Ordena por score decrescente
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).map((s) => s.food).toList();
  }

  /// Verifica se a query parece buscar uma receita/prato composto
  bool _isRecipeQuery(String query) {
    const recipeTerms = [
      'sanduiche', 'sandwich', 'pizza', 'lasanha', 'torta', 'bolo',
      'salpicao', 'salada de', 'prato', 'refeicao', 'marmita',
      'wrap', 'tapioca recheada', 'crepe', 'panqueca', 'omelete',
    ];
    for (final term in recipeTerms) {
      if (query.contains(term)) return true;
    }
    return false;
  }

  /// Verifica se o nome do alimento é uma receita/prato composto
  bool _isRecipeFood(String name) {
    const recipeIndicators = [
      'sanduiche', 'sandwich', 'pizza', 'lasanha', 'torta', 'bolo',
      'salpicao', 'salada de', 'papa de', 'sopa de', 'caldo de',
      'risoto', 'estrogonofe', 'escondidinho', 'empadao', 'quiche',
      'wrap', 'burrito', 'taco', 'panqueca', 'crepe',
    ];
    for (final indicator in recipeIndicators) {
      if (name.startsWith(indicator) || name.contains(' $indicator')) {
        return true;
      }
    }
    return false;
  }

  /// Converte palavras de preparação para stem (raiz) para ignorar gênero
  /// "grelhado" -> "grelh", "frita" -> "frit", "cozido" -> "cozid"
  String _toStem(String word) {
    // Preparações culinárias - remove sufixos de gênero
    const preparations = {
      'grelhado': 'grelh', 'grelhada': 'grelh', 'grelhados': 'grelh', 'grelhadas': 'grelh',
      'frito': 'frit', 'frita': 'frit', 'fritos': 'frit', 'fritas': 'frit',
      'cozido': 'cozid', 'cozida': 'cozid', 'cozidos': 'cozid', 'cozidas': 'cozid',
      'assado': 'assad', 'assada': 'assad', 'assados': 'assad', 'assadas': 'assad',
      'refogado': 'refog', 'refogada': 'refog', 'refogados': 'refog', 'refogadas': 'refog',
      'mexido': 'mexid', 'mexida': 'mexid', 'mexidos': 'mexid', 'mexidas': 'mexid',
      'cru': 'cru', 'crua': 'cru', 'crus': 'cru', 'cruas': 'cru',
      'inteiro': 'inteir', 'inteira': 'inteir', 'inteiros': 'inteir', 'inteiras': 'inteir',
    };
    return preparations[word] ?? word;
  }

  /// Verifica se a query é uma bebida comum
  bool _isBeverageQuery(String query) {
    const beverages = [
      'cafe', 'cha', 'suco', 'leite', 'refrigerante', 'agua',
      'cerveja', 'vinho', 'cappuccino', 'capuccino', 'achocolatado',
      'vitamina', 'shake', 'smoothie', 'energetico', 'isotônico',
    ];
    for (final beverage in beverages) {
      if (query.contains(beverage)) {
        return true;
      }
    }
    return false;
  }

  /// Extrai o alimento principal removendo preparações
  String _extractMainFood(String query) {
    final preparations = [
      'mexido', 'mexida', 'cozido', 'cozida', 'frito', 'frita',
      'assado', 'assada', 'grelhado', 'grelhada', 'refogado', 'refogada'
    ];
    var result = query;
    for (final prep in preparations) {
      result = result.replaceAll(prep, '').trim();
    }
    final words = result.split(' ').where((w) => w.length > 2).toList();
    return words.isNotEmpty ? words.first : query;
  }

  /// Normaliza texto removendo acentos e convertendo para minúsculo
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('à', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(',', ' ')
        .replaceAll('.', '')
        .trim();
  }
}
