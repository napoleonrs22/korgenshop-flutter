/// Вариант ответа на шаге квиза.
class QuizOption {
  const QuizOption({
    required this.id,
    required this.label,
    required this.value,
    this.icon,
    this.iconWidth = 20,
    this.iconHeight = 20,
  });

  final String id;
  final String label;

  /// Числовой вес варианта — используется при расчёте сметы.
  final double value;

  /// Имя SVG-ассета без расширения; если null — рисуется плашка без иконки.
  final String? icon;
  final double iconWidth;
  final double iconHeight;
}

/// Один шаг-вопрос квиза.
class QuizStep {
  const QuizStep({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<QuizOption> options;
}

/// Квиз целиком: карточка на экране выбора + шаги визарда.
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.duration,
    required this.image,
    required this.icon,
    required this.steps,
    required this.unitLabel,
    this.iconWidth = 20,
    this.iconHeight = 16,
  });

  final String id;

  /// Заголовок карточки на экране выбора квиза.
  final String title;

  /// Короткое название — показывается в прогресс-баре визарда.
  final String shortTitle;

  final String description;

  /// Оценка времени прохождения, например «3-5 мин».
  final String duration;

  final String image;
  final String icon;
  final double iconWidth;
  final double iconHeight;

  final List<QuizStep> steps;

  /// Что считаем в смете: «камер», «точек прохода».
  final String unitLabel;

  /// Шагов всего: вопросы, шаг с фотографиями объекта и экран сметы.
  int get totalSteps => steps.length + 2;
}
