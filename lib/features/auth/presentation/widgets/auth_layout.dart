import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';

/// Общая обвязка экранов подтверждения почты и восстановления пароля:
/// кнопка назад, плашка логотипа, заголовок и подпись.
///
/// Вход и регистрация свою вёрстку не меняют — там шапка отличается
/// (логотип KORGEN SHOP крупным текстом вместо заголовка экрана).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// Своя обработка «назад» — многошаговому экрану нужно вернуться на
  /// предыдущий шаг, а не закрыться целиком.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            if (onBack != null || context.canPop())
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onBack ?? context.pop,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Align: в ListView поперечное ограничение жёсткое, иначе
            // плашка растянулась бы на всю ширину.
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.imagePlaceholder,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(
                  child: AppIcon('logo_mark', width: 22, height: 22),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodySmall),
            const SizedBox(height: 40),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Основная кнопка шага — та же геометрия, что у кнопки входа.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
