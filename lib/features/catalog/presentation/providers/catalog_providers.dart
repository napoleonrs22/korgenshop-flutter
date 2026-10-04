import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/product_api.dart';
import '../../../../core/network/network_providers.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) =>
      ProductRepositoryImpl(ProductApiDataSource(ref.watch(apiClientProvider))),
);

/// Варианты сортировки из дропдауна над сеткой.
enum ProductSort {
  recommended('catalog.sort.recommended', 'recommended'),
  priceAsc('catalog.sort.priceAsc', 'price_asc'),
  priceDesc('catalog.sort.priceDesc', 'price_desc'),
  nameAsc('catalog.sort.nameAsc', 'name_asc');

  const ProductSort(this.labelKey, this.apiValue);

  /// Ключ подписи в словаре локали.
  final String labelKey;

  /// Значение параметра `sort` в API.
  final String apiValue;
}

/// Выбранная категория; null — «все категории».
final categoryFilterProvider = StateProvider<String?>((ref) => null);

final sortProvider = StateProvider<ProductSort>(
  (ref) => ProductSort.recommended,
);

/// Состояние каталога: накопленные страницы плюс флаги загрузки.
class CatalogState {
  const CatalogState({
    this.items = const [],
    this.total = 0,
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
  });

  final List<Product> items;
  final int total;

  /// Первая загрузка или смена фильтра.
  final bool loading;

  /// Подгрузка следующей страницы внизу списка.
  final bool loadingMore;

  final bool hasMore;
  final Object? error;

  CatalogState copyWith({
    List<Product>? items,
    int? total,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    Object? error,
  }) {
    return CatalogState(
      items: items ?? this.items,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Подгружает каталог порциями по мере прокрутки.
class CatalogNotifier extends StateNotifier<CatalogState> {
  CatalogNotifier(this._repository, {this.category, required this.sort})
    : super(const CatalogState()) {
    loadFirstPage();
  }

  final ProductRepository _repository;
  final String? category;
  final String sort;

  int _page = 1;

  Future<void> loadFirstPage() async {
    state = const CatalogState();
    _page = 1;

    try {
      final page = await _repository.getProducts(
        categorySlug: category,
        sort: sort,
        page: 1,
      );

      if (!mounted) return;

      state = CatalogState(
        items: page.items,
        total: page.total,
        loading: false,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = CatalogState(loading: false, error: error);
    }
  }

  /// Вызывается, когда список прокручен почти до конца.
  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    state = state.copyWith(loadingMore: true);

    try {
      final page = await _repository.getProducts(
        categorySlug: category,
        sort: sort,
        page: _page + 1,
      );

      if (!mounted) return;

      _page = page.page;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        total: page.total,
        loadingMore: false,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = state.copyWith(loadingMore: false, error: error);
    }
  }
}

/// Пересоздаётся при смене фильтра или сортировки — и грузит первую
/// страницу заново.
final catalogProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((
  ref,
) {
  return CatalogNotifier(
    ref.watch(productRepositoryProvider),
    category: ref.watch(categoryFilterProvider),
    sort: ref.watch(sortProvider).apiValue,
  );
});

/// Карточка товара по slug.
final productByIdProvider = FutureProvider.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).getProductById(id),
);
