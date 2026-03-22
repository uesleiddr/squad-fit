import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../di/service_locator.dart';
import 'weight_service.dart';
import 'user_service.dart';

class CompetitionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Usa DI para serviços dependentes
  WeightService get _weightService => getIt<WeightService>();
  UserService get _userService => getIt<UserService>();

  CollectionReference<Map<String, dynamic>> get _competitionsCollection =>
      _firestore.collection('competitions');

  CollectionReference<Map<String, dynamic>> get _participantsCollection =>
      _firestore.collection('competitionParticipants');

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<CompetitionModel> createCompetition({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required VictoryRule victoryRule,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final now = DateTime.now();
    final inviteCode = _generateInviteCode();

    final docRef = _competitionsCollection.doc();
    final competition = CompetitionModel(
      id: docRef.id,
      name: name,
      description: description,
      adminId: authUser.uid,
      startDate: startDate,
      endDate: endDate,
      inviteCode: inviteCode,
      victoryRule: victoryRule,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(competition.toFirestore());

    final latestWeight = await _weightService.getLatestWeight();
    final user = await _userService.getCurrentUser();
    final currentWeight = latestWeight?.weight ?? user?.initialWeight ?? 0;

    await joinCompetition(competition.id, currentWeight: currentWeight);

    return competition;
  }

  Future<CompetitionModel?> getCompetitionById(String competitionId) async {
    final doc = await _competitionsCollection.doc(competitionId).get();
    if (!doc.exists) return null;
    return CompetitionModel.fromFirestore(doc);
  }

  Future<CompetitionModel?> getCompetitionByInviteCode(String inviteCode) async {
    final snapshot = await _competitionsCollection
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CompetitionModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> joinCompetitionByCode(String inviteCode, {required double currentWeight}) async {
    final competition = await getCompetitionByInviteCode(inviteCode);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
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
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final existing = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('userId', isEqualTo: authUser.uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final existingParticipant = CompetitionParticipantModel.fromFirestore(existing.docs.first);

      if (existingParticipant.status == ParticipantStatus.active) {
        throw Exception('Voce ja esta nesta competicao');
      }

      final updatedParticipant = existingParticipant.copyWith(
        status: ParticipantStatus.active,
        initialWeight: currentWeight,
        joinedAt: DateTime.now(),
      );
      await _participantsCollection.doc(existingParticipant.id).update(updatedParticipant.toFirestore());
      return updatedParticipant;
    }

    final docRef = _participantsCollection.doc();
    final participant = CompetitionParticipantModel(
      id: docRef.id,
      competitionId: competitionId,
      userId: authUser.uid,
      initialWeight: currentWeight,
      joinedAt: DateTime.now(),
      status: ParticipantStatus.active,
    );

    await docRef.set(participant.toFirestore());
    return participant;
  }

  Future<List<CompetitionModel>> getMyCompetitions() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return [];

    final participations = await _participantsCollection
        .where('userId', isEqualTo: authUser.uid)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .get();

    if (participations.docs.isEmpty) return [];

    final competitionIds = participations.docs
        .map((doc) => doc.data()['competitionId'] as String)
        .toList();

    return _getCompetitionsByIds(competitionIds);
  }

  Future<List<CompetitionModel>> _getCompetitionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<CompetitionModel> results = [];

    for (var i = 0; i < ids.length; i += 30) {
      final batch = ids.skip(i).take(30).toList();
      final snapshot = await _competitionsCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      results.addAll(
        snapshot.docs.map((doc) => CompetitionModel.fromFirestore(doc)),
      );
    }

    return results;
  }

  Stream<List<CompetitionModel>> getMyCompetitionsStream() {
    final authUser = _auth.currentUser;
    if (authUser == null) return Stream.value([]);

    return _participantsCollection
        .where('userId', isEqualTo: authUser.uid)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <CompetitionModel>[];

      final competitionIds = snapshot.docs
          .map((doc) => doc.data()['competitionId'] as String)
          .toList();

      return _getCompetitionsByIds(competitionIds);
    });
  }

  Future<List<CompetitionParticipantModel>> getCompetitionParticipants(
    String competitionId,
  ) async {
    final snapshot = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .get();

    return snapshot.docs
        .map((doc) => CompetitionParticipantModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateCompetition(
    String competitionId, {
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    if (competition.adminId != authUser.uid) {
      throw Exception('Apenas o administrador pode editar a competicao');
    }

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (startDate != null) updates['startDate'] = Timestamp.fromDate(startDate);
    if (endDate != null) updates['endDate'] = Timestamp.fromDate(endDate);

    await _competitionsCollection.doc(competitionId).update(updates);
  }

  Future<void> removeParticipant(
    String competitionId,
    String participantUserId,
  ) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    if (competition.adminId != authUser.uid) {
      throw Exception('Apenas o administrador pode remover participantes');
    }

    if (participantUserId == authUser.uid) {
      throw Exception('O administrador nao pode se remover da competicao');
    }

    final participantDoc = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('userId', isEqualTo: participantUserId)
        .limit(1)
        .get();

    if (participantDoc.docs.isNotEmpty) {
      await _participantsCollection.doc(participantDoc.docs.first.id).update({
        'status': ParticipantStatus.removed.name,
      });
    }
  }

  Future<void> leaveCompetition(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    if (competition.adminId == authUser.uid) {
      throw Exception('O administrador nao pode sair da competicao');
    }

    final participantDoc = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('userId', isEqualTo: authUser.uid)
        .limit(1)
        .get();

    if (participantDoc.docs.isNotEmpty) {
      await _participantsCollection.doc(participantDoc.docs.first.id).update({
        'status': ParticipantStatus.removed.name,
      });
    }
  }

  Future<void> archiveCompetition(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    if (!competition.hasEnded) {
      throw Exception('Apenas competicoes encerradas podem ser arquivadas');
    }

    final participantDoc = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('userId', isEqualTo: authUser.uid)
        .limit(1)
        .get();

    if (participantDoc.docs.isNotEmpty) {
      await _participantsCollection.doc(participantDoc.docs.first.id).update({
        'status': ParticipantStatus.archived.name,
      });
    }
  }

  Future<bool> isAdmin(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return false;

    final competition = await getCompetitionById(competitionId);
    return competition?.adminId == authUser.uid;
  }

  bool isCurrentUserAdmin(String adminId) {
    final authUser = _auth.currentUser;
    if (authUser == null) return false;
    return authUser.uid == adminId;
  }

  /// Obtém o ranking de uma competição (OTIMIZADO - batch fetch)
  Future<List<RankingEntryModel>> getCompetitionRanking(
    String competitionId,
  ) async {
    final authUser = _auth.currentUser;
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
        isCurrentUser: participant.userId == authUser?.uid,
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

  /// Stream do ranking (CORRIGIDO - sem memory leak)
  Stream<List<RankingEntryModel>> getCompetitionRankingStream(
    String competitionId,
  ) {
    final controller = StreamController<List<RankingEntryModel>>.broadcast();

    List<StreamSubscription> weightSubscriptions = [];
    StreamSubscription? participantsSubscription;
    bool isDisposed = false;
    Timer? debounceTimer;

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

    // Debounce para evitar múltiplas chamadas em sequência
    void debouncedRefresh() {
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 300), refreshRanking);
    }

    void cleanupWeightSubscriptions() {
      for (final sub in weightSubscriptions) {
        sub.cancel();
      }
      weightSubscriptions = [];
    }

    void setupWeightListeners(List<String> participantUserIds) {
      cleanupWeightSubscriptions();

      if (isDisposed) return;

      for (final userId in participantUserIds) {
        final sub = _firestore
            .collection('weightRecords')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((_) => debouncedRefresh());
        weightSubscriptions.add(sub);
      }
    }

    participantsSubscription = _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .snapshots()
        .listen(
      (snapshot) {
        if (isDisposed) return;

        final participantUserIds =
            snapshot.docs.map((doc) => doc.data()['userId'] as String).toList();
        setupWeightListeners(participantUserIds);
        debouncedRefresh();
      },
      onError: (e) {
        if (!isDisposed && !controller.isClosed) {
          controller.addError(e);
        }
      },
    );

    controller.onCancel = () {
      isDisposed = true;
      debounceTimer?.cancel();
      participantsSubscription?.cancel();
      cleanupWeightSubscriptions();
    };

    return controller.stream;
  }

  Future<void> deleteCompetition(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final competition = await getCompetitionById(competitionId);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    if (competition.adminId != authUser.uid) {
      throw Exception('Apenas o administrador pode excluir a competicao');
    }

    final participants = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .get();

    for (final doc in participants.docs) {
      await _participantsCollection.doc(doc.id).delete();
    }

    await _competitionsCollection.doc(competitionId).delete();
  }
}
