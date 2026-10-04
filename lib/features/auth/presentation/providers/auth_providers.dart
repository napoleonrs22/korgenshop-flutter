import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/auth_user.dart';

/// Переопределяется в [buildAppOverrides] при старте приложения.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('sharedPreferencesProvider не переопределён'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

/// Текущий пользователь: null — не авторизован.
class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null)) {
    _restore();
  }

  final AuthRepository _repository;

  Future<void> _restore() async {
    _repository.restoreSession();

    if (_repository.storedToken == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.me);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? fullAddress,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        fullAddress: fullAddress,
      ),
    );
  }

  /// Подтверждение почты: в ответ приходит обновлённый пользователь.
  ///
  /// Ошибку пробрасываем экрану, а не кладём в состояние: неверный код не
  /// повод считать, что пользователь разлогинился — токен-то остался.
  Future<void> verifyEmail(String code) async {
    state = AsyncValue.data(await _repository.verifyEmail(code));
  }

  /// Смена пароля по коду заодно выдаёт новый токен — это вход.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    state = AsyncValue.data(
      await _repository.resetPassword(
        email: email,
        code: code,
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
    );

/// Удобный флаг для экранов.
final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).valueOrNull != null,
);
