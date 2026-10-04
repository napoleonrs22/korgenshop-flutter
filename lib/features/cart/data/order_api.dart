import '../../../core/network/api_client.dart';
import '../presentation/providers/cart_providers.dart';

/// Оформление заказа: POST /orders.
///
/// Корзина живёт на клиенте, на сервер уходит только состав —
/// цену и НДС считает бэкенд.
class OrderApiDataSource {
  const OrderApiDataSource(this._api);

  final ApiClient _api;

  Future<int> createOrder({
    required List<CartLine> lines,
    required String name,
    required String phone,
    required String email,
    required String city,
    required String address,
    String country = 'Казахстан',
    String customerType = 'individual',
    String deliveryService = 'transport_company',
    String paymentMethod = 'bank_card',
    String? comment,
  }) async {
    final data = await _api.post(
      '/orders',
      body: {
        'items': [
          for (final line in lines)
            {'product_id': line.product.remoteId, 'quantity': line.quantity},
        ],
        'customer_type': customerType,
        'name': name,
        'phone': phone,
        'email': email,
        'country': country,
        'city': city,
        'address': address,
        'delivery_service': deliveryService,
        'payment_method': paymentMethod,
        'comment': comment,
      },
    );

    final order = (data as Map)['order'];
    final payload = order is Map && order['data'] is Map
        ? order['data'] as Map
        : order as Map?;

    return (payload?['id'] as num?)?.toInt() ?? 0;
  }
}
