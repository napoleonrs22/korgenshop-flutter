import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_api.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final ProductApiDataSource _dataSource;

  @override
  Future<ProductPage> getProducts({
    String? categorySlug,
    String? sort,
    String? search,
    int page = 1,
  }) => _dataSource.fetchProducts(
    categorySlug: categorySlug,
    sort: sort ?? 'recommended',
    search: search,
    page: page,
  );

  @override
  Future<Product?> getProductById(String id) =>
      _dataSource.fetchProductBySlug(id);
}
