/// Validador de código de convite
class InviteCodeValidator {
  /// Regex para código: exatamente 8 caracteres alfanuméricos maiúsculos
  static final _regex = RegExp(r'^[A-Z0-9]{8}$');

  /// Valida se o código tem formato correto
  static bool isValid(String code) {
    return _regex.hasMatch(code.toUpperCase());
  }

  /// Normaliza o código (uppercase e trim)
  static String normalize(String code) {
    return code.trim().toUpperCase();
  }
}
