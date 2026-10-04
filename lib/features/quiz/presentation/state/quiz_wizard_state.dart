import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_estimate.dart';
import '../../domain/services/quiz_estimator.dart';

/// Состояние визарда: на каком шаге стоим и что уже ответили.
class QuizWizardState {
  const QuizWizardState({
    required this.quiz,
    this.currentStep = 0,
    this.answers = const {},
    this.photos = const [],
  });

  final Quiz quiz;

  /// Индекс шага. Равен `quiz.steps.length` на экране сметы.
  final int currentStep;

  /// Ответы по id шага.
  final Map<String, QuizOption> answers;

  /// Пути к снимкам объекта. Уходят в заявку вместе с ответами.
  final List<String> photos;

  /// Шаг с фотографиями идёт сразу за вопросами.
  bool get isPhotoStep => currentStep == quiz.steps.length;

  bool get isResultStep => currentStep > quiz.steps.length;

  bool get isFirstStep => currentStep == 0;

  QuizStep? get step =>
      currentStep < quiz.steps.length ? quiz.steps[currentStep] : null;

  /// Ответ, выбранный на текущем шаге.
  QuizOption? get currentAnswer {
    final current = step;
    return current == null ? null : answers[current.id];
  }

  /// Пока шаг не отвечен, «Next Step» заблокирован. Фотографии
  /// необязательны, поэтому их шаг пропускается свободно.
  bool get canGoNext => isResultStep || isPhotoStep || currentAnswer != null;

  /// Заполненность прогресс-бара: на первом шаге из пяти это 20%.
  double get progress => (currentStep + 1) / quiz.totalSteps;

  QuizWizardState copyWith({
    int? currentStep,
    Map<String, QuizOption>? answers,
    List<String>? photos,
  }) {
    return QuizWizardState(
      quiz: quiz,
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      photos: photos ?? this.photos,
    );
  }
}

class QuizWizardNotifier extends StateNotifier<QuizWizardState> {
  QuizWizardNotifier(Quiz quiz, this._estimator)
    : super(QuizWizardState(quiz: quiz));

  final QuizEstimator _estimator;

  /// Выбрать вариант на текущем шаге.
  void select(QuizOption option) {
    final step = state.step;
    if (step == null) return;
    state = state.copyWith(answers: {...state.answers, step.id: option});
  }

  /// Не больше десяти снимков — столько принимает бэкенд.
  void addPhotos(Iterable<String> paths) {
    final merged = [...state.photos];

    for (final path in paths) {
      if (merged.length >= 10 || merged.contains(path)) continue;
      merged.add(path);
    }

    state = state.copyWith(photos: merged);
  }

  void removePhoto(String path) => state = state.copyWith(
    photos: [...state.photos]..remove(path),
  );

  void next() {
    if (!state.canGoNext || state.isResultStep) return;
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void back() {
    if (state.isFirstStep) return;
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void reset() => state = QuizWizardState(quiz: state.quiz);

  QuizEstimate get estimate => _estimator.estimate(state.quiz, state.answers);
}
