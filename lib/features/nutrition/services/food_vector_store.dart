import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_vector.dart';
import 'brazilian_food_service.dart';

/// Vector Store para busca semântica de alimentos usando Supabase pgvector
///
/// Realiza buscas por similaridade de cosseno no banco de dados,
/// eliminando a necessidade de carregar vetores na memória do app.
class FoodVectorStore {
  final SupabaseClient _supabase;

  FoodVectorStore({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Verifica se o vector store está disponível
  bool get isLoaded => true; // Sempre disponível via Supabase

  /// Retorna contagem de vetores no banco
  Future<int> getCount() async {
    try {
      final response = await _supabase
          .from('food_vectors')
          .select('id')
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('[VectorStore] Erro ao contar vetores: $e');
      return 0;
    }
  }

  /// Para compatibilidade - não precisa mais carregar
  @Deprecated('Vetores são buscados diretamente do Supabase')
  Future<void> load() async {
    // No-op - mantido para compatibilidade
  }

  /// Busca os K alimentos mais similares à query usando pgvector
  ///
  /// [queryEmbedding] - Embedding da query do usuário (3072 dimensões)
  /// [topK] - Número máximo de resultados (padrão: 10)
  /// [minScore] - Score mínimo de similaridade (padrão: 0.5)
  /// [category] - Filtro opcional por categoria
  ///
  /// Retorna lista ordenada por similaridade decrescente
  Future<List<VectorSearchResult>> search(
    List<double> queryEmbedding, {
    int topK = 10,
    double minScore = 0.5,
    String? category,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Chama a função RPC search_foods no Supabase
      final response = await _supabase.rpc(
        'search_foods',
        params: {
          'query_embedding': queryEmbedding,
          'match_threshold': minScore,
          'match_count': topK,
          'filter_category': category,
        },
      );

      final results = (response as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        return VectorSearchResult(
          food: BrazilianFood(
            codigo: map['id'] as String,
            name: map['name'] as String,
            calories: (map['calories'] as num?)?.toDouble() ?? 0,
            protein: (map['protein'] as num?)?.toDouble() ?? 0,
            carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
            fat: (map['fat'] as num?)?.toDouble() ?? 0,
            source: map['source'] as String? ?? '',
          ),
          score: (map['similarity'] as num).toDouble(),
        );
      }).toList();

      stopwatch.stop();
      debugPrint(
          '[VectorStore] Busca pgvector: ${results.length} resultados em ${stopwatch.elapsedMilliseconds}ms');

      return results;
    } catch (e) {
      debugPrint('[VectorStore] Erro na busca: $e');
      return [];
    }
  }

  /// Busca usando múltiplos embeddings (para queries expandidas)
  ///
  /// Executa múltiplas buscas e combina os resultados usando o maior score
  Future<List<VectorSearchResult>> searchMultiple(
    List<List<double>> queryEmbeddings, {
    int topK = 10,
    double minScore = 0.5,
    String? category,
  }) async {
    if (queryEmbeddings.isEmpty) return [];

    // Executa buscas em paralelo
    final futures = queryEmbeddings.map(
      (embedding) => search(
        embedding,
        topK: topK,
        minScore: minScore,
        category: category,
      ),
    );

    final allResults = await Future.wait(futures);

    // Combina resultados usando maior score por alimento
    final scoreMap = <String, VectorSearchResult>{};

    for (final results in allResults) {
      for (final result in results) {
        final existing = scoreMap[result.food.codigo];
        if (existing == null || result.score > existing.score) {
          scoreMap[result.food.codigo] = result;
        }
      }
    }

    // Ordena por score decrescente
    final combined = scoreMap.values.toList();
    combined.sort((a, b) => b.score.compareTo(a.score));

    return combined.take(topK).toList();
  }

  /// Busca direta por categoria (sem embedding)
  ///
  /// Útil para listagens e filtros rápidos
  Future<List<BrazilianFood>> searchByCategory(
    String category, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('food_vectors')
          .select('id, name, calories, protein, carbs, fat, source')
          .eq('category', category)
          .limit(limit);

      return (response as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        return BrazilianFood(
          codigo: map['id'] as String,
          name: map['name'] as String,
          calories: (map['calories'] as num?)?.toDouble() ?? 0,
          protein: (map['protein'] as num?)?.toDouble() ?? 0,
          carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
          fat: (map['fat'] as num?)?.toDouble() ?? 0,
          source: map['source'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[VectorStore] Erro ao buscar por categoria: $e');
      return [];
    }
  }

  /// Lista todas as categorias disponíveis
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('food_vectors')
          .select('category')
          .not('category', 'is', null);

      final categories = (response as List<dynamic>)
          .map((item) => (item as Map<String, dynamic>)['category'] as String?)
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      debugPrint('[VectorStore] Erro ao listar categorias: $e');
      return [];
    }
  }

  /// Limpa cache (no-op para Supabase)
  void clear() {
    // No-op - dados estão no Supabase
  }
}
