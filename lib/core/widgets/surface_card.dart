import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radii.dart';

/// Белый контейнер с бордером и лёгкой тенью — базовая карточка макета.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding,
    this.radius = AppRadii.card,
    this.borderColor = AppColors.border,
    this.shadows = AppColors.cardShadow,
    this.clip = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color borderColor;
  final List<BoxShadow> shadows;

  /// Обрезать содержимое по радиусу — нужно карточкам с фото на всю ширину.
  final bool clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: child,
    );

    if (onTap != null) {
      content = Stack(
        // passthrough: иначе Stack отдаёт карточке свободные ограничения,
        // и она сжимается по содержимому вместо ширины ячейки сетки.
        fit: StackFit.passthrough,
        children: [
          content,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, borderRadius: borderRadius),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// Заголовок секции с необязательной ссылкой справа.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(fontSize: 18, height: 24 / 18),
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onActionTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
