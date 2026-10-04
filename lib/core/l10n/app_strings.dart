import 'dart:convert';

import 'package:flutter/services.dart';

import 'app_locale.dart';

/// Словарь одного языка, загруженный из `assets/l10n/<code>.json`.
///
/// Ключи адресуются точкой: `t('catalog.sort.recommended')`.
class AppStrings {
  const AppStrings(this.locale, this._data);

  final AppLocale locale;
  final Map<String, dynamic> _data;

  static final _cache = <AppLocale, AppStrings>{};

  static Future<AppStrings> load(AppLocale locale) async {
    final cached = _cache[locale];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/l10n/${locale.code}.json');
    final strings = AppStrings(
      locale,
      json.decode(raw) as Map<String, dynamic>,
    );
    return _cache[locale] = strings;
  }

  Object? _node(String path) {
    Object? node = _data;
    for (final part in path.split('.')) {
      if (node is! Map<String, dynamic>) return null;
      node = node[part];
    }
    return node;
  }

  /// Строка по ключу. `params` подставляются в плейсхолдеры вида `{count}`.
  String t(String path, {Map<String, Object?> params = const {}}) {
    final value = _node(path);
    if (value is! String) {
      assert(false, 'Нет строки "$path" в ${locale.code}.json');
      return path;
    }
    if (params.isEmpty) return value;
    return params.entries.fold(
      value,
      (result, entry) => result.replaceAll('{${entry.key}}', '${entry.value}'),
    );
  }

  List<String> list(String path) =>
      (_node(path) as List<dynamic>?)?.cast<String>() ?? const [];

  /// Значения узла как строки. Порядок сохраняется — важно для характеристик.
  Map<String, String> map(String path) {
    final value = _node(path);
    if (value is! Map<String, dynamic>) return const {};
    return {for (final entry in value.entries) entry.key: '${entry.value}'};
  }

  /// Ключи узла в порядке файла — по ним собираются списки сущностей.
  List<String> keys(String path) =>
      (_node(path) as Map<String, dynamic>?)?.keys.toList() ?? const [];

  bool has(String path) => _node(path) != null;
}
