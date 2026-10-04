import '../../../../core/network/api_client.dart';
import '../../domain/entities/category.dart';

/// Категории из API. Иконки в бэкенде не хранятся — подбираем локально
/// по slug, а для незнакомых категорий берём запасную.
class CategoryApiDataSource {
  const CategoryApiDataSource(this._api);

  final ApiClient _api;

  static const _fallback = (name: 'cat_cameras', width: 26.667, height: 21.333);

  static const _icons = <String, ({String name, double width, double height})>{
    'kamery': (name: 'cat_cameras', width: 26.667, height: 21.333),
    'cameras': (name: 'cat_cameras', width: 26.667, height: 21.333),
    'videoregistratory': (name: 'cat_nvr', width: 24, height: 25.333),
    'nvr': (name: 'cat_nvr', width: 24, height: 25.333),
    'poe-kommutatory': (name: 'cat_poe', width: 24.867, height: 25.333),
    'poe': (name: 'cat_poe', width: 24.867, height: 25.333),
    'turnikety': (name: 'cat_turnstiles', width: 24, height: 24),
    'turnstiles': (name: 'cat_turnstiles', width: 24, height: 24),
    'shlagbaumy': (name: 'cat_barriers', width: 26.667, height: 20),
    'barriers': (name: 'cat_barriers', width: 26.667, height: 20),
  };

  Future<List<Category>> fetchCategories() async {
    final data = await _api.get('/categories');
    final items = (data as Map)['data'] as List<dynamic>? ?? const [];

    return items.map((item) {
      final json = item as Map<String, dynamic>;
      final slug = '${json['slug'] ?? ''}';
      final icon = _icons[slug] ?? _fallback;

      return Category(
        id: slug,
        title: '${json['title'] ?? ''}',
        icon: icon.name,
        iconWidth: icon.width,
        iconHeight: icon.height,
      );
    }).toList();
  }
}
