import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radii.dart';

/// Бейдж-лейбл в форме таблетки (SKU, категория, статусы).
class LabelBadge extends StatelessWidget {
  const LabelBadge(
    this.text, {
    this.background = AppColors.divider,
    this.foreground = AppColors.textTertiary,
    this.borderColor,
    this.uppercase = false,
    this.radius = AppRadii.pill,
    this.maxLines,
    super.key,
  });

  /// Голубой вариант — статусы вроде «In Stock» / «High Voltage».
  const LabelBadge.accent(
    this.text, {
    this.uppercase = false,
    this.radius = AppRadii.pill,
    this.maxLines,
    super.key,
  }) : background = AppColors.primaryPale,
       foreground = AppColors.primaryPaleText,
       borderColor = null;

  final String text;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final bool uppercase;
  final double radius;

  /// Ограничение строк. Нужно там, где высота карточки фиксирована и
  /// перенос подписи выталкивает содержимое за край.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        uppercase ? text.toUpperCase() : text,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: AppTextStyles.label.copyWith(color: foreground),
      ),
    );
  }
}

/// Тег карточки проекта: серый фон, тонкий бордер, форма таблетки.
class OutlinedTag extends StatelessWidget {
  const OutlinedTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
