import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_menu_sheet.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/catalog_providers.dart';
import '../widgets/filters_sheet.dart';
import '../widgets/product_card.dart';
import '../../../../core/l10n/locale_providers.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// За 400 пикселей до конца просим следующую страницу — так подгрузка
  /// успевает завершиться до того, как пользователь упрётся в конец.
  void _onScroll() {
    if (!_scroll.hasClients) return;

    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 400) {
      ref.read(catalogProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final catalog = ref.watch(catalogProvider);
    final sort = ref.watch(sortProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onLeadingTap: () => AppMenuSheet.show(context),
        onActionTap: () => FiltersSheet.show(context),
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _BorderedRow(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.t('catalog.filters'), style: AppTextStyles.h3),
                InkWell(
                  onTap: () => FiltersSheet.show(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: AppIcon.square(
                      'filter',
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _BorderedRow(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    strings.t(
                      'catalog.results',
                      params: {'count': catalog.total},
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _SortDropdown(
                    value: sort,
                    onChanged: (value) =>
                        ref.read(sortProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (catalog.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (catalog.error != null && catalog.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Text(
                  strings.t('catalog.error', params: {'error': catalog.error!}),
                ),
              ),
            )
          else if (catalog.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Text(
                  strings.t('catalog.empty'),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            )
          else ...[
            for (final product in catalog.items) ...[
              ProductCard(
                product: product,
                inCart: cart.any((l) => l.product.id == product.id),
                onAddToCart: () => ref.read(cartProvider.notifier).add(product),
                onDetails: () => context.go(AppRoutes.product(product.id)),
              ),
              const SizedBox(height: 16),
            ],
            if (catalog.loadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ],
      ),
    );
  }
}

/// Строка с нижним бордером — так в макете оформлены «Filters» и сорт-бар.
class _BorderedRow extends StatelessWidget {
  const _BorderedRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 17),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}

class _SortDropdown extends ConsumerWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            strings.t('catalog.sortBy'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductSort>(
              value: value,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(4),
              icon: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.expand_more, size: 18),
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              items: [
                for (final option in ProductSort.values)
                  DropdownMenuItem(
                    value: option,
                    child: Text(strings.t(option.labelKey)),
                  ),
              ],
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }
}
