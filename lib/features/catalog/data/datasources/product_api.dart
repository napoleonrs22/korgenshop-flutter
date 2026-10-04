import '../../../../core/network/api_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_review.dart';
import '../../domain/entities/product_page.dart';

/// Каталог из API: GET /products и GET /products/{slug}.
class ProductApiDataSource {
  const ProductApiDataSource(this._api);

  final ApiClient _api;

  Future<ProductPage> fetchProducts({
    String? categorySlug,
    String? search,
    String sort = 'recommended',
    int page = 1,
    int perPage = 50,
  }) async {
    final data = await _api.get(
      '/products',
      query: {
        'category': ?categorySlug,
        if (search != null && search.isNotEmpty) 'search': search,
        'sort': sort,
        'page': page,
        'per_page': perPage,
      },
    );

    final map = data as Map;
    final items = map['data'] as List<dynamic>? ?? const [];
    final meta = map['meta'] as Map<String, dynamic>? ?? const {};

    final currentPage = (meta['current_page'] as num?)?.toInt() ?? page;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? currentPage;

    return ProductPage(
      items: items
          .map((item) => _fromList(item as Map<String, dynamic>))
          .toList(),
      page: currentPage,
      hasMore: currentPage < lastPage,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
    );
  }

  Future<Product?> fetchProductBySlug(String slug) async {
    final data = await _api.get('/products/$slug');
    final item = (data as Map)['data'];

    if (item is! Map<String, dynamic>) return null;

    return _fromDetail(item);
  }

  /// Краткая карточка каталога: описания и характеристик в списке нет.
  Product _fromList(Map<String, dynamic> json) {
    return Product(
      id: '${json['slug'] ?? json['id']}',
      remoteId: (json['id'] as num?)?.toInt() ?? 0,
      name: '${json['title'] ?? ''}',
      categoryId: '${json['category_id'] ?? ''}',
      categoryLabel: '',
      shortDescription: '',
      description: '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      images: [
        if (json['image'] is String && (json['image'] as String).isNotEmpty)
          json['image'] as String,
      ],
      specifications: const {},
      badge: _badgeFrom(json),
      inStock: _inStock(json),
    );
  }

  Product _fromDetail(Map<String, dynamic> json) {
    final category = json['category'];
    final description = '${json['description'] ?? ''}';

    return Product(
      id: '${json['slug'] ?? json['id']}',
      remoteId: (json['id'] as num?)?.toInt() ?? 0,
      name: '${json['title'] ?? ''}',
      categoryId: '${json['category_id'] ?? ''}',
      categoryLabel: category is Map ? '${category['title'] ?? ''}' : '',
      shortDescription: _firstSentence(description),
      description: description,
      price: (json['price'] as num?)?.toInt() ?? 0,
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((item) => '$item')
          .where((item) => item.isNotEmpty)
          .toList(),
      specifications: _specifications(json['details']),
      badge: _badgeFrom(json),
      inStock: _inStock(json),
      reviews: _reviews(json['reviews']),
    );
  }

  /// Отзывы приходят только в детальной карточке; свежие ставим наверх.
  List<ProductReview> _reviews(Object? raw) {
    if (raw is! List) return const [];

    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(ProductReview.fromJson)
        .toList();

    items.sort((a, b) {
      final left = a.createdAt;
      final right = b.createdAt;
      if (left == null || right == null) return b.id.compareTo(a.id);
      return right.compareTo(left);
    });

    return items;
  }

  /// `details` приходит либо объектом, либо списком пар — поддерживаем оба.
  Map<String, String> _specifications(dynamic details) {
    if (details is Map) {
      return {
        for (final entry in details.entries) '${entry.key}': '${entry.value}',
      };
    }

    if (details is List) {
      final result = <String, String>{};
      for (final item in details) {
        if (item is Map && item.length >= 2) {
          final values = item.values.toList();
          result['${values.first}'] = '${values[1]}';
        }
      }
      return result;
    }

    return const {};
  }

  String? _badgeFrom(Map<String, dynamic> json) {
    final status = json['availability_status'];
    if (status is String && status.trim().isNotEmpty) return status;
    return null;
  }

  bool _inStock(Map<String, dynamic> json) {
    final status = '${json['availability_status'] ?? ''}'.toLowerCase();
    if (status.contains('нет') || status.contains('out')) return false;
    return json['is_active'] != false;
  }

  String _firstSentence(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    final end = trimmed.indexOf('. ');
    return end == -1 ? trimmed : trimmed.substring(0, end + 1);
  }
}
