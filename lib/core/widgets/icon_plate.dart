import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// Скруглённая плашка под иконкой — категории, опции квиза, WhatsApp-блок.
class IconPlate extends StatelessWidget {
  const IconPlate({
    required this.child,
    this.size = 56,
    this.radius = AppRadii.card,
    this.background = AppColors.primaryLight,
    super.key,
  });

  final Widget child;
  final double size;
  final double radius;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(child: child),
    );
  }
}
