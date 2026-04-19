// ignore_for_file: avoid_print
// Script para gerar embeddings dos alimentos usando Gemini
//
// Execução:
//   dart run scripts/generate_embeddings.dart
//
// Lê GEMINI_API_KEY do arquivo .env ou variável de ambiente.
//
// Este script:
// 1. Carrega foods.json e taco.json
// 2. Cria chunks otimizados para cada alimento
// 3. Gera embeddings usando Gemini text-embedding-004
// 4. Salva em assets/data/food_vectors.json

import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

/// Obtém API key do .env ou variável de ambiente
String get geminiApiKey {
  // 1. Tenta variável de ambiente
  var key = Platform.environment['GEMINI_API_KEY'];
  if (key != null && key.isNotEmpty) {
    return key;
  }

  // 2. Tenta ler do arquivo .env
  try {
    final envFile = File('.env');
    if (envFile.existsSync()) {
      final lines = envFile.readAsLinesSync();
      for (final line in lines) {
        if (line.startsWith('GEMINI_API_KEY=')) {
          key = line.substring('GEMINI_API_KEY='.length).trim();
          if (key.isNotEmpty) {
            return key;
          }
        }
      }
    }
  } catch (_) {}

  throw Exception(
    'GEMINI_API_KEY não encontrada.\n'
    'Defina no arquivo .env ou como variável de ambiente.',
  );
}

/// Tamanho do batch para processamento
const int batchSize = 50;

/// Delay entre requests (ms) para rate limiting
const int delayBetweenRequests = 60; // ~16 RPS (limite é 1500 RPM = 25 RPS)

// ============================================================================
// MODELOS
// ============================================================================

/// Chunk de alimento com metadados e texto para embedding
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

  FoodChunk({
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'source': source,
      };
}

// ============================================================================
// CHUNKING - PREPARAÇÃO DOS DADOS
// ============================================================================

/// Carrega e processa todos os alimentos
Future<List<FoodChunk>> loadAndChunkFoods() async {
  final chunks = <FoodChunk>[];

  // 1. Carrega foods.json
  print('Carregando foods.json...');
  try {
    final foodsFile = File('assets/data/foods.json');
    final foodsData = jsonDecode(await foodsFile.readAsString()) as Map<String, dynamic>;

    for (final entry in foodsData.entries) {
      final code = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final nutrients = data['nutrients'] as Map<String, dynamic>? ?? {};

      final name = data['name'] as String? ?? '';
      final nameEn = data['name_en'] as String? ?? '';

      if (name.isEmpty) continue;

      chunks.add(_createChunk(
        id: code,
        name: name,
        nameEn: nameEn,
        calories: _extractNutrient(nutrients, 'Energia'),
        protein: _extractNutrient(nutrients, 'Proteína'),
        carbs: _extractNutrient(nutrients, 'Carboidrato total'),
        fat: _extractNutrient(nutrients, 'Lipídios'),
        source: 'foods',
      ));
    }
    print('  -> ${foodsData.length} alimentos carregados');
  } catch (e) {
    print('  ERRO: $e');
  }

  // 2. Carrega taco.json
  print('Carregando taco.json...');
  try {
    final tacoFile = File('assets/data/taco.json');
    final tacoData = jsonDecode(await tacoFile.readAsString()) as List<dynamic>;

    for (final item in tacoData) {
      final name = item['description'] as String? ?? '';
      if (name.isEmpty) continue;

      chunks.add(_createChunk(
        id: 'TACO_${item['id']}',
        name: name,
        nameEn: '',
        calories: _parseDouble(item['energy_kcal']),
        protein: _parseDouble(item['protein_g']),
        carbs: _parseDouble(item['carbohydrate_g']),
        fat: _parseDouble(item['lipid_g']),
        source: 'taco',
      ));
    }
    print('  -> ${tacoData.length} alimentos carregados');
  } catch (e) {
    print('  ERRO: $e');
  }

  print('\nTotal de chunks: ${chunks.length}');
  return chunks;
}

/// Cria um chunk com texto otimizado para embedding
FoodChunk _createChunk({
  required String id,
  required String name,
  required String nameEn,
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
String _generateSearchText({
  required String name,
  required String nameEn,
  required String category,
  required List<String> tags,
}) {
  final parts = <String>[];

  // Nome simplificado
  parts.add(_simplifyName(name));

  // Nome em inglês
  if (nameEn.isNotEmpty) {
    parts.add(nameEn);
  }

  // Categoria
  parts.add(category);

  // Tags
  parts.addAll(tags);

  // Sinônimos
  parts.addAll(_getSynonyms(name));

  return parts.join(' | ');
}

/// Simplifica nome removendo detalhes
String _simplifyName(String name) {
  return name
      .replaceAll(RegExp(r',?\s*s/\s*óleo', caseSensitive: false), '')
      .replaceAll(RegExp(r',?\s*c/\s*óleo', caseSensitive: false), '')
      .replaceAll(RegExp(r',?\s*s/\s*sal', caseSensitive: false), '')
      .replaceAll(RegExp(r',?\s*c/\s*sal', caseSensitive: false), '')
      .replaceAll('Gallus gallus', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Extrai categoria do alimento
String _extractCategory(String name) {
  final n = name.toLowerCase();

  if (n.startsWith('carne') || n.startsWith('frango') || n.startsWith('peixe') ||
      n.startsWith('ovo') || n.contains('boi') || n.contains('porco')) {
    return 'proteína';
  }
  if (n.startsWith('arroz') || n.startsWith('macarrão') || n.startsWith('pão') ||
      n.startsWith('batata')) {
    return 'carboidrato';
  }
  if (n.contains('bebida') || n.contains('suco') || n.startsWith('leite') ||
      n.contains('café') || n.contains('chá')) {
    return 'bebida';
  }
  if (n.startsWith('salada') || n.contains('verdura') || n.contains('legume')) {
    return 'vegetal';
  }
  if (n.startsWith('fruta') || n.contains('maçã') || n.contains('banana')) {
    return 'fruta';
  }
  if (n.startsWith('queijo') || n.startsWith('iogurte')) {
    return 'laticínio';
  }

  return 'outro';
}

/// Extrai tags de preparação
List<String> _extractTags(String name) {
  final tags = <String>[];
  final n = name.toLowerCase();

  if (n.contains('grelh')) tags.add('grelhado');
  if (n.contains('frit')) tags.add('frito');
  if (n.contains('cozid')) tags.add('cozido');
  if (n.contains('assad')) tags.add('assado');
  if (n.contains('cru')) tags.add('cru');
  if (n.contains('refog')) tags.add('refogado');
  if (n.contains('mexid')) tags.add('mexido');
  if (n.contains('integral')) tags.add('integral');
  if (n.contains('light')) tags.add('light');
  if (n.contains('peito')) tags.add('peito');
  if (n.contains('coxa')) tags.add('coxa');
  if (n.contains('filé') || n.contains('file')) tags.add('filé');

  return tags;
}

/// Retorna sinônimos comuns
List<String> _getSynonyms(String name) {
  final synonyms = <String>[];
  final n = name.toLowerCase();

  if (n.contains('frango')) synonyms.addAll(['galinha', 'chicken']);
  if (n.contains('boi')) synonyms.addAll(['vaca', 'beef']);
  if (n.contains('porco')) synonyms.addAll(['suíno', 'pork']);
  if (n.contains('grelh')) synonyms.add('grilled');
  if (n.contains('frit')) synonyms.add('fried');
  if (n.contains('café')) synonyms.add('coffee');

  return synonyms;
}

double _extractNutrient(Map<String, dynamic> nutrients, String name) {
  final nutrient = nutrients[name];
  if (nutrient == null) return 0;
  if (nutrient is Map) {
    final value = nutrient['value'];
    if (value is num) return value.toDouble();
  }
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value == 'NA' || value == 'Tr' || value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

// ============================================================================
// GERAÇÃO DE EMBEDDINGS
// ============================================================================

/// Gera embeddings para todos os chunks
Future<List<Map<String, dynamic>>> generateEmbeddings(
  List<FoodChunk> chunks,
  GenerativeModel model,
) async {
  final results = <Map<String, dynamic>>[];
  var processed = 0;
  var errors = 0;

  final totalBatches = (chunks.length / batchSize).ceil();

  for (var i = 0; i < chunks.length; i += batchSize) {
    final batchNum = (i / batchSize).floor() + 1;
    final batch = chunks.skip(i).take(batchSize).toList();

    print('\nBatch $batchNum/$totalBatches (${batch.length} itens)...');

    for (final chunk in batch) {
      try {
        final result = await model.embedContent(
          Content.text(chunk.searchText),
        );

        final embedding = result.embedding;
        results.add({
          ...chunk.toJson(),
          'embedding': embedding.values,
        });

        processed++;

        // Progress indicator a cada 10 itens
        if (processed % 10 == 0) {
          stdout.write('\r  Processados: $processed/${chunks.length} (${(processed / chunks.length * 100).toStringAsFixed(1)}%)');
        }

        // Rate limiting
        await Future.delayed(Duration(milliseconds: delayBetweenRequests));
      } catch (e) {
        errors++;
        print('\n  ERRO em "${chunk.name}": $e');
      }
    }
  }

  print('\n\nConcluído: $processed processados, $errors erros');
  return results;
}

// ============================================================================
// MAIN
// ============================================================================

Future<void> main() async {
  print('=' * 60);
  print('GERADOR DE EMBEDDINGS PARA BUSCA DE ALIMENTOS');
  print('=' * 60);
  print('');

  // 1. Verifica API key
  print('Verificando API key...');
  final apiKey = geminiApiKey;
  print('  -> OK\n');

  // 2. Carrega e processa alimentos (chunking)
  print('ETAPA 1: CHUNKING');
  print('-' * 40);
  final chunks = await loadAndChunkFoods();

  // Mostra exemplos de chunks
  print('\nExemplos de chunks gerados:');
  for (final chunk in chunks.take(3)) {
    print('  - ${chunk.name}');
    print('    Categoria: ${chunk.category}');
    print('    Tags: ${chunk.tags.join(", ")}');
    print('    SearchText: ${chunk.searchText.substring(0, 80.clamp(0, chunk.searchText.length))}...');
  }

  // 3. Inicializa modelo de embeddings
  print('\nETAPA 2: GERAÇÃO DE EMBEDDINGS');
  print('-' * 40);
  print('Inicializando modelo Gemini gemini-embedding-001...');

  final model = GenerativeModel(
    model: 'gemini-embedding-001',
    apiKey: apiKey,
  );

  // Teste de conexão
  print('Testando conexão...');
  try {
    final testResult = await model.embedContent(Content.text('teste'));
    print('  -> OK (dimensão: ${testResult.embedding.values.length})');
  } catch (e) {
    print('  ERRO: $e');
    exit(1);
  }

  // 4. Gera embeddings
  print('\nGerando embeddings (isso pode levar alguns minutos)...');
  print('Rate limit: ${(1000 / delayBetweenRequests).toStringAsFixed(1)} requests/segundo');

  final startTime = DateTime.now();
  final embeddings = await generateEmbeddings(chunks, model);
  final duration = DateTime.now().difference(startTime);

  print('\nTempo total: ${duration.inMinutes}m ${duration.inSeconds % 60}s');

  // 5. Salva resultado
  print('\nETAPA 3: SALVANDO RESULTADO');
  print('-' * 40);

  final outputFile = File('assets/data/food_vectors.json');
  final jsonOutput = jsonEncode(embeddings);

  await outputFile.writeAsString(jsonOutput);

  final fileSizeKB = (await outputFile.length()) / 1024;
  final fileSizeMB = fileSizeKB / 1024;

  print('Arquivo salvo: ${outputFile.path}');
  print('Tamanho: ${fileSizeMB.toStringAsFixed(2)} MB');
  print('Total de vetores: ${embeddings.length}');

  // 6. Estatísticas finais
  print('\n${'=' * 60}');
  print('RESUMO');
  print('=' * 60);
  print('Alimentos processados: ${chunks.length}');
  print('Embeddings gerados: ${embeddings.length}');
  print('Taxa de sucesso: ${(embeddings.length / chunks.length * 100).toStringAsFixed(1)}%');
  print('Dimensão do embedding: 3072 (gemini-embedding-001)');
  print('Arquivo de saída: assets/data/food_vectors.json');
  print('');
}
