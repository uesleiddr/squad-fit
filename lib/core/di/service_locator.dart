import 'package:get_it/get_it.dart';
import '../services/user_service.dart';
import '../services/weight_service.dart';
import '../services/competition_service.dart';
import '../services/deep_link_service.dart';
import '../../features/auth/services/auth_service.dart';

final getIt = GetIt.instance;

/// Inicializa o service locator com todas as dependências
void setupServiceLocator() {
  // Services como singletons lazy (criados apenas quando usados pela primeira vez)
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<WeightService>(() => WeightService());
  getIt.registerLazySingleton<CompetitionService>(() => CompetitionService());
  getIt.registerLazySingleton<DeepLinkService>(() => DeepLinkService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}

/// Reset para testes
void resetServiceLocator() {
  getIt.reset();
}
