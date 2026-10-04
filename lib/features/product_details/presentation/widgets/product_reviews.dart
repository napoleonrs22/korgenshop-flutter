import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_review.dart';
import 'review_sheet.dart';
import 'review_stars.dart';

/// Блок отзывов под вкладками карточки товара.
class ProductReviews extends ConsumerWidget {
  const ProductReviews({required this.product, required this.onSent, super.key});

  final Product product;

  /// Вызывается после успешной отправки — карточку нужно перезапросить,
  /// чтобы новый отзыв появился в списке.
  final VoidCallback onSent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final reviews = product.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.t('reviews.title'),
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ),
            if (reviews.isNotEmpty) ...[
              ReviewStars(rating: product.rating),
              const SizedBox(width: 8),
              Text(
                product.rating.toStringAsFixed(1),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          reviews.isEmpty
              ? strings.t('reviews.empty')
              : strings.t('reviews.count', params: {'count': reviews.length}),
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        for (final review in reviews) ...[
          _ReviewCard(review: review),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () async {
              final sent = await ReviewSheet.show(context, slug: product.id);
              if (!sent || !context.mounted) return;

              onSent();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(strings.t('reviews.sent')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
            ),
            child: Text(
              strings.t('reviews.write'),
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.name,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ReviewStars(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.createdAt != null) ...[
            const SizedBox(height: 2),
            Text(_date(review.createdAt!), style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 8),
          Text(review.comment, style: AppTextStyles.bodySmall),
          if (review.advantages != null)
            _Aspect(sign: '+', text: review.advantages!),
          if (review.disadvantages != null)
            _Aspect(sign: '−', text: review.disadvantages!),
        ],
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');

    return '${two(local.day)}.${two(local.month)}.${local.year}';
  }
}

/// Плюсы и минусы: короткая строка со знаком вместо отдельного заголовка.
class _Aspect extends StatelessWidget {
  const _Aspect({required this.sign, required this.text});

  final String sign;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Text(
              sign,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
