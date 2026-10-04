import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radii.dart';

/// Основная синяя кнопка.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.radius = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.textStyle,
    super.key,
  });

  /// Компактный вариант из карточки каталога: 12px uppercase, r2.
  factory PrimaryButton.compact({
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
  }) {
    return PrimaryButton(
      label: label.toUpperCase(),
      onPressed: onPressed,
      icon: icon,
      radius: AppRadii.control,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: AppTextStyles.label.copyWith(color: Colors.white),
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double radius;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding,
          child: Row(
            // min — кнопка может стоять не-flex ребёнком Row и получить
            // безграничную ширину; тогда Flexible внутри падает с ассертом.
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle ?? AppTextStyles.buttonLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Вторичная кнопка: белый фон, синий бордер и текст.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.radius = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.textStyle,
    super.key,
  });

  /// Компактный вариант «DETAILS» из карточки каталога.
  factory SecondaryButton.compact({
    required String label,
    VoidCallback? onPressed,
  }) {
    return SecondaryButton(
      label: label.toUpperCase(),
      onPressed: onPressed,
      radius: AppRadii.control,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: AppTextStyles.label.copyWith(color: AppColors.primary),
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double radius;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            // min — кнопка может стоять не-flex ребёнком Row и получить
            // безграничную ширину; тогда Flexible внутри падает с ассертом.
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style:
                      textStyle ??
                      AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
