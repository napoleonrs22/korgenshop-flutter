import '../../../../core/utils/money.dart';
import 'product_review.dart';

/// Товар каталога.
class Product {
  const Product({
    required this.id,
    required this.remoteId,
    required this.name,
    required this.categoryId,
    required this.categoryLabel,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.images,
    required this.specifications,
    this.badge,
    this.inStock = true,
    this.reviews = const [],
  });

  /// Slug — им адресуются маршруты приложения и API.
  final String id;

  /// Числовой идентификатор из БД: нужен при оформлении заказа.
  final int remoteId;

  final String name;
  final String categoryId;

  /// Подпись категории на карточке товара.
  final String categoryLabel;

  final String shortDescription;
  final String description;

  /// Целое число тенге, без копеек — так цена хранится на бэкенде.
  final int price;

  /// Абсолютные URL галереи; первый используется как превью в каталоге.
  final List<String> images;

  /// Пары для вкладки «Характеристики».
  final Map<String, String> specifications;

  /// Бейдж поверх фото в каталоге, например «Под заказ».
  final String? badge;

  final bool inStock;

  /// Отзывы приходят вместе с карточкой товара, отдельного запроса нет.
  final List<ProductReview> reviews;

  String get formattedPrice => Money.format(price);

  /// Средняя оценка. Ноль означает «отзывов нет» — звёзды не рисуем.
  double get rating => reviews.isEmpty
      ? 0
      : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
            reviews.length;
}
