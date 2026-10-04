import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/order_history_api.dart';
import '../../domain/entities/order.dart';

final orderHistoryApiProvider = Provider<OrderHistoryApi>(
  (ref) => OrderHistoryApi(ref.watch(apiClientProvider)),
);

/// История заказов текущего пользователя.
///
/// Зависит от состояния авторизации: после входа, выхода или смены пароля
/// список перезапрашивается сам — токен в клиенте к тому моменту уже другой.
final ordersProvider = FutureProvider<List<Order>>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;

  if (user == null) return Future.value(const []);

  return ref.watch(orderHistoryApiProvider).list();
});
