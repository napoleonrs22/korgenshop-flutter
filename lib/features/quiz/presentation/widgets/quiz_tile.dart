import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/quiz.dart';
import '../../../../core/theme/app_radii.dart';

/// Карточка квиза: фото с градиентом, бейдж длительности, иконка,
/// заголовок и описание.
class QuizTile extends StatelessWidget {
  const QuizTile({required this.quiz, required this.onTap, super.key});

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadii.card,
      shadows: const [],
      clip: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.imagePlaceholder,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(quiz.image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xE6FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 8,
                    child: _DurationBadge(duration: quiz.duration),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconPlate(
                      size: 48,
                      background: const Color(0x331F5EA8),
                      child: AppIcon(
                        quiz.icon,
                        width: quiz.iconWidth,
                        height: quiz.iconHeight,
                        color: AppColors.primary,
                      ),
                    ),
                    const AppIcon.square(
                      'arrow_right',
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.title,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(quiz.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.divider,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
            'clock',
            width: 10.5,
            height: 12.25,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(duration, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
