import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../exceptions/app_exceptions.dart';
import '../models/weight_record_model.dart';
import '../utils/validators.dart';

class WeightService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Registra um novo peso
  Future<WeightRecordModel> addWeight(double weight, {DateTime? date}) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    if (!Validators.isValidWeight(weight)) {
      throw ValidationException.invalidWeight;
    }

    final recordDate = date ?? DateTime.now();

    final response = await _supabase.from('weight_records').insert({
      'user_id': _userId,
      'weight': weight,
      'date': recordDate.toIso8601String().split('T')[0],
    }).select().single();

    return WeightRecordModel.fromJson(response);
  }

  /// Busca todos os registros de peso do usuário atual
  Future<List<WeightRecordModel>> getWeightHistory() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('weight_records')
        .select()
        .eq('user_id', _userId!)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => WeightRecordModel.fromJson(json))
        .toList();
  }

  /// Stream dos registros de peso (atualiza em tempo real)
  Stream<List<WeightRecordModel>> getWeightHistoryStream() {
    if (_userId == null) return Stream.value([]);

    return _supabase
        .from('weight_records')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('date', ascending: false)
        .map((data) => data.map((e) => WeightRecordModel.fromJson(e)).toList());
  }

  /// Busca o peso mais recente do usuário
  Future<WeightRecordModel?> getLatestWeight({String? userId}) async {
    final targetUserId = userId ?? _userId;
    if (targetUserId == null) return null;

    final response = await _supabase
        .from('weight_records')
        .select()
        .eq('user_id', targetUserId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return WeightRecordModel.fromJson(response);
  }

  /// Retorna o peso atual do usuário (último registro ou peso inicial do perfil)
  /// Lança exceção se nenhum peso estiver disponível
  Future<double> getCurrentWeight(double? initialWeight) async {
    final latestWeight = await getLatestWeight();
    if (latestWeight != null) {
      return latestWeight.weight;
    }
    if (initialWeight != null) {
      return initialWeight;
    }
    throw WeightException.noWeightRegistered;
  }

  /// Busca registros de peso de um usuário em um período
  Future<List<WeightRecordModel>> getWeightsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    final targetUserId = userId ?? _userId;
    if (targetUserId == null) return [];

    final response = await _supabase
        .from('weight_records')
        .select()
        .eq('user_id', targetUserId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    return (response as List)
        .map((json) => WeightRecordModel.fromJson(json))
        .toList();
  }

  /// Busca o peso que o usuário tinha em uma data específica
  Future<WeightRecordModel?> getWeightForDate({
    required DateTime targetDate,
    String? userId,
  }) async {
    final targetUserId = userId ?? _userId;
    if (targetUserId == null) return null;

    final dateStr = targetDate.toIso8601String().split('T')[0];

    // 1. Tenta buscar o peso mais recente ATÉ a data alvo
    var response = await _supabase
        .from('weight_records')
        .select()
        .eq('user_id', targetUserId)
        .lte('date', dateStr)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      return WeightRecordModel.fromJson(response);
    }

    // 2. Se não tem peso antes, busca o primeiro peso DEPOIS da data
    response = await _supabase
        .from('weight_records')
        .select()
        .eq('user_id', targetUserId)
        .gt('date', dateStr)
        .order('date', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      return WeightRecordModel.fromJson(response);
    }

    return null;
  }

  /// Deleta um registro de peso (apenas do próprio usuário)
  Future<void> deleteWeight(String recordId) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    // RLS já garante que só pode deletar próprios registros
    await _supabase.from('weight_records').delete().eq('id', recordId);
  }

  /// Atualiza um registro de peso (apenas do próprio usuário)
  Future<void> updateWeight(String recordId, double newWeight) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    if (!Validators.isValidWeight(newWeight)) {
      throw ValidationException.invalidWeight;
    }

    // RLS já garante que só pode atualizar próprios registros
    await _supabase
        .from('weight_records')
        .update({'weight': newWeight})
        .eq('id', recordId);
  }

  /// Busca o peso mais recente de múltiplos usuários em batch.
  Future<Map<String, WeightRecordModel?>> getLatestWeightsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    final Map<String, WeightRecordModel?> results = {};

    // Inicializa todos como null
    for (final userId in userIds) {
      results[userId] = null;
    }

    // Busca todos os pesos dos usuários
    final response = await _supabase
        .from('weight_records')
        .select()
        .inFilter('user_id', userIds)
        .order('date', ascending: false);

    // Agrupa por userId e pega o mais recente de cada
    final Map<String, WeightRecordModel> latestByUser = {};
    for (final json in response) {
      final record = WeightRecordModel.fromJson(json);
      // Só guarda se ainda não tem (o primeiro é o mais recente por causa do orderBy)
      if (!latestByUser.containsKey(record.userId)) {
        latestByUser[record.userId] = record;
      }
    }

    // Atualiza o resultado
    latestByUser.forEach((userId, record) {
      results[userId] = record;
    });

    return results;
  }
}
