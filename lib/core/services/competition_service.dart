import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

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
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(competition.toFirestore());

    // Admin automaticamente entra como participante
    await joinCompetition(competition.id, currentWeight: 0);

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

  /// Verifica se o usuário é admin de uma competição
  Future<bool> isAdmin(String competitionId) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return false;

    final competition = await getCompetitionById(competitionId);
    return competition?.adminId == authUser.uid;
  }
}
