import '../entities/category.dart';
import '../entities/hero_banner.dart';

/// Контент главной: слайды баннера и сетка категорий.
abstract class HomeRepository {
  Future<List<HeroBanner>> getBanners();

  Future<List<Category>> getCategories();
}
