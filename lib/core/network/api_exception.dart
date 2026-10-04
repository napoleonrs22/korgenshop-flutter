/// Ошибка обращения к API в понятном для UI виде.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;

  /// Разбор поля `errors` из ответа валидации: поле → список сообщений.
  final Map<String, List<String>>? errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 422;

  /// Первое сообщение по конкретному полю — для подписи под инпутом.
  String? errorFor(String field) => errors?[field]?.first;

  @override
  String toString() => message;
}
