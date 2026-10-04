import '../entities/product.dart';
import '../entities/product_page.dart';

/// Контракт слоя данных для товаров.
///
/// Фильтр, сортировку и постраничную выдачу выполняет сервер: каталог
/// большой, тянуть его целиком и резать на клиенте нельзя.
abstract class ProductRepository {
  Future<ProductPage> getProducts({
    String? categorySlug,
    String? sort,
    String? search,
    int page,
  });

  Future<Product?> getProductById(String id);
}
