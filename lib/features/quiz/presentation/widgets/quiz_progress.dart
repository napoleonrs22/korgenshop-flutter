import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Прогресс визарда: «Step X of N», название квиза и полоска.
class QuizProgress extends StatelessWidget {
  const QuizProgress({
    required this.stepLabel,
    required this.quizTitle,
    required this.progress,
    super.key,
  });

  final String stepLabel;
  final String quizTitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stepLabel, style: style),
            Flexible(
              child: Text(
                quizTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.progressTrack,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
