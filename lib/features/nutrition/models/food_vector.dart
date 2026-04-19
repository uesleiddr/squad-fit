import '../services/brazilian_food_service.dart';

/// Chunk de alimento preparado para embedding
///
/// Contém metadados extraídos do alimento original
/// e texto otimizado para geração de embedding
class FoodChunk {
  final String id;
  final String name;
  final String nameEn;
  final String searchText;
  final String category;
  final List<String> tags;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String source;

  const FoodChunk({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.searchText,
    required this.category,
    required this.tags,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.source,
  });

  /// Cria chunk a partir de dados brutos do JSON
  factory FoodChunk.fromRawData({
    required String id,
    required String name,
    String nameEn = '',
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String source,
  }) {
    final category = _extractCategory(name);
    final tags = _extractTags(name);
    final searchText = _generateSearchText(
      name: name,
      nameEn: nameEn,
      category: category,
      tags: tags,
    );

    return FoodChunk(
      id: id,
      name: name,
      nameEn: nameEn,
      searchText: searchText,
      category: category,
      tags: tags,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      source: source,
    );
  }

  /// Gera texto otimizado para embedding
  static String _generateSearchText({
    required String name,
    required String nameEn,
    required String category,
    required List<String> tags,
  }) {
    final parts = <String>[];

    // Nome simplificado (remove detalhes como "s/ óleo, s/ sal")
    parts.add(_simplifyName(name));

    // Nome em inglês (melhora semântica cross-language)
    if (nameEn.isNotEmpty) {
      parts.add(nameEn);
    }

    // Categoria
    parts.add(category);

    // Tags de preparação
    parts.addAll(tags);

    // Sinônimos comuns
    parts.addAll(_getSynonyms(name));

    return parts.join(' | ');
  }

  /// Simplifica nome removendo detalhes excessivos
  static String _simplifyName(String name) {
    return name
        .replaceAll(RegExp(r',?\s*s/\s*óleo', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*c/\s*óleo', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*s/\s*sal', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*c/\s*sal', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*s/\s*pele', caseSensitive: false), ', sem pele')
        .replaceAll(RegExp(r',?\s*c/\s*pele', caseSensitive: false), ', com pele')
        .replaceAll('Gallus gallus', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r',\s*,'), ',')
        .trim();
  }

  /// Extrai categoria do alimento
  static String _extractCategory(String name) {
    final nameLower = name.toLowerCase();

    // Proteínas
    if (nameLower.startsWith('carne') ||
        nameLower.startsWith('frango') ||
        nameLower.startsWith('peixe') ||
        nameLower.contains('boi') ||
        nameLower.contains('porco') ||
        nameLower.contains('camarão') ||
        nameLower.startsWith('ovo')) {
      return 'proteína';
    }

    // Carboidratos
    if (nameLower.startsWith('arroz') ||
        nameLower.startsWith('macarrão') ||
        nameLower.startsWith('pão') ||
        nameLower.startsWith('batata') ||
        nameLower.startsWith('mandioca')) {
      return 'carboidrato';
    }

    // Bebidas
    if (nameLower.contains('bebida') ||
        nameLower.contains('suco') ||
        nameLower.startsWith('leite') ||
        nameLower.contains('café') ||
        nameLower.contains('chá') ||
        nameLower.contains('refrigerante')) {
      return 'bebida';
    }

    // Vegetais
    if (nameLower.startsWith('salada') ||
        nameLower.contains('verdura') ||
        nameLower.contains('legume') ||
        nameLower.contains('alface') ||
        nameLower.contains('tomate') ||
        nameLower.contains('cenoura')) {
      return 'vegetal';
    }

    // Frutas
    if (nameLower.startsWith('fruta') ||
        nameLower.contains('maçã') ||
        nameLower.contains('banana') ||
        nameLower.contains('laranja') ||
        nameLower.contains('manga')) {
      return 'fruta';
    }

    // Laticínios
    if (nameLower.startsWith('queijo') ||
        nameLower.startsWith('iogurte') ||
        nameLower.contains('requeijão')) {
      return 'laticínio';
    }

    // Doces
    if (nameLower.contains('bolo') ||
        nameLower.contains('doce') ||
        nameLower.contains('chocolate') ||
        nameLower.contains('sorvete')) {
      return 'doce';
    }

    return 'outro';
  }

  /// Extrai tags de preparação e características
  static List<String> _extractTags(String name) {
    final tags = <String>[];
    final nameLower = name.toLowerCase();

    // Preparações
    if (nameLower.contains('grelh')) tags.add('grelhado');
    if (nameLower.contains('frit')) tags.add('frito');
    if (nameLower.contains('cozid')) tags.add('cozido');
    if (nameLower.contains('assad')) tags.add('assado');
    if (nameLower.contains('cru')) tags.add('cru');
    if (nameLower.contains('refog')) tags.add('refogado');
    if (nameLower.contains('mexid')) tags.add('mexido');
    if (nameLower.contains('empan')) tags.add('empanado');

    // Características
    if (nameLower.contains('integral')) tags.add('integral');
    if (nameLower.contains('light')) tags.add('light');
    if (nameLower.contains('diet')) tags.add('diet');
    if (nameLower.contains('sem pele') || nameLower.contains('s/ pele')) {
      tags.add('sem pele');
    }
    if (nameLower.contains('com pele') || nameLower.contains('c/ pele')) {
      tags.add('com pele');
    }
    if (nameLower.contains('desnatado')) tags.add('desnatado');
    if (nameLower.contains('sem lactose')) tags.add('sem lactose');

    // Partes de proteínas
    if (nameLower.contains('peito')) tags.add('peito');
    if (nameLower.contains('coxa')) tags.add('coxa');
    if (nameLower.contains('sobrecoxa')) tags.add('sobrecoxa');
    if (nameLower.contains('filé') || nameLower.contains('file')) tags.add('filé');
    if (nameLower.contains('inteiro')) tags.add('inteiro');

    return tags;
  }

  /// Retorna sinônimos comuns
  static List<String> _getSynonyms(String name) {
    final synonyms = <String>[];
    final nameLower = name.toLowerCase();

    // Sinônimos de proteínas
    if (nameLower.contains('frango')) {
      synonyms.addAll(['galinha', 'chicken', 'ave']);
    }
    if (nameLower.contains('boi') || nameLower.contains('carne, bovina')) {
      synonyms.addAll(['vaca', 'beef', 'bife']);
    }
    if (nameLower.contains('porco')) {
      synonyms.addAll(['suíno', 'pork']);
    }

    // Sinônimos de preparação
    if (nameLower.contains('grelh')) {
      synonyms.addAll(['na chapa', 'grilled']);
    }
    if (nameLower.contains('frit')) {
      synonyms.addAll(['fried', 'fritado']);
    }

    // Sinônimos de bebidas
    if (nameLower.contains('café')) {
      synonyms.addAll(['coffee', 'cafezinho']);
    }

    return synonyms;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'search_text': searchText,
        'category': category,
        'tags': tags,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'source': source,
      };
}

/// Vetor de alimento com embedding para busca semântica
class FoodVector {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String source;
  final List<double> embedding;

  const FoodVector({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.source,
    required this.embedding,
  });

  factory FoodVector.fromJson(Map<String, dynamic> json) {
    return FoodVector(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      source: json['source'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'source': source,
        'embedding': embedding,
      };

  /// Converte para BrazilianFood (para uso na UI)
  BrazilianFood toFood() => BrazilianFood(
        codigo: id,
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        source: source,
      );
}

/// Resultado de busca vetorial com score de similaridade
class VectorSearchResult {
  final BrazilianFood food;
  final double score;

  const VectorSearchResult({
    required this.food,
    required this.score,
  });

  @override
  String toString() => 'VectorSearchResult(${food.name}, score: ${score.toStringAsFixed(3)})';
}
