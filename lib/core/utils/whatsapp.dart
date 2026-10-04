import 'package:url_launcher/url_launcher.dart';

/// Переход в WhatsApp на номер компании с заготовленным текстом.
class WhatsApp {
  const WhatsApp._();

  /// Номер в международном формате без плюса и разделителей.
  static const phone = '77756131326';

  static Uri chatUri(String message) =>
      Uri.https('wa.me', '/$phone', {if (message.isNotEmpty) 'text': message});

  /// Возвращает false, если на устройстве нечем открыть ссылку —
  /// вызывающий код покажет подсказку.
  static Future<bool> open(String message) async {
    final uri = chatUri(message);

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}
