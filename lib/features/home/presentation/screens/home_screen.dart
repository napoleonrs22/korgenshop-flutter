import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_menu_sheet.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_project_card.dart';
import '../widgets/hero_slider.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/theme/app_radii.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final banners = ref.watch(bannersProvider);
    final categories = ref.watch(categoriesProvider);
    final projects = ref.watch(featuredProjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onLeadingTap: () => AppMenuSheet.show(context),
        onActionTap: () => context.go(AppRoutes.catalog),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          banners.when(
            loading: () => const _HeroPlaceholder(),
            error: (_, _) => const _HeroPlaceholder(),
            data: (items) => HeroSlider(
              banners: items,
              onCtaTap: (_) => context.go(AppRoutes.quizzes),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: strings.t('home.categoriesTitle'),
            actionLabel: strings.t('home.allCategories'),
            onActionTap: () {
              ref.read(categoryFilterProvider.notifier).state = null;
              context.go(AppRoutes.catalog);
            },
          ),
          const SizedBox(height: 16),
          categories.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Text(
              strings.t('home.errorCategories', params: {'error': error}),
            ),
            data: (items) => CategoryGrid(
              categories: items,
              onTap: (category) {
                ref.read(categoryFilterProvider.notifier).state = category.id;
                context.go(AppRoutes.catalog);
              },
            ),
          ),
          const SizedBox(height: 40),
          SectionHeader(
            title: strings.t('home.projectsTitle'),
            actionLabel: strings.t('home.allProjects'),
            onActionTap: () => context.go(AppRoutes.projects),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 304,
            child: projects.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                strings.t('home.errorProjects', params: {'error': error}),
              ),
              data: (items) => ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, i) => FeaturedProjectCard(
                  project: items[i],
                  onTap: () => context.go(AppRoutes.projects),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    );
  }
}
