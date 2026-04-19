import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/di/service_locator.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/daily_summary.dart';
import '../models/meal_entry.dart';
import '../models/meal_item.dart';
import '../models/meal_type.dart';
import 'brazilian_food_service.dart';
import 'fatsecret_service.dart';
import 'gemini_nutrition_service.dart';

/// Service orquestrador para a feature de nutrição
///
/// Responsável por:
/// - Coordenar Gemini (parse) + BrazilianFood/FatSecret (nutrição) + Supabase (persistência)
/// - Gerenciar refeições do usuário
/// - Calcular resumos diários
///
/// Estratégia de busca nutricional:
/// 1. BrazilianFood (local) - base brasileira com 5.298 alimentos
/// 2. FatSecret (API) - fallback para industrializados/internacionais
class NutritionService {
  final _supabase = Supabase.instance.client;

  BrazilianFoodService get _brazilianFoodService => getIt<BrazilianFoodService>();
  FatSecretService get _fatSecretService => getIt<FatSecretService>();
  GeminiNutritionService get _geminiService => getIt<GeminiNutritionService>();

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Processa entrada de texto natural e salva como refeição
  ///
  /// Fluxo:
  /// 1. Gemini parseia o texto em itens estruturados
  /// 2. FatSecret busca dados nutricionais para cada item
  /// 3. Salva meal_entry + meal_items no Supabase
  Future<MealEntry> processMealInput({
    required String userInput,
    required MealType mealType,
    DateTime? recordedAt,
  }) async {
    dev.log('╔═══════════════════════════════════════════════════════════════╗', name: 'Nutrition');
    dev.log('║ PROCESSANDO REFEIÇÃO                                          ║', name: 'Nutrition');
    dev.log('╚═══════════════════════════════════════════════════════════════╝', name: 'Nutrition');
    dev.log('📝 Input: "$userInput"', name: 'Nutrition');
    dev.log('🍽️ Tipo: ${mealType.name}', name: 'Nutrition');

    if (_userId == null) {
      dev.log('❌ Usuário não autenticado', name: 'Nutrition');
      throw AuthException.notAuthenticated;
    }

    // 1. Parse do texto com Gemini
    dev.log('', name: 'Nutrition');
    dev.log('▶ ETAPA 1: Gemini Parse', name: 'Nutrition');
    final parsedItems = await _geminiService.parseNaturalText(userInput);

    dev.log('📋 Gemini retornou ${parsedItems.length} items', name: 'Nutrition');

    if (parsedItems.isEmpty) {
      dev.log('❌ Nenhum alimento identificado!', name: 'Nutrition');
      throw ValidationException('Não foi possível identificar alimentos no texto');
    }

    // 2. Busca dados nutricionais para cada item
    dev.log('', name: 'Nutrition');
    dev.log('▶ ETAPA 2: FatSecret Nutrition Lookup', name: 'Nutrition');

    final mealItems = <_TempMealItem>[];
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final parsed in parsedItems) {
      dev.log('', name: 'Nutrition');
      dev.log('🔍 Buscando: "${parsed.name}" (EN: ${parsed.nameEn}) qty: ${parsed.quantity}', name: 'Nutrition');

      // Estratégia: BrazilianFood primeiro (base local), FatSecret como fallback
      final brazilianFood = await _brazilianFoodService.searchFood(parsed.name, unit: parsed.unit);

      if (brazilianFood != null) {
        // BrazilianFood retorna valores por 100g, precisamos calcular baseado na quantidade do usuário
        final userUnit = parsed.unit?.toLowerCase() ?? 'unidade';
        double gramsAmount;

        if (_isWeightUnit(userUnit)) {
          gramsAmount = _convertToGrams(parsed.quantity, userUnit);
        } else {
          // Para unidades (ex: "1 pão"), estima gramas baseado no tipo de alimento
          gramsAmount = parsed.quantity * _estimateGramsPerUnit(parsed.name);
        }

        final multiplier = gramsAmount / 100.0;

        final itemCalories = (brazilianFood.calories * multiplier).round();
        final itemProtein = brazilianFood.protein * multiplier;
        final itemCarbs = brazilianFood.carbs * multiplier;
        final itemFat = brazilianFood.fat * multiplier;

        dev.log('✅ BrazilianFood: "${brazilianFood.name}" ${brazilianFood.calories} kcal/100g', name: 'Nutrition');
        dev.log('   User: ${parsed.quantity} $userUnit → ${gramsAmount.toStringAsFixed(0)}g → multiplier: ${multiplier.toStringAsFixed(2)} → $itemCalories kcal', name: 'Nutrition');

        mealItems.add(_TempMealItem(
          name: parsed.name,
          quantity: parsed.quantity,
          unit: parsed.unit ?? 'g',
          calories: itemCalories,
          protein: itemProtein,
          carbs: itemCarbs,
          fat: itemFat,
          fatsecretFoodId: null,
        ));

        totalCalories += itemCalories;
        totalProtein += itemProtein;
        totalCarbs += itemCarbs;
        totalFat += itemFat;
      } else {
        // Fallback: FatSecret para industrializados/internacionais
        dev.log('📡 BrazilianFood não encontrou, tentando FatSecret...', name: 'Nutrition');
        final nutrition = await _fatSecretService.searchAndGetNutrition(parsed.nameEn);

        if (nutrition != null) {
          double multiplier;
          final userUnit = parsed.unit?.toLowerCase() ?? 'unidade';
          final fsUnit = nutrition.servingUnit.toLowerCase();

          if (_unitsAreCompatible(userUnit, fsUnit)) {
            multiplier = parsed.quantity / nutrition.servingSize;
          } else {
            multiplier = parsed.quantity;
          }

          final itemCalories = (nutrition.calories * multiplier).round();
          final itemProtein = nutrition.protein * multiplier;
          final itemCarbs = nutrition.carbs * multiplier;
          final itemFat = nutrition.fat * multiplier;

          dev.log('✅ FatSecret: ${nutrition.calories} kcal per ${nutrition.servingSize}${nutrition.servingUnit}', name: 'Nutrition');
          dev.log('   User: ${parsed.quantity} $userUnit → multiplier: ${multiplier.toStringAsFixed(2)} → $itemCalories kcal', name: 'Nutrition');

          mealItems.add(_TempMealItem(
            name: parsed.name,
            quantity: parsed.quantity,
            unit: parsed.unit ?? nutrition.servingUnit,
            calories: itemCalories,
            protein: itemProtein,
            carbs: itemCarbs,
            fat: itemFat,
            fatsecretFoodId: nutrition.foodId,
          ));

          totalCalories += itemCalories;
          totalProtein += itemProtein;
          totalCarbs += itemCarbs;
          totalFat += itemFat;
        } else {
          dev.log('⚠️ NÃO ENCONTRADO em nenhuma fonte! Adicionando com 0 kcal', name: 'Nutrition');

          mealItems.add(_TempMealItem(
            name: parsed.name,
            quantity: parsed.quantity,
            unit: parsed.unit ?? 'unidade',
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fatsecretFoodId: null,
          ));
        }
      }
    }

    dev.log('', name: 'Nutrition');
    dev.log('📊 TOTAIS: $totalCalories kcal | P:${totalProtein.toStringAsFixed(1)}g | C:${totalCarbs.toStringAsFixed(1)}g | F:${totalFat.toStringAsFixed(1)}g', name: 'Nutrition');

    // 3. Salva no Supabase (meal_entry)
    final entryResponse = await _supabase.from('meal_entries').insert({
      'user_id': _userId,
      'meal_type': mealType.name,
      'description': userInput,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
    }).select().single();

    final entryId = entryResponse['id'] as String;

    // 4. Salva meal_items
    final itemsToInsert = mealItems.map((item) => {
      'meal_entry_id': entryId,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'calories': item.calories,
      'protein': item.protein,
      'carbs': item.carbs,
      'fat': item.fat,
      'fatsecret_food_id': item.fatsecretFoodId,
    }).toList();

    final itemsResponse = await _supabase
        .from('meal_items')
        .insert(itemsToInsert)
        .select();

    final savedItems = (itemsResponse as List)
        .map((json) => MealItem.fromJson(json))
        .toList();

    return MealEntry.fromJson(entryResponse, items: savedItems);
  }

  /// Busca refeições de uma data específica
  Future<List<MealEntry>> getMealsForDate(DateTime date) async {
    if (_userId == null) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('meal_entries')
        .select()
        .eq('user_id', _userId!)
        .gte('recorded_at', startOfDay.toIso8601String())
        .lt('recorded_at', endOfDay.toIso8601String())
        .order('recorded_at', ascending: true);

    final entries = <MealEntry>[];

    for (final entryJson in response) {
      // Busca items de cada entry
      final itemsResponse = await _supabase
          .from('meal_items')
          .select()
          .eq('meal_entry_id', entryJson['id']);

      final items = (itemsResponse as List)
          .map((json) => MealItem.fromJson(json))
          .toList();

      entries.add(MealEntry.fromJson(entryJson, items: items));
    }

    return entries;
  }

  /// Retorna resumo diário com totais e meta
  Future<DailySummary> getDailySummary(DateTime date) async {
    final meals = await getMealsForDate(date);
    final calorieGoal = await _getUserCalorieGoal();

    return DailySummary.fromMeals(
      date: date,
      meals: meals,
      calorieGoal: calorieGoal,
    );
  }

  /// Busca a meta de calorias do usuário
  Future<int> _getUserCalorieGoal() async {
    if (_userId == null) return 2000;

    final response = await _supabase
        .from('users')
        .select('calorie_goal')
        .eq('id', _userId!)
        .maybeSingle();

    return response?['calorie_goal'] as int? ?? 2000;
  }

  /// Atualiza a meta de calorias do usuário
  Future<void> updateCalorieGoal(int calories) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    if (calories < 500 || calories > 10000) {
      throw ValidationException('Meta de calorias deve estar entre 500 e 10.000');
    }

    await _supabase
        .from('users')
        .update({'calorie_goal': calories})
        .eq('id', _userId!);
  }

  /// Deleta uma refeição (e seus itens via CASCADE)
  Future<void> deleteMealEntry(String entryId) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    await _supabase.from('meal_entries').delete().eq('id', entryId);
  }

  /// Verifica se a unidade é de peso (g, kg)
  bool _isWeightUnit(String unit) {
    const weightUnits = ['g', 'kg', 'grama', 'gramas', 'quilograma', 'quilogramas'];
    return weightUnits.contains(unit.toLowerCase());
  }

  /// Converte quantidade para gramas
  double _convertToGrams(double quantity, String unit) {
    final u = unit.toLowerCase();
    if (u == 'kg' || u == 'quilograma' || u == 'quilogramas') {
      return quantity * 1000;
    }
    // g, grama, gramas
    return quantity;
  }

  /// Estima gramas por unidade baseado no tipo de alimento
  /// Valores aproximados para alimentos comuns brasileiros
  double _estimateGramsPerUnit(String foodName) {
    final name = foodName.toLowerCase();

    // Pães
    if (name.contains('pão francês') || name.contains('pao frances')) return 50;
    if (name.contains('pão de forma') || name.contains('pao de forma')) return 25;
    if (name.contains('pão') || name.contains('pao')) return 50;

    // Frutas
    if (name.contains('banana')) return 100;
    if (name.contains('maçã') || name.contains('maca')) return 150;
    if (name.contains('laranja')) return 180;
    if (name.contains('mamão') || name.contains('mamao')) return 150;

    // Ovos
    if (name.contains('ovo')) return 50;

    // Café/bebidas (assume ml ≈ g para líquidos)
    if (name.contains('café') || name.contains('cafe')) return 50;
    if (name.contains('leite')) return 200;

    // Carnes
    if (name.contains('frango') || name.contains('peito')) return 100;
    if (name.contains('carne') || name.contains('bife')) return 100;

    // Default: 100g por unidade
    return 100;
  }

  /// Verifica se duas unidades são compatíveis (mesma categoria)
  bool _unitsAreCompatible(String unit1, String unit2) {
    const volumeUnits = ['ml', 'l', 'litro', 'litros'];
    const weightUnits = ['g', 'kg', 'grama', 'gramas'];

    final u1 = unit1.toLowerCase();
    final u2 = unit2.toLowerCase();

    if (volumeUnits.contains(u1) && volumeUnits.contains(u2)) return true;
    if (weightUnits.contains(u1) && weightUnits.contains(u2)) return true;

    return false;
  }

  /// Stream de refeições do dia (atualização em tempo real)
  Stream<List<MealEntry>> getMealsForDateStream(DateTime date) {
    if (_userId == null) return Stream.value([]);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _supabase
        .from('meal_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('recorded_at', ascending: true)
        .map((data) {
          // Filtra por data no cliente (stream não suporta range queries)
          return data
              .where((entry) {
                final recordedAt = DateTime.parse(entry['recorded_at']);
                return recordedAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                       recordedAt.isBefore(endOfDay);
              })
              .map((json) => MealEntry.fromJson(json))
              .toList();
        });
  }
}

/// Classe temporária para construir MealItems antes de salvar
class _TempMealItem {
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? fatsecretFoodId;

  _TempMealItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fatsecretFoodId,
  });
}
