import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weight_record_model.dart';

class WeightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _weightsCollection =>
      _firestore.collection('weightRecords');

  /// Registra um novo peso
  Future<WeightRecordModel> addWeight(double weight, {DateTime? date}) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final now = DateTime.now();
    final recordDate = date ?? now;

    final docRef = _weightsCollection.doc();
    final record = WeightRecordModel(
      id: docRef.id,
      userId: authUser.uid,
      weight: weight,
      date: recordDate,
      createdAt: now,
    );

    await docRef.set(record.toFirestore());
    return record;
  }

  /// Busca todos os registros de peso do usuário atual
  Future<List<WeightRecordModel>> getWeightHistory() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return [];

    final snapshot = await _weightsCollection
        .where('userId', isEqualTo: authUser.uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WeightRecordModel.fromFirestore(doc))
        .toList();
  }

  /// Stream dos registros de peso (atualiza em tempo real)
  Stream<List<WeightRecordModel>> getWeightHistoryStream() {
    final authUser = _auth.currentUser;
    if (authUser == null) return Stream.value([]);

    return _weightsCollection
        .where('userId', isEqualTo: authUser.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightRecordModel.fromFirestore(doc))
            .toList());
  }

  /// Busca o peso mais recente do usuário
  Future<WeightRecordModel?> getLatestWeight({String? userId}) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return null;

    final snapshot = await _weightsCollection
        .where('userId', isEqualTo: targetUserId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return WeightRecordModel.fromFirestore(snapshot.docs.first);
  }

  /// Busca registros de peso de um usuário em um período
  Future<List<WeightRecordModel>> getWeightsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return [];

    final snapshot = await _weightsCollection
        .where('userId', isEqualTo: targetUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WeightRecordModel.fromFirestore(doc))
        .toList();
  }

  /// Busca o peso que o usuário tinha em uma data específica
  /// 1. Primeiro tenta o peso mais recente ATÉ a data (o peso atual naquela data)
  /// 2. Se não existir, pega o primeiro peso registrado DEPOIS da data
  Future<WeightRecordModel?> getWeightForDate({
    required DateTime targetDate,
    String? userId,
  }) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return null;

    // Fim do dia para incluir registros do próprio dia
    final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    // 1. Tenta buscar o peso mais recente ATÉ a data alvo
    final beforeSnapshot = await _weightsCollection
        .where('userId', isEqualTo: targetUserId)
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (beforeSnapshot.docs.isNotEmpty) {
      return WeightRecordModel.fromFirestore(beforeSnapshot.docs.first);
    }

    // 2. Se não tem peso antes, busca o primeiro peso DEPOIS da data
    final afterSnapshot = await _weightsCollection
        .where('userId', isEqualTo: targetUserId)
        .where('date', isGreaterThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: false)
        .limit(1)
        .get();

    if (afterSnapshot.docs.isNotEmpty) {
      return WeightRecordModel.fromFirestore(afterSnapshot.docs.first);
    }

    return null;
  }

  /// Deleta um registro de peso
  Future<void> deleteWeight(String recordId) async {
    await _weightsCollection.doc(recordId).delete();
  }

  /// Atualiza um registro de peso
  Future<void> updateWeight(String recordId, double newWeight) async {
    await _weightsCollection.doc(recordId).update({
      'weight': newWeight,
    });
  }
}
