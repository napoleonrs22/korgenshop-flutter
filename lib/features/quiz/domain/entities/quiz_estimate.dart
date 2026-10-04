/// Строка расшифровки в смете.
class EstimateLine {
  const EstimateLine(this.label, this.value);

  final String label;
  final String value;
}

/// Результат квиза — предварительная смета.
class QuizEstimate {
  const QuizEstimate({
    required this.unitCount,
    required this.unitLabel,
    required this.equipmentCost,
    required this.installationCost,
    required this.breakdown,
  });

  final int unitCount;
  final String unitLabel;

  /// Целые тенге, как и цены товаров.
  final int equipmentCost;
  final int installationCost;
  final List<EstimateLine> breakdown;

  int get total => equipmentCost + installationCost;
}
