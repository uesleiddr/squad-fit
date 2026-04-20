import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';

class UserService {
  final _supabase = supabase.Supabase.instance.client;

  /// Retorna o usuário atual do Supabase Auth
  supabase.User? get currentAuthUser => _supabase.auth.currentUser;

  /// ID do usuário atual
  String? get _userId => currentAuthUser?.id;

  /// Busca o perfil do usuário atual no Supabase
  Future<UserModel?> getCurrentUser() async {
    if (_userId == null) return null;
    return getUserById(_userId!);
  }

  /// Busca um usuário pelo ID
  Future<UserModel?> getUserById(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Stream do usuário atual (atualiza em tempo real)
  Stream<UserModel?> getCurrentUserStream() {
    if (_userId == null) return Stream.value(null);

    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', _userId!)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }

  /// Cria o perfil do usuário no Supabase (após primeiro login)
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
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();
    final user = UserModel(
      id: authUser.id,
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

    await _supabase.from('users').upsert(user.toJson());
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
    if (_userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final updates = <String, dynamic>{};

    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (photoUrl != null) updates['photo_url'] = photoUrl;
    if (initialWeight != null) updates['initial_weight'] = initialWeight;
    if (goalWeight != null) updates['goal_weight'] = goalWeight;
    if (height != null) updates['height'] = height;
    if (birthDate != null) {
      updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
    }

    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', _userId!);
    }
  }

  /// Verifica se o usuário já completou o cadastro
  Future<bool> hasCompletedProfile() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    // Considera perfil completo se tem nome e peso inicial
    return user.firstName.isNotEmpty && user.initialWeight != null;
  }

  /// Busca múltiplos usuários por IDs
  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final response = await _supabase
        .from('users')
        .select()
        .inFilter('id', userIds);

    final Map<String, UserModel> results = {};
    for (final json in response) {
      final user = UserModel.fromJson(json);
      results[user.id] = user;
    }

    return results;
  }

  /// Atualiza a meta de calorias do usuário
  Future<void> updateCalorieGoal(int calorieGoal) async {
    if (_userId == null) {
      throw Exception('Usuário não autenticado');
    }

    await _supabase
        .from('users')
        .update({'calorie_goal': calorieGoal})
        .eq('id', _userId!);
  }

  /// Deleta o perfil do usuário (dados na tabela users)
  Future<void> deleteUserProfile() async {
    if (_userId == null) {
      throw Exception('Usuário não autenticado');
    }

    await _supabase.from('users').delete().eq('id', _userId!);
  }
}
