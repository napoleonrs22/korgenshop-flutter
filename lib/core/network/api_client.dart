import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

/// Тонкая обёртка над Dio: базовый адрес, bearer-токен и приведение
/// ошибок Laravel к [ApiException].
class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
              // Коды разбираем сами — включая 5xx. Иначе ошибка сервера
              // прилетала бы как исключение Dio и терялась за общим
              // «Ошибка сети» вместо текста, который прислал бэкенд.
              validateStatus: (status) => status != null,
            ),
          );

  final Dio _dio;
  String? _token;

  /// Токен подставляется во все последующие запросы.
  void setToken(String? token) => _token = token;

  String? get token => _token;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query, options: _options()));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body, options: _options()));

  Options _options() => Options(
    headers: _token == null ? null : {'Authorization': 'Bearer $_token'},
  );

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    late final Response<dynamic> response;

    try {
      response = await request();
    } on DioException catch (error) {
      throw ApiException(_networkMessage(error));
    }

    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 200 && status < 300) {
      return data;
    }

    throw ApiException(
      _messageFrom(data, status),
      statusCode: status,
      errors: _errorsFrom(data),
    );
  }

  String _networkMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Сервер не отвечает',
      DioExceptionType.connectionError => 'Нет связи с сервером',
      DioExceptionType.badCertificate => 'Сертификат сервера не принят',
      // Остаётся unknown: обычно это ошибка разбора ответа или
      // неожиданное исключение в транспорте — показываем подробности.
      _ => 'Сбой запроса: ${error.message ?? error.type.name}',
    };
  }

  String _messageFrom(dynamic data, int status) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Ошибка запроса ($status)';
  }

  Map<String, List<String>>? _errorsFrom(dynamic data) {
    if (data is! Map || data['errors'] is! Map) return null;

    final raw = data['errors'] as Map;
    return {
      for (final entry in raw.entries)
        '${entry.key}': (entry.value as List<dynamic>? ?? const [])
            .map((item) => '$item')
            .toList(),
    };
  }
}
