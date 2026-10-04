import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/product.dart';
import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/remote_image.dart';

/// Карточка товара в каталоге: фото с бейджами, заголовок, цена, две кнопки.
class ProductCard extends ConsumerWidget {
  const ProductCard({
    required this.product,
    required this.inCart,
    required this.onAddToCart,
    required this.onDetails,
    super.key,
  });

  final Product product;
  final bool inCart;
  final VoidCallback onAddToCart;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return SurfaceCard(
      radius: AppRadii.card,
      borderColor: AppColors.divider,
      shadows: const [],
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.imagePlaceholder,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: RemoteImage(
                        product.images.isEmpty ? null : product.images.first,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Один бейдж: статус наличия из API, иначе «в наличии».
                  Positioned(
                    left: 8,
                    top: 8,
                    child: product.badge == null
                        ? LabelBadge(strings.t('product.inStock'))
                        : LabelBadge.accent(product.badge!),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.formattedPrice, style: AppTextStyles.price),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton.compact(
                        label: strings.t(
                          inCart ? 'catalog.inCart' : 'catalog.addToCart',
                        ),
                        onPressed: onAddToCart,
                        icon: const AppIcon(
                          'cart_small',
                          width: 14.986,
                          height: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SecondaryButton.compact(
                      label: strings.t('catalog.details'),
                      onPressed: onDetails,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
