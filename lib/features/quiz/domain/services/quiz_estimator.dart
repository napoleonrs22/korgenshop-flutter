import '../entities/quiz.dart';
import '../entities/quiz_estimate.dart';

/// Считает предварительную смету по ответам квиза.
///
/// Формулы условные — это заглушка вместо расчёта на бэкенде, но она
/// детерминирована и реагирует на каждый ответ, чтобы результат визарда
/// выглядел осмысленным.
class QuizEstimator {
  const QuizEstimator();

  QuizEstimate estimate(Quiz quiz, Map<String, QuizOption> answers) {
    final steps = quiz.steps;

    // Первый шаг задаёт базовое количество единиц, второй — масштаб,
    // третий — цену за единицу, четвёртый — надбавку за хранение/интеграцию.
    final base = _valueOf(answers, steps, 0, fallback: 8);
    final scale = _valueOf(answers, steps, 1, fallback: 1);
    final unitPrice = _valueOf(answers, steps, 2, fallback: 130000);
    final extraPerUnit = _valueOf(answers, steps, 3, fallback: 20000);

    final units = (base * scale).round().clamp(1, 500);
    final hardware = units * unitPrice;
    final extras = units * extraPerUnit;
    final recorder = units <= 8 ? 289500.0 : 512000.0;
    final equipment = hardware + extras + recorder;
    final installation = units * 25000.0;

    return QuizEstimate(
      unitCount: units,
      unitLabel: quiz.unitLabel,
      equipmentCost: equipment.round(),
      installationCost: installation.round(),
      breakdown: [
        for (var i = 0; i < steps.length; i++)
          if (answers[steps[i].id] != null)
            EstimateLine(steps[i].question, answers[steps[i].id]!.label),
      ],
    );
  }

  double _valueOf(
    Map<String, QuizOption> answers,
    List<QuizStep> steps,
    int index, {
    required double fallback,
  }) {
    if (index >= steps.length) return fallback;
    return answers[steps[index].id]?.value ?? fallback;
  }
}
