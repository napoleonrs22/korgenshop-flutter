import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Иконка, экспортированная из Figma.
///
/// Размеры задаются явно, потому что экспортированные SVG приходят с
/// `preserveAspectRatio="none"` — без фиксированных ширины и высоты
/// они растянутся по контейнеру.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    required this.width,
    required this.height,
    this.color,
    super.key,
  });

  /// Квадратная иконка.
  const AppIcon.square(this.name, {required double size, this.color, super.key})
    : width = size,
      height = size;

  final String name;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: width,
      height: height,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
