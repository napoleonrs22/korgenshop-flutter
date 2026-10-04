/// Категория оборудования на главной.
class Category {
  const Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String id;
  final String title;

  /// Имя SVG-ассета в `assets/icons` без расширения.
  final String icon;

  /// Размеры иконки из макета — задаются явно, экспорт идёт без
  /// сохранения пропорций.
  final double iconWidth;
  final double iconHeight;
}
