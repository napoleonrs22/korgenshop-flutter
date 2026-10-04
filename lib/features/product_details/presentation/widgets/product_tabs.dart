import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../../core/l10n/locale_providers.dart';

enum ProductTab { description, specifications, video }

/// Табы карточки товара: подчёркивание активного, контент под ними.
class ProductTabs extends ConsumerStatefulWidget {
  const ProductTabs({required this.product, super.key});

  final Product product;

  @override
  ConsumerState<ProductTabs> createState() => _ProductTabsState();
}

class _ProductTabsState extends ConsumerState<ProductTabs> {
  ProductTab _active = ProductTab.description;

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Tab(
                  label: strings.t('product.tabDescription'),
                  active: _active == ProductTab.description,
                  onTap: () => setState(() => _active = ProductTab.description),
                ),
                const SizedBox(width: 16),
                _Tab(
                  label: strings.t('product.tabSpecifications'),
                  active: _active == ProductTab.specifications,
                  onTap: () =>
                      setState(() => _active = ProductTab.specifications),
                ),
                const SizedBox(width: 16),
                _Tab(
                  label: strings.t('product.tabVideo'),
                  active: _active == ProductTab.video,
                  trailing: const AppIcon.square(
                    'play',
                    size: 15,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => setState(() => _active = ProductTab.video),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        switch (_active) {
          ProductTab.description => _DescriptionTab(product: widget.product),
          ProductTab.specifications => _SpecificationsTab(
            specifications: widget.product.specifications,
          ),
          ProductTab.video => const _VideoTab(),
        },
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.h3.copyWith(
                color: active ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(product.description, style: AppTextStyles.body)],
    );
  }
}

class _SpecificationsTab extends StatelessWidget {
  const _SpecificationsTab({required this.specifications});

  final Map<String, String> specifications;

  @override
  Widget build(BuildContext context) {
    final entries = specifications.entries.toList();

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: i == entries.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entries[i].key,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entries[i].value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VideoTab extends ConsumerWidget {
  const _VideoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_outline,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            ref.strings.t('product.videoSoon'),
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
