import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/env_config.dart';

/// Item de alimento parseado pelo Gemini
class ParsedFoodItem {
  final String name;
  final String nameEn; // Nome em inglês para busca na API
  final double quantity;
  final String? unit;

  const ParsedFoodItem({
    required this.name,
    required this.nameEn,
    required this.quantity,
    this.unit,
  });

  factory ParsedFoodItem.fromJson(Map<String, dynamic> json) {
    return ParsedFoodItem(
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      quantity: (json['quantity'] ?? 1).toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'name_en': nameEn,
        'quantity': quantity,
        'unit': unit,
      };

  @override
  String toString() => 'ParsedFoodItem(name: $name, nameEn: $nameEn, quantity: $quantity, unit: $unit)';
}

/// Service para parsing de texto natural usando Gemini
///
/// Responsável por:
/// - Receber texto natural do usuário (ex: "comi 2 ovos e 1 pão")
/// - Retornar lista estruturada de alimentos com quantidades
class GeminiNutritionService {
  GenerativeModel? _model;

  GenerativeModel get _geminiModel {
    if (_model == null) {
      final apiKey = EnvConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Gemini API key not configured');
      }
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          maxOutputTokens: 8192,
        ),
      );
    }
    return _model!;
  }

  /// Prompt do sistema para o Gemini - formato minificado obrigatório
  static const _systemPrompt = '''
Parse alimentos PT-BR→EN. JSON minificado, sem espaços.
Ex: "2 ovos e pão"→[{"name":"ovo","name_en":"egg","quantity":2,"unit":"un"},{"name":"pão","name_en":"bread","quantity":1,"unit":"un"}]''';

  /// Transforma texto natural em lista estruturada de alimentos
  Future<List<ParsedFoodItem>> parseNaturalText(String userInput) async {
    debugPrint('[Gemini] ═══════════════════════════════════════════');
    debugPrint('[Gemini] INPUT: "$userInput"');

    if (userInput.trim().isEmpty) {
      debugPrint('[Gemini] Input vazio, retornando []');
      return [];
    }

    try {
      // Prompt compacto para evitar respostas longas
      final prompt = '$_systemPrompt\nTexto: "$userInput"\nJSON:';

      debugPrint('[Gemini] Enviando para Gemini...');
      final response = await _geminiModel.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      debugPrint('[Gemini] Resposta bruta: "$text"');
      debugPrint('[Gemini] Tamanho resposta: ${text.length} chars');

      if (text.isEmpty) {
        debugPrint('[Gemini] Resposta vazia do Gemini');
        return [];
      }

      // Remove possíveis marcadores de código markdown
      var jsonText = text;
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      // Tenta consertar JSON truncado (comum em respostas cortadas)
      if (!jsonText.endsWith(']')) {
        debugPrint('[Gemini] JSON parece truncado, tentando consertar...');
        // Se termina no meio de um objeto, tenta fechar
        final lastBrace = jsonText.lastIndexOf('}');
        if (lastBrace > 0) {
          jsonText = '${jsonText.substring(0, lastBrace + 1)}]';
          debugPrint('[Gemini] JSON consertado: "$jsonText"');
        }
      }

      debugPrint('[Gemini] JSON limpo: "$jsonText"');

      final decoded = jsonDecode(jsonText);

      if (decoded is! List) {
        debugPrint('[Gemini] Resposta não é uma lista: ${decoded.runtimeType}');
        return [];
      }

      final items = decoded
          .map((item) => ParsedFoodItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.name.isNotEmpty)
          .toList();

      debugPrint('[Gemini] Items parseados: ${items.length}');
      for (final item in items) {
        debugPrint('[Gemini]    -> ${item.name} (EN: ${item.nameEn}) qty: ${item.quantity}, unit: ${item.unit}');
      }

      return items;
    } catch (e, stack) {
      debugPrint('[Gemini] ERRO: $e');
      debugPrint('[Gemini] Stack: $stack');
      rethrow;
    }
  }
}
