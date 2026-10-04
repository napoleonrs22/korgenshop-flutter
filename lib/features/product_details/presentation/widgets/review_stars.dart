import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Пять звёзд: показ оценки и, если задан [onRate], её выбор.
class ReviewStars extends StatelessWidget {
  const ReviewStars({
    required this.rating,
    this.size = 16,
    this.onRate,
    super.key,
  });

  /// Дробное значение допустимо: средняя оценка округляется до половины.
  final double rating;
  final double size;
  final void Function(int value)? onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onRate == null ? null : () => onRate!(i),
            child: Padding(
              padding: EdgeInsets.only(right: i == 5 ? 0 : size * .18),
              child: Icon(
                _iconFor(i),
                size: size,
                color: rating >= i - .5
                    ? const Color(0xFFF5A623)
                    : AppColors.border,
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(int index) {
    // Базовые начертания, а не «rounded»: те лежат в отдельном наборе и
    // не всегда доступны — в тестах отрисовывались пустыми квадратами.
    if (rating >= index) return Icons.star;
    // Половинка нужна только для средней оценки; при выборе её не бывает.
    if (rating >= index - .5) return Icons.star_half;
    return Icons.star_border;
  }
}
