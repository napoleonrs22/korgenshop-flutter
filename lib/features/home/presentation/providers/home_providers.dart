import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/hero_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../projects/presentation/providers/projects_providers.dart';
import '../../data/datasources/category_api.dart';
import '../../data/datasources/banner_api.dart';
import '../../../../core/network/network_providers.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    BannerApiDataSource(ref.watch(apiClientProvider)),
    CategoryApiDataSource(ref.watch(apiClientProvider)),
  ),
);

final bannersProvider = FutureProvider<List<HeroBanner>>(
  (ref) => ref.watch(homeRepositoryProvider).getBanners(),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(homeRepositoryProvider).getCategories(),
);

final featuredProjectsProvider = FutureProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).getFeaturedProjects(),
);

/// Активный слайд hero-баннера.
final heroSlideProvider = StateProvider<int>((ref) => 0);
