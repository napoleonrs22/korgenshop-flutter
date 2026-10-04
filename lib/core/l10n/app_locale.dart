import 'package:flutter/widgets.dart';

/// Языки приложения. Каждому соответствует файл `assets/l10n/<code>.json`.
enum AppLocale {
  ru('ru'),
  kk('kk'),
  en('en');

  const AppLocale(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLocale fromCode(String? code) => AppLocale.values.firstWhere(
    (value) => value.code == code,
    orElse: () => AppLocale.ru,
  );
}
