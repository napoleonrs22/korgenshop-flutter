import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/remote_image.dart';

/// Карточка проекта в горизонтальной карусели на главной.
class FeaturedProjectCard extends StatelessWidget {
  const FeaturedProjectCard({
    required this.project,
    required this.onTap,
    super.key,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: SurfaceCard(
        radius: AppRadii.card,
        shadows: AppColors.brandShadow,
        clip: true,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ColoredBox(
                color: AppColors.imagePlaceholder,
                child: RemoteImage(project.image),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // В API у проекта нет заказчика и года: показываем то,
                    // что пришло, и не рисуем пустые чипы.
                    if (project.client != null || project.year != null) ...[
                      Row(
                        children: [
                          if (project.client != null)
                            Flexible(
                              child: LabelBadge(
                                project.client!,
                                background: AppColors.chipBackground,
                                maxLines: 1,
                              ),
                            ),
                          if (project.client != null && project.year != null)
                            const SizedBox(width: 8),
                          if (project.year != null)
                            LabelBadge(
                              '${project.year}',
                              background: AppColors.chipBackground,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
