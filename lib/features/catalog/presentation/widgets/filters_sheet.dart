import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../providers/catalog_providers.dart';
import '../../../../core/l10n/locale_providers.dart';

/// Фильтры каталога. На мобильном сайдбар из макета раскрывается
/// нижним листом.
class FiltersSheet extends ConsumerWidget {
  const FiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(categoryFilterProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('catalog.filters'), style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Text(
              strings.t('catalog.category'),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Ошибка: $error'),
              data: (items) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: strings.t('catalog.all'),
                    selected: selected == null,
                    onTap: () =>
                        ref.read(categoryFilterProvider.notifier).state = null,
                  ),
                  for (final category in items)
                    _FilterChip(
                      label: category.title,
                      selected: selected == category.id,
                      onTap: () =>
                          ref.read(categoryFilterProvider.notifier).state =
                              category.id,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: strings.t('catalog.showResults'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
