import 'product.dart';

/// Страница каталога: сервер отдаёт товары порциями.
class ProductPage {
  const ProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.total,
  });

  final List<Product> items;

  /// Номер текущей страницы, начиная с единицы.
  final int page;

  /// Есть ли ещё страницы — по `meta.last_page`.
  final bool hasMore;

  /// Всего товаров под текущим фильтром.
  final int total;
}
