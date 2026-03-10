import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Retorna o usuário atual do Firebase Auth
  User? get currentAuthUser => _auth.currentUser;

  /// Busca o perfil do usuário atual no Firestore
  Future<UserModel?> getCurrentUser() async {
    final authUser = currentAuthUser;
    if (authUser == null) return null;
    return getUserById(authUser.uid);
  }

  /// Busca um usuário pelo ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream do usuário atual (atualiza em tempo real)
  Stream<UserModel?> getCurrentUserStream() {
    final authUser = currentAuthUser;
    if (authUser == null) return Stream.value(null);

    return _usersCollection.doc(authUser.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Cria o perfil do usuário no Firestore (após primeiro login)
  Future<UserModel> createUser({
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    double? initialWeight,
    double? goalWeight,
    int? height,
    DateTime? birthDate,
  }) async {
    final authUser = currentAuthUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final now = DateTime.now();
    final user = UserModel(
      id: authUser.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      photoUrl: photoUrl,
      initialWeight: initialWeight,
      goalWeight: goalWeight,
      height: height,
      birthDate: birthDate,
      createdAt: now,
      updatedAt: now,
    );

    await _usersCollection.doc(authUser.uid).set(user.toFirestore());
    return user;
  }

  /// Atualiza o perfil do usuário
  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? photoUrl,
    double? initialWeight,
    double? goalWeight,
    int? height,
    DateTime? birthDate,
  }) async {
    final authUser = currentAuthUser;
    if (authUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (initialWeight != null) updates['initialWeight'] = initialWeight;
    if (goalWeight != null) updates['goalWeight'] = goalWeight;
    if (height != null) updates['height'] = height;
    if (birthDate != null) updates['birthDate'] = Timestamp.fromDate(birthDate);

    await _usersCollection.doc(authUser.uid).update(updates);
  }

  /// Verifica se o usuário já completou o cadastro
  Future<bool> hasCompletedProfile() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    // Considera perfil completo se tem nome e peso inicial
    return user.firstName.isNotEmpty && user.initialWeight != null;
  }
}
