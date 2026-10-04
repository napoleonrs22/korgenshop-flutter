import 'package:get_it/get_it.dart';

import '../../features/quiz/domain/services/quiz_estimator.dart';

final getIt = GetIt.instance;

/// Регистрирует доменные сервисы, не зависящие от языка.
///
/// Репозитории и датасорсы живут в Riverpod-провайдерах рядом с фичами:
/// они пересобираются при смене языка, потому что читают словарь локали.
/// Замена моков на API — подмена одной строки в провайдере репозитория.
void configureDependencies() {
  if (getIt.isRegistered<QuizEstimator>()) return;

  getIt.registerLazySingleton(QuizEstimator.new);
}
