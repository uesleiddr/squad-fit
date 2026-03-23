import '../constants/app_constants.dart';

class Validators {
  Validators._();

  /// Valida formato de email usando regex
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Regex para validação de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Valida se o peso está dentro dos limites aceitáveis
  static bool isValidWeight(double? weight) {
    if (weight == null) return false;
    return weight >= AppConstants.minWeight && weight <= AppConstants.maxWeight;
  }

  /// Valida senha (mínimo 6 caracteres)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Valida nome (não vazio e sem caracteres especiais)
  static bool isValidName(String name) {
    if (name.trim().isEmpty) return false;
    // Permite letras, espaços e acentos
    final nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
    return nameRegex.hasMatch(name.trim());
  }

  /// Valida altura em cm (entre 50 e 300)
  static bool isValidHeight(int? height) {
    if (height == null) return false;
    return height >= 50 && height <= 300;
  }

  /// Retorna mensagem de erro para email, ou null se válido
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu email';
    }
    if (!isValidEmail(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Retorna mensagem de erro para senha, ou null se válida
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (!isValidPassword(value)) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Retorna mensagem de erro para peso, ou null se válido
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o peso';
    }
    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null) {
      return 'Peso inválido';
    }
    if (!isValidWeight(weight)) {
      return 'Peso deve ser entre ${AppConstants.minWeight.toInt()} e ${AppConstants.maxWeight.toInt()} kg';
    }
    return null;
  }

  /// Retorna mensagem de erro para nome, ou null se válido
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu $fieldName';
    }
    return null;
  }
}
