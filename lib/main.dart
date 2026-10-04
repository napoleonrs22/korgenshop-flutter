import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/l10n/locale_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Шрифт лежит в google_fonts/ и грузится из бандла, а не из сети.
  GoogleFonts.config.allowRuntimeFetching = false;

  configureDependencies();

  // Словарь выбранного языка загружается до первого кадра, чтобы экраны
  // читали строки синхронно и не мигали пустыми плейсхолдерами.
  final overrides = await buildAppOverrides();

  runApp(ProviderScope(overrides: overrides, child: const KorgenShopApp()));
}
