import '../../../../core/network/api_client.dart';
import '../../domain/entities/hero_banner.dart';

/// Слайды главной из GET /sliders.
class BannerApiDataSource {
  const BannerApiDataSource(this._api);

  final ApiClient _api;

  Future<List<HeroBanner>> fetchBanners() async {
    final data = await _api.get('/sliders');
    final items = (data as Map)['data'] as List<dynamic>? ?? const [];

    return items
        .map((item) {
          final json = item as Map<String, dynamic>;
          final content = '${json['content'] ?? ''}'.trim();

          return HeroBanner(
            id: '${json['id'] ?? ''}',
            label: '${json['type'] ?? ''}'.toUpperCase(),
            title: content,
            ctaLabel: 'Подробнее',
            image: '${json['image'] ?? ''}',
          );
        })
        .where((banner) => banner.image.isNotEmpty)
        .toList();
  }
}
