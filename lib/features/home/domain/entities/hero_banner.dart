/// Слайд hero-баннера на главной.
class HeroBanner {
  const HeroBanner({
    required this.id,
    required this.label,
    required this.title,
    required this.ctaLabel,
    required this.image,
  });

  final String id;

  /// Бейдж над заголовком, например «СЕРВИС».
  final String label;

  final String title;
  final String ctaLabel;
  final String image;
}
