import '../../../core/network/api_client.dart';
import '../../catalog/domain/entities/product_review.dart';

/// Отправка отзыва: POST /products/{slug}/reviews.
///
/// Токен не обязателен — гость указывает имя сам, как и на сайте. Если токен
/// есть, сервер привяжет отзыв к аккаунту.
class ReviewApi {
  const ReviewApi(this._api);

  final ApiClient _api;

  Future<ProductReview> submit({
    required String productSlug,
    required String name,
    required int rating,
    required String comment,
    String? advantages,
    String? disadvantages,
  }) async {
    final data = await _api.post(
      '/products/$productSlug/reviews',
      body: {
        'name': name,
        'rating': rating,
        'comment': comment,
        'advantages': ?advantages,
        'disadvantages': ?disadvantages,
      },
    );

    return ProductReview.fromJson(
      (data as Map)['data'] as Map<String, dynamic>,
    );
  }
}
