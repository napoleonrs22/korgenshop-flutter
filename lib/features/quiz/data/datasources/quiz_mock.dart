import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/quiz.dart';

/// Конфигурация квизов.
///
/// Веса вариантов, иконки и картинки не зависят от языка и заданы здесь;
/// вопросы и подписи вариантов приходят из словаря локали.
class QuizMockDataSource {
  const QuizMockDataSource(this._strings);

  final AppStrings _strings;

  static const _latency = Duration(milliseconds: 200);

  Future<List<Quiz>> fetchQuizzes() async {
    await Future<void>.delayed(_latency);
    return _specs.map(_build).toList();
  }

  Future<Quiz?> fetchQuizById(String id) async {
    await Future<void>.delayed(_latency);
    for (final spec in _specs) {
      if (spec.id == id) return _build(spec);
    }
    return null;
  }

  Quiz _build(_QuizSpec spec) {
    final path = 'content.quizzes.${spec.id}';
    return Quiz(
      id: spec.id,
      title: _strings.t('$path.title'),
      shortTitle: _strings.t('$path.shortTitle'),
      description: _strings.t('$path.description'),
      duration: _strings.t('$path.duration'),
      image: spec.image,
      icon: spec.icon,
      iconWidth: spec.iconWidth,
      iconHeight: spec.iconHeight,
      unitLabel: _strings.t('$path.unitLabel'),
      steps: [
        for (final step in spec.steps)
          QuizStep(
            id: step.id,
            question: _strings.t('$path.steps.${step.id}.question'),
            options: [
              for (final option in step.options)
                QuizOption(
                  id: option.id,
                  label: _strings.t(
                    '$path.steps.${step.id}.options.${option.id}',
                  ),
                  value: option.value,
                  icon: option.icon,
                  iconWidth: option.iconWidth,
                  iconHeight: option.iconHeight,
                ),
            ],
          ),
      ],
    );
  }

  static const _specs = <_QuizSpec>[
    _QuizSpec(
      id: 'cctv',
      image: 'assets/images/quiz_cctv.jpg',
      icon: 'quiz_camera',
      iconWidth: 20,
      iconHeight: 16,
      steps: [
        _StepSpec(
          id: 'object_type',
          options: [
            _OptionSpec(
              id: 'apartment',
              value: 4,
              icon: 'obj_apartment',
              iconWidth: 16,
              iconHeight: 18,
            ),
            _OptionSpec(
              id: 'retail',
              value: 8,
              icon: 'obj_retail',
              iconWidth: 20.094,
              iconHeight: 18,
            ),
            _OptionSpec(
              id: 'warehouse',
              value: 16,
              icon: 'obj_warehouse',
              iconWidth: 20,
              iconHeight: 20,
            ),
            _OptionSpec(
              id: 'office',
              value: 12,
              icon: 'obj_office',
              iconWidth: 20,
              iconHeight: 18,
            ),
          ],
        ),
        _StepSpec(
          id: 'area',
          options: [
            _OptionSpec(id: 'small', value: 0.75),
            _OptionSpec(id: 'medium', value: 1),
            _OptionSpec(id: 'large', value: 1.6),
            _OptionSpec(id: 'xlarge', value: 2.4),
          ],
        ),
        _StepSpec(
          id: 'quality',
          options: [
            _OptionSpec(id: '2mp', value: 115000),
            _OptionSpec(id: '4mp', value: 130000),
            _OptionSpec(id: '8mp', value: 210000),
            _OptionSpec(id: 'mixed', value: 160000),
          ],
        ),
        _StepSpec(
          id: 'retention',
          options: [
            _OptionSpec(id: '7d', value: 6000),
            _OptionSpec(id: '14d', value: 11000),
            _OptionSpec(id: '30d', value: 20000),
            _OptionSpec(id: '90d', value: 55000),
          ],
        ),
      ],
    ),
    _QuizSpec(
      id: 'access',
      image: 'assets/images/quiz_turnstiles.jpg',
      icon: 'quiz_turnstile',
      iconWidth: 16,
      iconHeight: 20,
      steps: [
        _StepSpec(
          id: 'system_type',
          options: [
            _OptionSpec(
              id: 'tripod',
              value: 2,
              icon: 'obj_office',
              iconWidth: 20,
              iconHeight: 18,
            ),
            _OptionSpec(
              id: 'optical',
              value: 3,
              icon: 'obj_retail',
              iconWidth: 20.094,
              iconHeight: 18,
            ),
            _OptionSpec(
              id: 'barrier',
              value: 2,
              icon: 'obj_warehouse',
              iconWidth: 20,
              iconHeight: 20,
            ),
            _OptionSpec(
              id: 'combined',
              value: 4,
              icon: 'obj_apartment',
              iconWidth: 16,
              iconHeight: 18,
            ),
          ],
        ),
        _StepSpec(
          id: 'throughput',
          options: [
            _OptionSpec(id: 'upto200', value: 1),
            _OptionSpec(id: 'upto1000', value: 1.5),
            _OptionSpec(id: 'upto5000', value: 2.5),
            _OptionSpec(id: 'over5000', value: 4),
          ],
        ),
        _StepSpec(
          id: 'identification',
          options: [
            _OptionSpec(id: 'card', value: 450000),
            _OptionSpec(id: 'mobile', value: 575000),
            _OptionSpec(id: 'biometry', value: 825000),
            _OptionSpec(id: 'plates', value: 700000),
          ],
        ),
        _StepSpec(
          id: 'integration',
          options: [
            _OptionSpec(id: 'standalone', value: 0),
            _OptionSpec(id: 'time', value: 60000),
            _OptionSpec(id: 'erp', value: 130000),
            _OptionSpec(id: 'full', value: 240000),
          ],
        ),
      ],
    ),
  ];
}

/// Нелокализуемая часть квиза.
class _QuizSpec {
  const _QuizSpec({
    required this.id,
    required this.image,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    required this.steps,
  });

  final String id;
  final String image;
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final List<_StepSpec> steps;
}

class _StepSpec {
  const _StepSpec({required this.id, required this.options});

  final String id;
  final List<_OptionSpec> options;
}

class _OptionSpec {
  const _OptionSpec({
    required this.id,
    required this.value,
    this.icon,
    this.iconWidth = 20,
    this.iconHeight = 20,
  });

  final String id;
  final double value;
  final String? icon;
  final double iconWidth;
  final double iconHeight;
}
