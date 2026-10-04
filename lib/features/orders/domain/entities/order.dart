/// Позиция заказа: товар, количество и цена на момент покупки.
class OrderItem {
  const OrderItem({
    required this.title,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toInt() ?? 0;
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;

    return OrderItem(
      title: '${json['title'] ?? ''}',
      quantity: quantity,
      price: price,
      lineTotal: (json['line_total'] as num?)?.toInt() ?? price * quantity,
      image: json['image'] is String && (json['image'] as String).isNotEmpty
          ? json['image'] as String
          : null,
    );
  }

  final String title;
  final int quantity;
  final int price;
  final int lineTotal;
  final String? image;
}

/// Заказ из истории покупок.
class Order {
  const Order({
    required this.id,
    required this.statusTitle,
    required this.total,
    required this.totalCount,
    required this.items,
    this.createdAt,
    this.city,
    this.address,
    this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final items = json['items'];

    return Order(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // Человекочитаемый статус приходит с сервера; при его отсутствии
      // показываем код, а не пустую строку.
      statusTitle: '${json['status_title'] ?? json['status'] ?? ''}',
      total: (json['summa'] as num?)?.toInt() ?? 0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      city: _text(json['city']),
      address: _text(json['address']),
      paymentMethod: _text(json['payment_method']),
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(OrderItem.fromJson)
                .toList()
          : const [],
    );
  }

  final int id;
  final String statusTitle;
  final int total;
  final int totalCount;
  final DateTime? createdAt;
  final String? city;
  final String? address;
  final String? paymentMethod;
  final List<OrderItem> items;

  /// Адрес одной строкой: город и улица, если оба заполнены.
  String? get place {
    final parts = [city, address].where(
      (part) => part != null && part.isNotEmpty,
    );

    return parts.isEmpty ? null : parts.join(', ');
  }

  static String? _text(Object? value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }
}
