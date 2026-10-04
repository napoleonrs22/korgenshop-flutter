/// Реализованный проект.
class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.category,
    this.client,
    this.year,
    this.tags = const [],
  });

  /// Slug — им адресуются маршруты приложения и API.
  final String id;

  final String title;
  final String description;

  /// Абсолютный URL обложки; null, если картинки нет.
  final String? image;

  /// Бейдж поверх фото. На бэкенде это поле `badge`.
  final String? category;

  /// Подпись под заголовком. На бэкенде это `subtitle`.
  final String? client;

  /// В API года нет — поле осталось для карточки на главной.
  final int? year;

  final List<String> tags;
}
