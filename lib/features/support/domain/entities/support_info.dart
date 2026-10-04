/// Контакты компании.
class ContactInfo {
  const ContactInfo({
    required this.officeTitle,
    required this.company,
    required this.addressLines,
    required this.phoneTitle,
    required this.phone,
    required this.workingHours,
  });

  final String officeTitle;

  /// Юридическое лицо, на которое оформляются договоры и счета.
  final String company;

  final List<String> addressLines;
  final String phoneTitle;
  final String phone;
  final String workingHours;
}

/// Пункт FAQ. Раскрывается аккордеоном.
class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
