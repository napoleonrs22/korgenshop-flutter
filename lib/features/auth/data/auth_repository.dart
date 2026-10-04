import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../domain/entities/auth_user.dart';

/// Вход, регистрация и хранение токена.
class AuthRepository {
  AuthRepository(this._api, this._prefs);

  static const _tokenKey = 'auth_token';

  final ApiClient _api;
  final SharedPreferences _prefs;

  String? get storedToken => _prefs.getString(_tokenKey);

  /// Подставляет сохранённый токен в клиент при старте приложения.
  void restoreSession() => _api.setToken(storedToken);

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password, 'device_name': 'mobile'},
    );

    return _handleAuthResponse(data as Map<String, dynamic>);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? fullAddress,
  }) async {
    final data = await _api.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        // На бэкенде поле необязательное — пустое не отправляем.
        'full_address': ?fullAddress,
        'device_name': 'mobile',
      },
    );

    return _handleAuthResponse(data as Map<String, dynamic>);
  }

  /// Подтверждение почты кодом из письма. Требует токена — код привязан
  /// к аккаунту, а не к адресу.
  Future<AuthUser> verifyEmail(String code) async {
    final data = await _api.post('/auth/otp/verify', body: {'code': code});
    final user = (data as Map)['user'];

    return AuthUser.fromJson(user as Map<String, dynamic>);
  }

  Future<void> resendEmailCode() => _api.post('/auth/otp/resend');

  /// Шаг 1 восстановления: письмо с шестизначным кодом.
  ///
  /// Сервер отвечает одинаково независимо от того, есть ли такой аккаунт,
  /// и возвращает `retry_after` — сколько секунд ждать до следующей отправки.
  Future<int> requestPasswordCode(String email) async {
    final data = await _api.post(
      '/auth/password/forgot',
      body: {'email': email},
    );

    return ((data as Map)['retry_after'] as num?)?.toInt() ?? 60;
  }

  /// Шаг 2: проверка кода без смены пароля, чтобы экран ввода мог ответить
  /// сразу, не заставляя сначала придумывать пароль.
  Future<void> checkPasswordCode({
    required String email,
    required String code,
  }) => _api.post('/auth/password/code', body: {'email': email, 'code': code});

  /// Шаг 3: новый пароль. В ответ приходит свежий токен — сервер отзывает
  /// все прежние, поэтому переавторизуемся сразу.
  Future<AuthUser> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/password/reset',
      body: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': password,
        'device_name': 'mobile',
      },
    );

    return _handleAuthResponse(data as Map<String, dynamic>);
  }

  Future<AuthUser?> me() async {
    if (_api.token == null) return null;

    final data = await _api.get('/auth/me');
    final user = (data as Map)['data'];

    return user is Map<String, dynamic> ? AuthUser.fromJson(user) : null;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      // Даже если сервер недоступен, локальную сессию сбрасываем.
      await _clearToken();
    }
  }

  Future<AuthUser> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = '${data['token'] ?? ''}';

    if (token.isNotEmpty) {
      _api.setToken(token);
      await _prefs.setString(_tokenKey, token);
    }

    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> _clearToken() async {
    _api.setToken(null);
    await _prefs.remove(_tokenKey);
  }
}
