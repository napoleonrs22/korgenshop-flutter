import '../../../core/network/api_client.dart';

/// Реквизиты Kaspi: QR и ссылка из конфигурации бэкенда.
class KaspiDetails {
  const KaspiDetails({this.qr, this.url, required this.hint});

  final String? qr;
  final String? url;
  final String hint;
}

/// Способ оплаты для формы заказа.
class PaymentMethod {
  const PaymentMethod({required this.value, required this.title, this.kaspi});

  /// Значение для поля `payment_method`: bank_card или kaspi_remote.
  final String value;
  final String title;
  final KaspiDetails? kaspi;
}

class PaymentApiDataSource {
  const PaymentApiDataSource(this._api);

  final ApiClient _api;

  Future<List<PaymentMethod>> fetchMethods() async {
    final data = await _api.get('/payment-methods');
    final items = (data as Map)['data'] as List<dynamic>? ?? const [];

    return items.map((item) {
      final json = item as Map<String, dynamic>;
      final kaspi = json['kaspi'];

      return PaymentMethod(
        value: '${json['value'] ?? ''}',
        title: '${json['title'] ?? ''}',
        kaspi: kaspi is Map<String, dynamic>
            ? KaspiDetails(
                qr: _nullable(kaspi['qr']),
                url: _nullable(kaspi['url']),
                hint: '${kaspi['hint'] ?? ''}',
              )
            : null,
      );
    }).toList();
  }

  String? _nullable(dynamic value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }
}
