import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../data/payment_api.dart';
import '../../../../core/network/network_providers.dart';

/// Позиция корзины.
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get total => product.price * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

/// Корзина живёт в памяти — оформления заказа в макете нет.
class CartNotifier extends StateNotifier<List<CartLine>> {
  CartNotifier() : super(const []);

  void add(Product product) {
    final index = state.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      state = [...state, CartLine(product: product, quantity: 1)];
      return;
    }
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(quantity: state[i].quantity + 1)
        else
          state[i],
    ];
  }

  void remove(String productId) {
    state = state.where((line) => line.product.id != productId).toList();
  }

  void decrease(String productId) {
    final index = state.indexWhere((line) => line.product.id == productId);
    if (index == -1) return;
    if (state[index].quantity <= 1) {
      remove(productId);
      return;
    }
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(quantity: state[i].quantity - 1)
        else
          state[i],
    ];
  }

  void clear() => state = const [];

  bool contains(String productId) =>
      state.any((line) => line.product.id == productId);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartLine>>(
  (ref) => CartNotifier(),
);

/// Суммарное количество единиц — бейдж на иконке корзины.
final cartCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, line) => sum + line.quantity);
});

final cartTotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, line) => sum + line.total);
});

/// Способы оплаты с бэкенда.
final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>(
  (ref) => PaymentApiDataSource(ref.watch(apiClientProvider)).fetchMethods(),
);

/// Выбранный способ оплаты.
final paymentMethodProvider = StateProvider<String>((ref) => 'bank_card');
