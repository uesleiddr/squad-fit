import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/env_config.dart';
import '../../../core/di/service_locator.dart';
import 'brazilian_food_service.dart';
import 'food_vector_store.dart';

/// Serviço de busca de alimentos usando RAG Avançado
///
/// Arquitetura:
/// ```
/// Query → [Query Expansion] → [Hybrid Search (Vector + Lexical)]
///                                     ↓
///                             Candidatos (top 50)
///                                     ↓
///                              [Re-Ranker + Metadata Boost]
///                                     ↓
///                             Resultados finais (top 10)
/// ```
///
/// Estratégias implementadas:
/// 1. **Hybrid Search**: Combina busca vetorial (semântica) + lexical (BM25-like)
/// 2. **Re-Ranking**: Reordena com metadata boost (categoria, preparação, match exato)
/// 3. **Query Expansion**: Expande query com sinônimos e variações
class RagFoodSearchService {
  final FoodVectorStore _vectorStore;
  final BrazilianFoodService _localService;

  GenerativeModel? _embeddingModel;
  bool? _lastConnectivityStatus;

  // Cache de embeddings para queries frequentes
  final Map<String, List<double>> _embeddingCache = {};
  static const int _maxCacheSize = 100;

  // Pesos para Hybrid Search
  static const double _vectorWeight = 0.7;
  static const double _lexicalWeight = 0.3;

  // Pesos para Re-Ranking
  static const double _exactMatchBonus = 0.15;
  static const double _categoryMatchBonus = 0.10;
  static const double _preparationMatchBonus = 0.08;
  static const double _simpleFoodBonus = 0.05;
  static const double _recipePenalty = 0.12;

  RagFoodSearchService({
    required FoodVectorStore vectorStore,
    required BrazilianFoodService localService,
  })  : _vectorStore = vectorStore,
        _localService = localService;

  /// Verifica se tem conexão com internet
  Future<bool> hasConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _lastConnectivityStatus = hasConnection;
      return hasConnection;
    } catch (_) {
      _lastConnectivityStatus = false;
      return false;
    }
  }

  /// Último status de conectividade conhecido
  bool get lastKnownConnectivity => _lastConnectivityStatus ?? false;

  /// Busca alimentos usando RAG Avançado (online) ou fallback local (offline)
  ///
  /// Pipeline:
  /// 1. Query Expansion
  /// 2. Hybrid Search (Vector + Lexical)
  /// 3. Re-Ranking com Metadata Boost
  Future<List<BrazilianFood>> search(
    String query, {
    int limit = 10,
    bool forceLocal = false,
  }) async {
    if (query.trim().length < 2) {
      return [];
    }

    final originalQuery = query.trim().toLowerCase();
    debugPrint('[RAG] ═══════════════════════════════════════');
    debugPrint('[RAG] Query: "$originalQuery"');

    // Verifica se deve usar busca semântica
    if (!forceLocal && await _shouldUseSemanticSearch()) {
      try {
        final results = await _advancedSearch(originalQuery, limit: limit);
        if (results.isNotEmpty) {
          debugPrint('[RAG] Resultados finais: ${results.length}');
          return results;
        }
        debugPrint('[RAG] Busca avançada sem resultados, usando fallback');
      } catch (e) {
        debugPrint('[RAG] Erro na busca avançada: $e');
      }
    }

    // Fallback: busca local tradicional
    debugPrint('[RAG] Usando busca local');
    return _localService.searchFoods(query, limit: limit);
  }

  /// Busca avançada com todas as estratégias
  Future<List<BrazilianFood>> _advancedSearch(
    String query, {
    required int limit,
  }) async {
    final stopwatch = Stopwatch()..start();

    // ═══════════════════════════════════════════════════════════════════════
    // ETAPA 1: QUERY EXPANSION
    // ═══════════════════════════════════════════════════════════════════════
    final expandedQueries = _expandQuery(query);
    debugPrint('[RAG] 1. Query Expansion: ${expandedQueries.length} variações');

    // ═══════════════════════════════════════════════════════════════════════
    // ETAPA 2: HYBRID SEARCH
    // ═══════════════════════════════════════════════════════════════════════
    final candidates = await _hybridSearch(
      originalQuery: query,
      expandedQueries: expandedQueries,
      candidateLimit: 50, // Busca mais candidatos para re-ranking
    );
    debugPrint('[RAG] 2. Hybrid Search: ${candidates.length} candidatos');

    if (candidates.isEmpty) {
      return [];
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ETAPA 3: RE-RANKING COM METADATA BOOST
    // ═══════════════════════════════════════════════════════════════════════
    final reranked = _rerank(candidates, query, expandedQueries);
    debugPrint('[RAG] 3. Re-Ranking aplicado');

    // Log top 5 resultados
    for (final result in reranked.take(5)) {
      debugPrint('[RAG]   ${result.finalScore.toStringAsFixed(3)} - ${result.food.name}');
    }

    stopwatch.stop();
    debugPrint('[RAG] Tempo total: ${stopwatch.elapsedMilliseconds}ms');

    return reranked.take(limit).map((r) => r.food).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUERY EXPANSION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Expande a query com sinônimos e variações
  List<String> _expandQuery(String query) {
    final expansions = <String>{query};
    final queryLower = query.toLowerCase();

    // Normaliza abreviações
    var normalized = queryLower
        .replaceAll('c/', 'com ')
        .replaceAll('s/', 'sem ')
        .replaceAll(' c ', ' com ')
        .replaceAll(' s ', ' sem ');
    expansions.add(normalized);

    // Sinônimos de proteínas
    if (queryLower.contains('frango')) {
      expansions.add(queryLower.replaceAll('frango', 'galinha'));
      expansions.add(queryLower.replaceAll('frango', 'ave'));
    }
    if (queryLower.contains('boi') || queryLower.contains('bovina')) {
      expansions.add(queryLower.replaceAll(RegExp(r'boi|bovina'), 'vaca'));
      expansions.add(queryLower.replaceAll(RegExp(r'boi|bovina'), 'carne'));
    }
    if (queryLower.contains('porco')) {
      expansions.add(queryLower.replaceAll('porco', 'suíno'));
    }

    // Sinônimos de preparação
    if (queryLower.contains('grelhado') || queryLower.contains('grelhada')) {
      expansions.add(queryLower.replaceAll(RegExp(r'grelha[do|da]'), 'na chapa'));
    }
    if (queryLower.contains('frito') || queryLower.contains('frita')) {
      expansions.add(queryLower.replaceAll(RegExp(r'frit[o|a]'), 'empanado'));
    }

    // Variações de formato
    if (queryLower.contains('peito de frango')) {
      expansions.add('frango peito');
      expansions.add('frango, peito');
    }
    if (queryLower.contains('ovo')) {
      expansions.add('ovo galinha');
      expansions.add('ovo, galinha');
    }

    // Adiciona contexto semântico para embedding
    expansions.add('alimento brasileiro: $query');

    return expansions.toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HYBRID SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  /// Combina busca vetorial (semântica) + busca lexical (BM25-like)
  Future<List<_HybridCandidate>> _hybridSearch({
    required String originalQuery,
    required List<String> expandedQueries,
    required int candidateLimit,
  }) async {
    // Executa busca vetorial e carregamento de dados locais em paralelo
    final futures = await Future.wait([
      _vectorSearch(expandedQueries, limit: candidateLimit),
      _localService.loadData().then((_) =>
          _lexicalSearch(originalQuery, expandedQueries, limit: candidateLimit)),
    ]);

    final vectorResults = futures[0];
    final lexicalResults = futures[1];

    // Combina resultados (Reciprocal Rank Fusion - RRF)
    return _fusionRanking(vectorResults, lexicalResults, candidateLimit);
  }

  /// Busca vetorial usando embeddings
  ///
  /// Otimização: usa apenas 1 embedding (query original) para reduzir latência
  Future<Map<String, double>> _vectorSearch(
    List<String> queries, {
    required int limit,
  }) async {
    final scores = <String, double>{};

    // Usa apenas a query original para minimizar chamadas à API
    // A busca semântica do pgvector já é boa o suficiente
    try {
      final embedding = await _getQueryEmbedding(queries.first);

      final results = await _vectorStore.search(
        embedding,
        topK: limit,
        minScore: 0.40,
      );

      for (final result in results) {
        scores[result.food.codigo] = result.score;
      }
    } catch (e) {
      debugPrint('[RAG] Erro na busca vetorial: $e');
    }

    return scores;
  }

  /// Busca lexical usando matching de termos (BM25-like simplificado)
  Map<String, double> _lexicalSearch(
    String originalQuery,
    List<String> expandedQueries,
    {required int limit}
  ) {
    final scores = <String, double>{};
    final allFoods = _localService.allFoods;

    // Extrai termos da query
    final queryTerms = _extractTerms(originalQuery);
    final expandedTerms = expandedQueries
        .expand((q) => _extractTerms(q))
        .toSet();

    for (final food in allFoods) {
      final foodTerms = _extractTerms(food.name.toLowerCase());

      double score = 0;

      // BM25-like scoring
      for (final term in queryTerms) {
        if (foodTerms.contains(term)) {
          // Termo exato
          score += 1.0;
        } else {
          // Partial match
          for (final foodTerm in foodTerms) {
            if (foodTerm.contains(term) || term.contains(foodTerm)) {
              score += 0.5;
              break;
            }
          }
        }
      }

      // Bonus para termos expandidos
      for (final term in expandedTerms) {
        if (foodTerms.contains(term) && !queryTerms.contains(term)) {
          score += 0.3;
        }
      }

      // Normaliza pelo número de termos
      if (queryTerms.isNotEmpty) {
        score = score / queryTerms.length;
      }

      // IDF-like: penaliza termos muito comuns
      if (food.name.toLowerCase().contains('sanduíche') ||
          food.name.toLowerCase().contains('preparada')) {
        score *= 0.7;
      }

      if (score > 0) {
        scores[food.codigo] = min(score, 1.0); // Normaliza para [0, 1]
      }
    }

    return scores;
  }

  /// Extrai termos relevantes de uma string
  Set<String> _extractTerms(String text) {
    final stopwords = {
      'de', 'da', 'do', 'em', 'com', 'sem', 'para', 'por', 'uma', 'um',
      'e', 'ou', 'a', 'o', 'as', 'os', 'que', 'na', 'no', 'nas', 'nos',
    };

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáéíóúãõâêîôûç]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !stopwords.contains(t))
        .toSet();
  }

  /// Fusão de rankings usando RRF (Reciprocal Rank Fusion)
  List<_HybridCandidate> _fusionRanking(
    Map<String, double> vectorScores,
    Map<String, double> lexicalScores,
    int limit,
  ) {
    final allIds = {...vectorScores.keys, ...lexicalScores.keys};
    final candidates = <_HybridCandidate>[];
    final allFoods = _localService.allFoods;

    for (final id in allIds) {
      final food = allFoods.firstWhere(
        (f) => f.codigo == id,
        orElse: () => BrazilianFood(
          codigo: id,
          name: 'Unknown',
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          source: '',
        ),
      );

      if (food.name == 'Unknown') continue;

      final vectorScore = vectorScores[id] ?? 0;
      final lexicalScore = lexicalScores[id] ?? 0;

      // Pontuação híbrida ponderada
      final hybridScore = (vectorScore * _vectorWeight) + (lexicalScore * _lexicalWeight);

      candidates.add(_HybridCandidate(
        food: food,
        vectorScore: vectorScore,
        lexicalScore: lexicalScore,
        hybridScore: hybridScore,
      ));
    }

    // Ordena por score híbrido
    candidates.sort((a, b) => b.hybridScore.compareTo(a.hybridScore));

    return candidates.take(limit).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RE-RANKING COM METADATA BOOST
  // ═══════════════════════════════════════════════════════════════════════════

  /// Re-ranking com boost baseado em metadados
  List<_RankedResult> _rerank(
    List<_HybridCandidate> candidates,
    String originalQuery,
    List<String> expandedQueries,
  ) {
    final queryLower = originalQuery.toLowerCase();
    final queryTerms = _extractTerms(queryLower);

    // Detecta intenção do usuário
    final wantsSimpleFood = !_isRecipeQuery(queryLower);
    final queryCategory = _detectCategory(queryLower);
    final queryPreparation = _detectPreparation(queryLower);

    final results = <_RankedResult>[];

    for (final candidate in candidates) {
      var boost = 0.0;
      final nameLower = candidate.food.name.toLowerCase();

      // 1. EXACT MATCH BONUS
      // Boost se todos os termos da query aparecem no nome
      final foodTerms = _extractTerms(nameLower);
      final matchingTerms = queryTerms.intersection(foodTerms);
      if (matchingTerms.length == queryTerms.length && queryTerms.isNotEmpty) {
        boost += _exactMatchBonus;
      }

      // 2. CATEGORY MATCH BONUS
      if (queryCategory != null) {
        final foodCategory = _detectCategory(nameLower);
        if (foodCategory == queryCategory) {
          boost += _categoryMatchBonus;
        }
      }

      // 3. PREPARATION MATCH BONUS
      if (queryPreparation != null && nameLower.contains(queryPreparation)) {
        boost += _preparationMatchBonus;
      }

      // 4. SIMPLE FOOD BONUS / RECIPE PENALTY
      final isRecipe = _isRecipeFood(nameLower);
      if (wantsSimpleFood) {
        if (isRecipe) {
          boost -= _recipePenalty;
        } else {
          boost += _simpleFoodBonus;
        }
      }

      // 5. NAME LENGTH PENALTY (nomes muito longos geralmente são receitas)
      if (nameLower.length > 60) {
        boost -= 0.03;
      }

      // 6. STARTS WITH QUERY BONUS
      if (nameLower.startsWith(queryTerms.firstOrNull ?? '')) {
        boost += 0.05;
      }

      final finalScore = (candidate.hybridScore + boost).clamp(0.0, 1.0);

      results.add(_RankedResult(
        food: candidate.food,
        vectorScore: candidate.vectorScore,
        lexicalScore: candidate.lexicalScore,
        hybridScore: candidate.hybridScore,
        boost: boost,
        finalScore: finalScore,
      ));
    }

    // Ordena pelo score final
    results.sort((a, b) => b.finalScore.compareTo(a.finalScore));

    return results;
  }

  /// Detecta se a query é para uma receita
  bool _isRecipeQuery(String query) {
    final recipeKeywords = [
      'sanduíche', 'sandwich', 'lanche', 'prato',
      'receita', 'preparado', 'comercial', 'restaurante',
    ];
    return recipeKeywords.any((k) => query.contains(k));
  }

  /// Detecta se o alimento é uma receita/prato composto
  bool _isRecipeFood(String name) {
    final recipeIndicators = [
      'sanduíche', 'hambúrguer', 'pizza', 'lasanha',
      'estrogonofe', 'yakisoba', 'marmita', 'prato',
      'preparada', 'preparado', 'comercial', 'fast food',
      'restaurante', 'lanchonete',
    ];
    return recipeIndicators.any((ind) => name.contains(ind));
  }

  /// Detecta categoria do alimento na query
  String? _detectCategory(String text) {
    if (text.contains('frango') || text.contains('galinha') || text.contains('ave')) {
      return 'frango';
    }
    if (text.contains('carne') || text.contains('boi') || text.contains('bovina')) {
      return 'bovina';
    }
    if (text.contains('porco') || text.contains('suíno')) {
      return 'suína';
    }
    if (text.contains('peixe') || text.contains('atum') || text.contains('salmão')) {
      return 'peixe';
    }
    if (text.contains('ovo')) {
      return 'ovo';
    }
    if (text.contains('arroz')) {
      return 'arroz';
    }
    if (text.contains('feijão')) {
      return 'feijão';
    }
    return null;
  }

  /// Detecta método de preparação na query
  String? _detectPreparation(String text) {
    if (text.contains('grelh')) return 'grelh';
    if (text.contains('frit')) return 'frit';
    if (text.contains('cozid')) return 'cozid';
    if (text.contains('assad')) return 'assad';
    if (text.contains('cru')) return 'cru';
    if (text.contains('refog')) return 'refog';
    if (text.contains('mexid')) return 'mexid';
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verifica se deve usar busca semântica
  Future<bool> _shouldUseSemanticSearch() async {
    // 1. Verifica conectividade (necessária para Supabase e Gemini)
    if (!await hasConnectivity()) {
      debugPrint('[RAG] Sem conexão, usando busca local');
      return false;
    }

    // 2. Verifica se a API key está configurada
    if (EnvConfig.geminiApiKey.isEmpty) {
      debugPrint('[RAG] API key não configurada, usando busca local');
      return false;
    }

    // 3. Vector store sempre disponível via Supabase
    return true;
  }

  /// Gera embedding para a query do usuário (com cache)
  Future<List<double>> _getQueryEmbedding(String query) async {
    final normalizedQuery = query.toLowerCase().trim();

    // Verifica cache primeiro
    if (_embeddingCache.containsKey(normalizedQuery)) {
      debugPrint('[RAG] Cache hit para "$normalizedQuery"');
      return _embeddingCache[normalizedQuery]!;
    }

    _embeddingModel ??= GenerativeModel(
      model: 'gemini-embedding-001',
      apiKey: EnvConfig.geminiApiKey,
    );

    final result = await _embeddingModel!.embedContent(
      Content.text(query),
    );

    final embedding = result.embedding.values;

    // Adiciona ao cache (limita tamanho)
    if (_embeddingCache.length >= _maxCacheSize) {
      _embeddingCache.remove(_embeddingCache.keys.first);
    }
    _embeddingCache[normalizedQuery] = embedding;

    return embedding;
  }

  /// Pré-carrega o vector store (no-op para Supabase)
  Future<void> preload() async {
    // No-op - dados são buscados diretamente do Supabase
  }

  /// Limpa cache e recursos
  void dispose() {
    _embeddingModel = null;
  }
}

/// Candidato da busca híbrida
class _HybridCandidate {
  final BrazilianFood food;
  final double vectorScore;
  final double lexicalScore;
  final double hybridScore;

  const _HybridCandidate({
    required this.food,
    required this.vectorScore,
    required this.lexicalScore,
    required this.hybridScore,
  });
}

/// Resultado após re-ranking
class _RankedResult {
  final BrazilianFood food;
  final double vectorScore;
  final double lexicalScore;
  final double hybridScore;
  final double boost;
  final double finalScore;

  const _RankedResult({
    required this.food,
    required this.vectorScore,
    required this.lexicalScore,
    required this.hybridScore,
    required this.boost,
    required this.finalScore,
  });
}

/// Factory para criar o RagFoodSearchService com dependências
RagFoodSearchService createRagFoodSearchService() {
  return RagFoodSearchService(
    vectorStore: getIt<FoodVectorStore>(),
    localService: getIt<BrazilianFoodService>(),
  );
}
