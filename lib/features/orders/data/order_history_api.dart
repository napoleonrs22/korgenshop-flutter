import '../../../core/network/api_client.dart';
import '../domain/entities/order.dart';

/// История заказов: GET /orders.
///
/// Эндпоинт закрыт токеном и отдаёт только заказы текущего пользователя —
/// фильтровать на клиенте ничего не нужно.
class OrderHistoryApi {
  const OrderHistoryApi(this._api);

  final ApiClient _api;

  Future<List<Order>> list() async {
    final data = await _api.get('/orders');
    final rows = (data as Map)['data'];

    if (rows is! List) return const [];

    return rows.whereType<Map<String, dynamic>>().map(Order.fromJson).toList();
  }
}
