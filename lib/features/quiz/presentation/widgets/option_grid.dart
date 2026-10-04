import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../domain/entities/quiz.dart';
import '../../../../core/theme/app_radii.dart';

/// Сетка вариантов ответа 2 × N. Выбранный вариант подсвечивается бордером.
class OptionGrid extends StatelessWidget {
  const OptionGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<QuizOption> options;
  final QuizOption? selected;
  final void Function(QuizOption option) onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      itemBuilder: (context, i) {
        final option = options[i];
        return _OptionCard(
          option: option,
          selected: selected?.id == option.id,
          onTap: () => onSelect(option),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      option.label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body.copyWith(
        color: selected ? AppColors.primary : AppColors.textPrimary,
      ),
    );

    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Толщину бордера не меняем — иначе карточка перерастает
            // фиксированную высоту сетки. Выбор показываем цветом.
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (option.icon != null) ...[
                IconPlate(
                  size: 48,
                  child: AppIcon(
                    option.icon!,
                    width: option.iconWidth,
                    height: option.iconHeight,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              label,
            ],
          ),
        ),
      ),
    );
  }
}
