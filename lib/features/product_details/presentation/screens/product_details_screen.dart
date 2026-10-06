import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_reviews.dart';
import '../widgets/product_tabs.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/utils/whatsapp.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productByIdProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: true,
        onLeadingTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.catalog);
          }
        },
      ),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(ref.strings.t('common.error', params: {'error': error})),
        ),
        data: (item) {
          if (item == null) {
            return Center(
              child: Text(
                ref.strings.t('product.notFound'),
                style: AppTextStyles.body,
              ),
            );
          }
          return _ProductBody(product: item);
        },
      ),
    );
  }
}

class _ProductBody extends ConsumerWidget {
  const _ProductBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final inCart = ref
        .watch(cartProvider)
        .any((line) => line.product.id == product.id);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ProductGallery(images: product.images),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelBadge(product.categoryLabel, uppercase: true),
              const SizedBox(height: 8),
              Text(product.name, style: AppTextStyles.display),
              const SizedBox(height: 4),
              Text(product.shortDescription, style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(product.formattedPrice, style: AppTextStyles.priceLarge),
                  const SizedBox(width: 16),
                  if (product.inStock) const _StockBadge(),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: strings.t(
                    inCart ? 'product.inCart' : 'product.addToCart',
                  ),
                  onPressed: () {
                    ref.read(cartProvider.notifier).add(product);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                  icon: const AppIcon(
                    'cart_large',
                    width: 19.982,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: strings.t('product.whatsapp'),
                  onPressed: () async {
                    final opened = await WhatsApp.open(
                      strings.t(
                        'product.whatsappMessage',
                        params: {'subject': product.name},
                      ),
                    );

                    if (opened || !context.mounted) return;

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.t('product.whatsappUnavailable'),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                  icon: const AppIcon.square(
                    'chat',
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ProductTabs(product: product),
              const SizedBox(height: 32),
              ProductReviews(
                product: product,
                // Отзывы приходят внутри карточки, поэтому после отправки
                // перезапрашиваем её целиком.
                onSent: () => ref.invalidate(productByIdProvider(product.id)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockBadge extends ConsumerWidget {
  const _StockBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon.square(
            'check_circle',
            size: 11.667,
            color: AppColors.primaryPaleText,
          ),
          const SizedBox(width: 4),
          Text(
            ref.strings.t('product.inStock'),
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryPaleText,
            ),
          ),
        ],
      ),
    );
  }
}
