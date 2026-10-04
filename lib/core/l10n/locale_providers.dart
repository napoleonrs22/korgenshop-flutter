import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'app_strings.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Текущий словарь. Значение подставляется в [buildAppOverrides] до
/// запуска приложения, поэтому строки доступны синхронно из любого виджета.
final stringsProvider = StateNotifierProvider<LocaleController, AppStrings>(
  (ref) => throw StateError(
    'stringsProvider должен быть переопределён через buildAppOverrides()',
  ),
);

class LocaleController extends StateNotifier<AppStrings> {
  LocaleController(super.state, this._prefs);

  static const storageKey = 'app_locale';

  final SharedPreferences _prefs;

  AppLocale get locale => state.locale;

  Future<void> setLocale(AppLocale locale) async {
    if (locale == state.locale) return;
    state = await AppStrings.load(locale);
    await _prefs.setString(storageKey, locale.code);
  }
}

/// Стартовый бутстрап: язык, словарь и общие зависимости.
/// Вызывается из `main()` и из тестов, чтобы обе точки входа собирались
/// одинаково.
Future<List<Override>> buildAppOverrides() async {
  final prefs = await SharedPreferences.getInstance();
  final locale = AppLocale.fromCode(
    prefs.getString(LocaleController.storageKey),
  );
  final strings = await AppStrings.load(locale);

  return [
    stringsProvider.overrideWith((ref) => LocaleController(strings, prefs)),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ];
}

/// Короткий доступ к словарю: `ref.strings.t('nav.home')`.
extension StringsRef on WidgetRef {
  AppStrings get strings => watch(stringsProvider);
}
