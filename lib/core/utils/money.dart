/// Форматирование цен.
///
/// Бэкенд хранит цену целым числом тенге, без копеек.
class Money {
  const Money._();

  static String format(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return '${amount < 0 ? '-' : ''}$buffer ₸';
  }
}
