import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../models/models.dart';
import '../di/service_locator.dart';
import 'weight_service.dart';
import 'user_service.dart';

class CompetitionService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // Usa DI para serviços dependentes
  WeightService get _weightService => getIt<WeightService>();
  UserService get _userService => getIt<UserService>();

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      AppConstants.inviteCodeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Gera um código de convite único, verificando se já existe no banco
  Future<String> _generateUniqueInviteCode() async {
    for (var attempt = 0; attempt < AppConstants.maxInviteCodeAttempts; attempt++) {
      final code = _generateRandomCode();
      final existing = await _supabase
          .from('competitions')
          .select('id')
          .eq('invite_code', code)
          .maybeSingle();

      if (existing == null) {
        return code;
      }
    }
    throw CompetitionException.inviteCodeExists;
  }

  Future<CompetitionModel> createCompetition({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required VictoryRule victoryRule,
  }) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final inviteCode = await _generateUniqueInviteCode();

    final response = await _supabase.from('competitions').insert({
      'name': name,
      'description': description,
      'admin_id': _userId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'invite_code': inviteCode,
      'victory_rule': victoryRule.name,
      'status': 'active',
    }).select().single();

    final competition = CompetitionModel.fromJson(response);

    // Admin entra automaticamente na competição
    final latestWeight = await _weightService.getLatestWeight();
    final user = await _userService.getCurrentUser();
    final currentWeight = latestWeight?.weight ?? user?.initialWeight ?? 0;

    await joinCompetition(competition.id, currentWeight: currentWeight);

    return competition;
  }

  Future<CompetitionModel?> getCompetitionById(String competitionId) async {
    final response = await _supabase
        .from('competitions')
        .select()
        .eq('id', competitionId)
        .maybeSingle();

    if (response == null) return null;
    return CompetitionModel.fromJson(response);
  }

  Future<CompetitionModel?> getCompetitionByInviteCode(String inviteCode) async {
    final response = await _supabase
        .from('competitions')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    if (response == null) return null;
    return CompetitionModel.fromJson(response);
  }

  Future<void> joinCompetitionByCode(String inviteCode, {required double currentWeight}) async {
    final competition = await getCompetitionByInviteCode(inviteCode);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    final weightRecord = await _weightService.getWeightForDate(
      targetDate: competition.startDate,
    );

    final initialWeight = weightRecord?.weight ?? currentWeight;
    await joinCompetition(competition.id, currentWeight: initialWeight);
  }

  Future<CompetitionParticipantModel> joinCompetition(
    String competitionId, {
    required double currentWeight,
  }) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    // Verifica se já existe participação
    final existing = await _supabase
        .from('competition_participants')
        .select()
        .eq('competition_id', competitionId)
        .eq('user_id', _userId!)
        .maybeSingle();

    if (existing != null) {
      final existingParticipant = CompetitionParticipantModel.fromJson(existing);

      if (existingParticipant.status == ParticipantStatus.active) {
        throw CompetitionException.alreadyParticipating;
      }

      // Reativa participação
      final response = await _supabase
          .from('competition_participants')
          .update({
            'status': ParticipantStatus.active.name,
            'initial_weight': currentWeight,
          })
          .eq('id', existingParticipant.id)
          .select()
          .single();

      return CompetitionParticipantModel.fromJson(response);
    }

    // Cria nova participação
    final response = await _supabase.from('competition_participants').insert({
      'competition_id': competitionId,
      'user_id': _userId,
      'initial_weight': currentWeight,
      'status': ParticipantStatus.active.name,
    }).select().single();

    return CompetitionParticipantModel.fromJson(response);
  }

  Future<List<CompetitionModel>> getMyCompetitions() async {
    if (_userId == null) return [];

    // Busca participações ativas
    final participations = await _supabase
        .from('competition_participants')
        .select('competition_id')
        .eq('user_id', _userId!)
        .eq('status', ParticipantStatus.active.name);

    if ((participations as List).isEmpty) return [];

    final competitionIds = participations
        .map((p) => p['competition_id'] as String)
        .toList();

    // Busca as competições
    final competitions = await _supabase
        .from('competitions')
        .select()
        .inFilter('id', competitionIds);

    return (competitions as List)
        .map((json) => CompetitionModel.fromJson(json))
        .toList();
  }

  Stream<List<CompetitionModel>> getMyCompetitionsStream() {
    if (_userId == null) return Stream.value([]);

    return _supabase
        .from('competition_participants')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .asyncMap((participations) async {
          final activeParticipations = participations
              .where((p) => p['status'] == ParticipantStatus.active.name)
              .toList();

          if (activeParticipations.isEmpty) return <CompetitionModel>[];

          final competitionIds = activeParticipations
              .map((p) => p['competition_id'] as String)
              .toList();

          final competitions = await _supabase
              .from('competitions')
              .select()
              .inFilter('id', competitionIds);

          return (competitions as List)
              .map((json) => CompetitionModel.fromJson(json))
              .toList();
        });
  }

  Future<List<CompetitionParticipantModel>> getCompetitionParticipants(
    String competitionId,
  ) async {
    final response = await _supabase
        .from('competition_participants')
        .select()
        .eq('competition_id', competitionId)
        .eq('status', ParticipantStatus.active.name);

    return (response as List)
        .map((json) => CompetitionParticipantModel.fromJson(json))
        .toList();
  }

  Future<void> updateCompetition(
    String competitionId, {
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    if (competition.adminId != _userId) {
      throw CompetitionException.adminOnly;
    }

    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (startDate != null) {
      updates['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      updates['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    if (updates.isNotEmpty) {
      await _supabase
          .from('competitions')
          .update(updates)
          .eq('id', competitionId);
    }
  }

  Future<void> removeParticipant(
    String competitionId,
    String participantUserId,
  ) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    if (competition.adminId != _userId) {
      throw CompetitionException.adminOnly;
    }

    if (participantUserId == _userId) {
      throw CompetitionException.adminCannotBeRemoved;
    }

    await _supabase
        .from('competition_participants')
        .update({'status': ParticipantStatus.removed.name})
        .eq('competition_id', competitionId)
        .eq('user_id', participantUserId);
  }

  Future<void> leaveCompetition(String competitionId) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    if (competition.adminId == _userId) {
      throw CompetitionException.adminCannotLeave;
    }

    await _supabase
        .from('competition_participants')
        .update({'status': ParticipantStatus.removed.name})
        .eq('competition_id', competitionId)
        .eq('user_id', _userId!);
  }

  Future<void> archiveCompetition(String competitionId) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    if (!competition.hasEnded) {
      throw CompetitionException.notEnded;
    }

    await _supabase
        .from('competition_participants')
        .update({'status': ParticipantStatus.archived.name})
        .eq('competition_id', competitionId)
        .eq('user_id', _userId!);
  }

  Future<bool> isAdmin(String competitionId) async {
    if (_userId == null) return false;

    final competition = await getCompetitionById(competitionId);
    return competition?.adminId == _userId;
  }

  bool isCurrentUserAdmin(String adminId) {
    if (_userId == null) return false;
    return _userId == adminId;
  }

  /// Seleciona a competição atual do usuário.
  CompetitionModel? getCurrentCompetition(List<CompetitionModel> competitions) {
    if (competitions.isEmpty) return null;

    // Prioriza competição ativa
    final activeCompetition = competitions
        .where((c) => !c.hasEnded)
        .toList();

    if (activeCompetition.isNotEmpty) {
      activeCompetition.sort((a, b) => b.startDate.compareTo(a.startDate));
      return activeCompetition.first;
    }

    // Se não há ativa, retorna a encerrada mais recente
    final endedCompetitions = competitions
        .where((c) => c.hasEnded)
        .toList();

    if (endedCompetitions.isNotEmpty) {
      endedCompetitions.sort((a, b) => b.endDate.compareTo(a.endDate));
      return endedCompetitions.first;
    }

    return null;
  }

  /// Obtém o ranking de uma competição
  Future<List<RankingEntryModel>> getCompetitionRanking(
    String competitionId,
  ) async {
    final competition = await getCompetitionById(competitionId);
    if (competition == null) return [];

    final participants = await getCompetitionParticipants(competitionId);
    if (participants.isEmpty) return [];

    // Coleta todos os userIds para batch fetch
    final userIds = participants.map((p) => p.userId).toList();

    // Batch fetch: busca todos os usuários e pesos de uma vez
    final usersMap = await _userService.getUsersByIds(userIds);
    final weightsMap = await _weightService.getLatestWeightsForUsers(userIds);

    final List<RankingEntryModel> rankings = [];

    for (final participant in participants) {
      final user = usersMap[participant.userId];
      if (user == null) continue;

      final latestWeight = weightsMap[participant.userId];

      final initialWeight = participant.initialWeight > 0
          ? participant.initialWeight
          : user.initialWeight ?? 0;

      final currentWeight = latestWeight?.weight ?? initialWeight;

      final weightLost = initialWeight - currentWeight;
      final percentageLost = initialWeight > 0
          ? (weightLost / initialWeight) * 100
          : 0.0;

      rankings.add(RankingEntryModel(
        position: 0,
        userId: participant.userId,
        userName: '${user.firstName} ${user.lastName}'.trim(),
        userPhotoUrl: user.photoUrl,
        initialWeight: initialWeight,
        currentWeight: currentWeight,
        weightLost: weightLost,
        percentageLost: percentageLost,
        isCurrentUser: participant.userId == _userId,
      ));
    }

    // Ordena pelo critério da competição
    if (competition.victoryRule == VictoryRule.percentageLoss) {
      rankings.sort((a, b) => b.percentageLost.compareTo(a.percentageLost));
    } else {
      rankings.sort((a, b) => b.weightLost.compareTo(a.weightLost));
    }

    // Define posições
    return rankings.asMap().entries.map((entry) {
      final rank = entry.value;
      return RankingEntryModel(
        position: entry.key + 1,
        userId: rank.userId,
        userName: rank.userName,
        userPhotoUrl: rank.userPhotoUrl,
        initialWeight: rank.initialWeight,
        currentWeight: rank.currentWeight,
        weightLost: rank.weightLost,
        percentageLost: rank.percentageLost,
        isCurrentUser: rank.isCurrentUser,
      );
    }).toList();
  }

  /// Stream do ranking com Supabase Realtime
  Stream<List<RankingEntryModel>> getCompetitionRankingStream(
    String competitionId,
  ) {
    final controller = StreamController<List<RankingEntryModel>>.broadcast();

    Timer? debounceTimer;
    bool isDisposed = false;

    Future<void> refreshRanking() async {
      if (isDisposed || controller.isClosed) return;

      try {
        final ranking = await getCompetitionRanking(competitionId);
        if (!isDisposed && !controller.isClosed) {
          controller.add(ranking);
        }
      } catch (e) {
        if (!isDisposed && !controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    void debouncedRefresh() {
      debounceTimer?.cancel();
      debounceTimer = Timer(AppConstants.rankingDebounce, refreshRanking);
    }

    // Listen to participants changes
    final participantsSubscription = _supabase
        .from('competition_participants')
        .stream(primaryKey: ['id'])
        .eq('competition_id', competitionId)
        .listen((_) => debouncedRefresh());

    // Listen to weight changes (para todos os usuários)
    final weightsSubscription = _supabase
        .from('weight_records')
        .stream(primaryKey: ['id'])
        .listen((_) => debouncedRefresh());

    // Initial load
    refreshRanking();

    controller.onCancel = () {
      isDisposed = true;
      debounceTimer?.cancel();
      participantsSubscription.cancel();
      weightsSubscription.cancel();
    };

    return controller.stream;
  }

  Future<void> deleteCompetition(String competitionId) async {
    if (_userId == null) {
      throw AuthException.notAuthenticated;
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw CompetitionException.notFound;
    }

    if (competition.adminId != _userId) {
      throw CompetitionException.adminOnly;
    }

    // Deleta participantes primeiro (CASCADE deve fazer isso automaticamente)
    await _supabase
        .from('competition_participants')
        .delete()
        .eq('competition_id', competitionId);

    // Deleta a competição
    await _supabase
        .from('competitions')
        .delete()
        .eq('id', competitionId);
  }
}
