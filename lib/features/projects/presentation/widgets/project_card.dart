import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/project.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/remote_image.dart';

/// Карточка на экране «Реализованные проекты».
class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadii.card,
      borderColor: AppColors.divider,
      clip: true,
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
                  RemoteImage(project.image),
                  if (project.category != null)
                    Positioned(
                      left: 16,
                      top: 16,
                      child: LabelBadge(
                        project.category!,
                        uppercase: true,
                        borderColor: AppColors.border,
                        radius: AppRadii.pill,
                      ),
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
                Text(project.title, style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(project.description, style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final tag in project.tags) OutlinedTag(tag)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
