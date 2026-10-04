/// Настройки сборки.
///
/// Адрес API задаётся при запуске:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000/api/v1
///
/// По умолчанию — боевой сервер, чтобы собранное приложение работало без
/// дополнительных флагов. Для локального стенда передаётся адрес явно:
/// с устройства по USB — http://127.0.0.1:8000/api/v1 вместе с
/// `adb reverse tcp:8000 tcp:8000`, с эмулятора — http://10.0.2.2:8000/api/v1.
class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://korgenshop.kz/api/v1',
  );
}
