/// Отзыв о товаре.
class ProductReview {
  const ProductReview({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    this.advantages,
    this.disadvantages,
    this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: '${json['name'] ?? ''}',
      // Оценка приходит целым от 1 до 5; за пределы не выпускаем, чтобы
      // звёзды не рисовались в минус или с шестой.
      rating: ((json['rating'] as num?)?.toInt() ?? 0).clamp(0, 5),
      comment: '${json['comment'] ?? ''}',
      advantages: _text(json['advantages']),
      disadvantages: _text(json['disadvantages']),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
    );
  }

  final int id;
  final String name;
  final int rating;
  final String comment;
  final String? advantages;
  final String? disadvantages;
  final DateTime? createdAt;

  static String? _text(Object? value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }
}
