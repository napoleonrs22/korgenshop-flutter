import '../../domain/entities/category.dart';
import '../../domain/entities/hero_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/banner_api.dart';
import '../datasources/category_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._banners, this._categories);

  final BannerApiDataSource _banners;
  final CategoryApiDataSource _categories;

  @override
  Future<List<HeroBanner>> getBanners() => _banners.fetchBanners();

  @override
  Future<List<Category>> getCategories() => _categories.fetchCategories();
}
