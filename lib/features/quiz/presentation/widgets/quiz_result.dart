import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/quiz_estimate.dart';
import '../../../../core/utils/money.dart';

/// Финальный шаг визарда — предварительная смета по ответам.
class QuizResult extends ConsumerWidget {
  const QuizResult({required this.estimate, super.key});

  final QuizEstimate estimate;

  String _money(int value) => Money.format(value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t('quiz.estimateTitle'),
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          strings.t(
            'quiz.estimateBody',
            params: {'count': estimate.unitCount, 'unit': estimate.unitLabel},
          ),
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              _Line(
                label: strings.t('quiz.equipment'),
                value: _money(estimate.equipmentCost),
              ),
              const SizedBox(height: 8),
              _Line(
                label: strings.t('quiz.installation'),
                value: _money(estimate.installationCost),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.t('quiz.total'),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(_money(estimate.total), style: AppTextStyles.price),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          strings.t('quiz.yourAnswers'),
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final line in estimate.breakdown)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  line.value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
