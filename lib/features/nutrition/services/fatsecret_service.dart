import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env_config.dart';

/// Resultado da busca de alimento no FatSecret
class FoodSearchResult {
  final String foodId;
  final String foodName;
  final String? brandName;
  final String foodDescription;

  const FoodSearchResult({
    required this.foodId,
    required this.foodName,
    this.brandName,
    required this.foodDescription,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) {
    return FoodSearchResult(
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      brandName: json['brand_name'],
      foodDescription: json['food_description'] ?? '',
    );
  }
}

/// Dados nutricionais de um alimento
class FoodNutrition {
  final String foodId;
  final String foodName;
  final String? brandName;
  final double servingSize;
  final String servingUnit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodNutrition({
    required this.foodId,
    required this.foodName,
    this.brandName,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodNutrition.fromJson(Map<String, dynamic> json) {
    // Pega a primeira serving disponível
    final servings = json['servings']?['serving'];
    Map<String, dynamic>? serving;

    if (servings is List && servings.isNotEmpty) {
      serving = servings[0] as Map<String, dynamic>;
    } else if (servings is Map<String, dynamic>) {
      serving = servings;
    }

    return FoodNutrition(
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      brandName: json['brand_name'],
      servingSize: double.tryParse(serving?['metric_serving_amount']?.toString() ?? '100') ?? 100,
      servingUnit: serving?['metric_serving_unit'] ?? 'g',
      calories: int.tryParse(serving?['calories']?.toString() ?? '0') ?? 0,
      protein: double.tryParse(serving?['protein']?.toString() ?? '0') ?? 0,
      carbs: double.tryParse(serving?['carbohydrate']?.toString() ?? '0') ?? 0,
      fat: double.tryParse(serving?['fat']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Service para integração com a API FatSecret
///
/// Responsável por:
/// - Autenticação OAuth 2.0 (Client Credentials)
/// - Buscar alimentos por nome
/// - Obter dados nutricionais completos
class FatSecretService {
  static const _tokenUrl = 'https://oauth.fatsecret.com/connect/token';
  static const _apiBaseUrl = 'https://platform.fatsecret.com/rest/server.api';

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Obtém um token de acesso OAuth 2.0
  Future<String> _getAccessToken() async {
    // Retorna token em cache se ainda válido
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final clientId = EnvConfig.fatsecretClientId;
    final clientSecret = EnvConfig.fatsecretClientSecret;

    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception('FatSecret credentials not configured');
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials&scope=basic',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get FatSecret access token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];

    // Token expira em expires_in segundos, guardamos com margem de 60s
    final expiresIn = data['expires_in'] as int? ?? 86400;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));

    return _accessToken!;
  }

  /// Busca alimentos por termo de pesquisa (em inglês)
  ///
  /// Retorna lista de resultados com nome, descrição e ID
  Future<List<FoodSearchResult>> searchFoods(String query, {int maxResults = 20}) async {
    debugPrint('[FatSecret] ───────────────────────────────────────────');
    debugPrint('[FatSecret] SEARCH: "$query"');

    if (query.trim().isEmpty) {
      debugPrint('⚠️ Query vazia');
      return [];
    }

    final token = await _getAccessToken();
    debugPrint('🔑 Token obtido');

    // Busca com region BR e language pt para resultados brasileiros
    final response = await http.post(
      Uri.parse(_apiBaseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'foods.search',
        'search_expression': query,
        'format': 'json',
        'max_results': maxResults.toString(),
        'region': 'BR',
        'language': 'pt',
      },
    );

    debugPrint('📡 Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('❌ Erro na busca: ${response.body}');
      throw Exception('Failed to search foods: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final foods = data['foods']?['food'];

    if (foods == null) {
      debugPrint('⚠️ Nenhum alimento encontrado para "$query"');
      return [];
    }

    // API retorna objeto único ou lista dependendo dos resultados
    List<FoodSearchResult> results = [];
    if (foods is List) {
      results = foods
          .map((f) => FoodSearchResult.fromJson(f as Map<String, dynamic>))
          .toList();
    } else if (foods is Map<String, dynamic>) {
      results = [FoodSearchResult.fromJson(foods)];
    }

    debugPrint('✅ Encontrados: ${results.length} resultados totais');

    // Filtra apenas alimentos genéricos (sem marca)
    final genericResults = results.where((r) => r.brandName == null || r.brandName!.isEmpty).toList();
    debugPrint('🏷️ Genéricos (sem marca): ${genericResults.length}');

    for (final r in genericResults.take(5)) {
      debugPrint('   → [${r.foodId}] ${r.foodName}');
    }

    return genericResults;
  }

  /// Obtém dados nutricionais completos de um alimento
  ///
  /// Usa o food_id obtido na busca
  Future<FoodNutrition?> getFoodNutrition(String foodId) async {
    debugPrint('🍎 GET NUTRITION para foodId: $foodId');

    if (foodId.isEmpty) {
      debugPrint('⚠️ foodId vazio');
      return null;
    }

    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse(_apiBaseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'food.get.v4',
        'food_id': foodId,
        'format': 'json',
        'region': 'BR',
        'language': 'pt',
      },
    );

    debugPrint('📡 Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('❌ Erro ao buscar nutrição: ${response.body}');
      throw Exception('Failed to get food nutrition: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final food = data['food'];

    if (food == null) {
      debugPrint('⚠️ food é null na resposta');
      return null;
    }

    debugPrint('📦 Food data keys: ${food.keys.toList()}');

    final nutrition = FoodNutrition.fromJson(food);
    debugPrint('[FatSecret] Nutrição: ${nutrition.calories} kcal per ${nutrition.servingSize}${nutrition.servingUnit}');

    return nutrition;
  }

  /// Busca o melhor resultado genérico e retorna seus dados nutricionais
  ///
  /// Estratégia:
  /// 1. Busca em inglês
  /// 2. Filtra apenas genéricos (já feito em searchFoods)
  /// 3. Prioriza match exato no nome
  Future<FoodNutrition?> searchAndGetNutrition(String queryEn) async {
    debugPrint('🔄 searchAndGetNutrition: "$queryEn"');

    final results = await searchFoods(queryEn);
    if (results.isEmpty) {
      debugPrint('⚠️ Nenhum resultado genérico para "$queryEn"');
      return null;
    }

    // Encontra o melhor match entre os genéricos
    final bestMatch = _findBestMatch(queryEn, results);
    debugPrint('🎯 Melhor match: [${bestMatch.foodId}] ${bestMatch.foodName}');

    return getFoodNutrition(bestMatch.foodId);
  }

  /// Encontra o melhor resultado baseado em similaridade com a query
  FoodSearchResult _findBestMatch(String query, List<FoodSearchResult> results) {
    final queryLower = query.toLowerCase();
    final queryWords = queryLower.split(' ');

    var bestScore = -1;
    var bestResult = results.first;

    for (final result in results) {
      var score = 0;
      final nameLower = result.foodName.toLowerCase();

      // +30 se nome é exatamente igual
      if (nameLower == queryLower) {
        score += 30;
      }
      // +20 se o nome começa com a query
      else if (nameLower.startsWith(queryLower)) {
        score += 20;
      }
      // +10 se a query está contida no nome
      else if (nameLower.contains(queryLower)) {
        score += 10;
      }

      // +5 para cada palavra da query presente no nome
      for (final word in queryWords) {
        if (word.length > 2 && nameLower.contains(word)) {
          score += 5;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestResult = result;
        debugPrint('   [${result.foodId}] ${result.foodName} → score: $score ★');
      }
    }

    return bestResult;
  }
}
