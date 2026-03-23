/// Exceção base do aplicativo
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exceção de autenticação
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  static const notAuthenticated = AuthException(
    'Usuário não autenticado',
    code: 'not-authenticated',
  );
}

/// Exceção de validação de dados
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});

  static const invalidWeight = ValidationException(
    'Peso inválido. Deve ser entre 1 e 500 kg.',
    code: 'invalid-weight',
  );

  static const invalidEmail = ValidationException(
    'Email inválido',
    code: 'invalid-email',
  );

  static const invalidInviteCode = ValidationException(
    'Código de convite inválido',
    code: 'invalid-invite-code',
  );

  static const requiredField = ValidationException(
    'Campo obrigatório não preenchido',
    code: 'required-field',
  );
}

/// Exceção de competição
class CompetitionException extends AppException {
  const CompetitionException(super.message, {super.code});

  static const notFound = CompetitionException(
    'Competição não encontrada',
    code: 'competition-not-found',
  );

  static const alreadyParticipating = CompetitionException(
    'Você já está participando desta competição',
    code: 'already-participating',
  );

  static const adminOnly = CompetitionException(
    'Apenas o administrador pode realizar esta ação',
    code: 'admin-only',
  );

  static const adminCannotLeave = CompetitionException(
    'O administrador não pode sair da competição',
    code: 'admin-cannot-leave',
  );

  static const adminCannotBeRemoved = CompetitionException(
    'O administrador não pode ser removido da competição',
    code: 'admin-cannot-be-removed',
  );

  static const notEnded = CompetitionException(
    'Apenas competições encerradas podem ser arquivadas',
    code: 'competition-not-ended',
  );

  static const inviteCodeExists = CompetitionException(
    'Código de convite já existe. Tente novamente.',
    code: 'invite-code-exists',
  );
}

/// Exceção de peso
class WeightException extends AppException {
  const WeightException(super.message, {super.code});

  static const notFound = WeightException(
    'Registro de peso não encontrado',
    code: 'weight-not-found',
  );

  static const noPermission = WeightException(
    'Sem permissão para modificar este registro',
    code: 'no-permission',
  );

  static const noWeightRegistered = WeightException(
    'Você precisa registrar seu peso primeiro',
    code: 'no-weight-registered',
  );
}

/// Exceção de usuário
class UserException extends AppException {
  const UserException(super.message, {super.code});

  static const notFound = UserException(
    'Usuário não encontrado',
    code: 'user-not-found',
  );

  static const profileIncomplete = UserException(
    'Perfil incompleto. Complete seu perfil para continuar.',
    code: 'profile-incomplete',
  );
}
