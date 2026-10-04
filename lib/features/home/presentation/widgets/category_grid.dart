import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_radii.dart';

/// Сетка категорий 2 × N: круглая плашка-иконка 64px и подпись.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    required this.categories,
    required this.onTap,
    super.key,
  });

  final List<Category> categories;
  final void Function(Category category) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      itemBuilder: (context, i) {
        final category = categories[i];
        return SurfaceCard(
          radius: AppRadii.card,
          // Во втором варианте у плиток нет бордера — только мягкая тень.
          borderColor: Colors.transparent,
          shadows: AppColors.elevatedShadow,
          padding: const EdgeInsets.all(20),
          onTap: () => onTap(category),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconPlate(
                child: AppIcon(
                  category.icon,
                  width: category.iconWidth,
                  height: category.iconHeight,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
