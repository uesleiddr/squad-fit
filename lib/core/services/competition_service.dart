import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'weight_service.dart';
import 'user_service.dart';

class CompetitionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsCollection =>
      _firestore.collection('competitions');

  CollectionReference<Map<String, dynamic>> get _participantsCollection =>
      _firestore.collection('competitionParticipants');

  /// Gera um código de convite único
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Cria uma nova competição
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

    // Admin automaticamente entra como participante
    // Busca o peso atual do admin
    final weightService = WeightService();
    final userService = UserService();

    final latestWeight = await weightService.getLatestWeight();
    final user = await userService.getCurrentUser();

    final currentWeight = latestWeight?.weight ?? user?.initialWeight ?? 0;

    await joinCompetition(competition.id, currentWeight: currentWeight);

    return competition;
  }

  /// Busca uma competição pelo ID
  Future<CompetitionModel?> getCompetitionById(String competitionId) async {
    final doc = await _competitionsCollection.doc(competitionId).get();
    if (!doc.exists) return null;
    return CompetitionModel.fromFirestore(doc);
  }

  /// Busca uma competição pelo código de convite
  Future<CompetitionModel?> getCompetitionByInviteCode(String inviteCode) async {
    final snapshot = await _competitionsCollection
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CompetitionModel.fromFirestore(snapshot.docs.first);
  }

  /// Entra em uma competição usando código de convite
  Future<void> joinCompetitionByCode(String inviteCode, {required double currentWeight}) async {
    final competition = await getCompetitionByInviteCode(inviteCode);
    if (competition == null) {
      throw Exception('Competicao nao encontrada');
    }

    await joinCompetition(competition.id, currentWeight: currentWeight);
  }

  /// Entra em uma competição
  Future<CompetitionParticipantModel> joinCompetition(
    String competitionId, {
    required double currentWeight,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    // Verifica se já é participante
    final existing = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('userId', isEqualTo: authUser.uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Voce ja esta nesta competicao');
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

  /// Lista competições do usuário atual
  Future<List<CompetitionModel>> getMyCompetitions() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return [];

    // Busca participações do usuário
    final participations = await _participantsCollection
        .where('userId', isEqualTo: authUser.uid)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .get();

    if (participations.docs.isEmpty) return [];

    // Busca as competições correspondentes
    final competitionIds = participations.docs
        .map((doc) => doc.data()['competitionId'] as String)
        .toList();

    final competitions = await Future.wait(
      competitionIds.map((id) => getCompetitionById(id)),
    );

    return competitions.whereType<CompetitionModel>().toList();
  }

  /// Stream das competições do usuário (tempo real)
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

      final competitions = await Future.wait(
        competitionIds.map((id) => getCompetitionById(id)),
      );

      return competitions.whereType<CompetitionModel>().toList();
    });
  }

  /// Lista participantes de uma competição
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

  /// Atualiza dados da competição (apenas admin)
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

  /// Remove um participante da competição (apenas admin)
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

  /// Sai de uma competição
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

  /// Arquiva uma competição encerrada (mantém no histórico)
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

  /// Verifica se o usuário é admin de uma competição
  Future<bool> isAdmin(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return false;

    final competition = await getCompetitionById(competitionId);
    return competition?.adminId == authUser.uid;
  }

  /// Verifica se o usuário atual é admin (versão síncrona usando o uid)
  bool isCurrentUserAdmin(String adminId) {
    final authUser = _auth.currentUser;
    if (authUser == null) return false;
    return authUser.uid == adminId;
  }

  /// Obtém o ranking de uma competição
  /// Retorna lista ordenada por regra de vitória (porcentagem ou kg perdidos)
  Future<List<RankingEntryModel>> getCompetitionRanking(
    String competitionId,
  ) async {
    final authUser = _auth.currentUser;
    final competition = await getCompetitionById(competitionId);
    if (competition == null) return [];

    final participants = await getCompetitionParticipants(competitionId);
    if (participants.isEmpty) return [];

    final weightService = WeightService();
    final userService = UserService();

    final List<RankingEntryModel> rankings = [];

    for (final participant in participants) {
      // Busca dados do usuário
      final user = await userService.getUserById(participant.userId);
      if (user == null) continue;

      // Busca peso atual do participante
      final latestWeight = await weightService.getLatestWeight(
        userId: participant.userId,
      );

      final initialWeight = participant.initialWeight > 0
          ? participant.initialWeight
          : user.initialWeight ?? 0;

      final currentWeight = latestWeight?.weight ?? initialWeight;

      final weightLost = initialWeight - currentWeight;
      final percentageLost = initialWeight > 0
          ? (weightLost / initialWeight) * 100
          : 0.0;

      rankings.add(RankingEntryModel(
        position: 0, // Será definido após ordenação
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
    final rankedList = <RankingEntryModel>[];
    for (var i = 0; i < rankings.length; i++) {
      final entry = rankings[i];
      rankedList.add(RankingEntryModel(
        position: i + 1,
        userId: entry.userId,
        userName: entry.userName,
        userPhotoUrl: entry.userPhotoUrl,
        initialWeight: entry.initialWeight,
        currentWeight: entry.currentWeight,
        weightLost: entry.weightLost,
        percentageLost: entry.percentageLost,
        isCurrentUser: entry.isCurrentUser,
      ));
    }

    return rankedList;
  }

  /// Stream do ranking de uma competição (atualiza em tempo real)
  Stream<List<RankingEntryModel>> getCompetitionRankingStream(
    String competitionId,
  ) {
    final controller = StreamController<List<RankingEntryModel>>();

    Future<void> refreshRanking() async {
      try {
        final ranking = await getCompetitionRanking(competitionId);
        if (!controller.isClosed) {
          controller.add(ranking);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // Escuta mudanças nos participantes
    final participantsSubscription = _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .where('status', isEqualTo: ParticipantStatus.active.name)
        .snapshots()
        .listen((_) => refreshRanking());

    // Escuta mudanças nos registros de peso (para atualizar ranking quando alguém registra peso)
    final weightsSubscription = _firestore
        .collection('weightRecords')
        .snapshots()
        .listen((_) => refreshRanking());

    controller.onCancel = () {
      participantsSubscription.cancel();
      weightsSubscription.cancel();
    };

    return controller.stream;
  }

  /// Exclui uma competição (apenas admin)
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

    // Remove todos os participantes
    final participants = await _participantsCollection
        .where('competitionId', isEqualTo: competitionId)
        .get();

    for (final doc in participants.docs) {
      await _participantsCollection.doc(doc.id).delete();
    }

    // Remove a competição
    await _competitionsCollection.doc(competitionId).delete();
  }
}
