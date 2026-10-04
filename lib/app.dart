import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_locale.dart';
import 'core/l10n/locale_providers.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

class KorgenShopApp extends ConsumerWidget {
  const KorgenShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    // Поднимаем сессию до первого кадра: контроллер восстановит токен
    // из хранилища и подставит его в HTTP-клиент.
    ref.watch(authControllerProvider);

    return MaterialApp.router(
      title: 'Korgen Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: strings.locale.locale,
      supportedLocales: AppLocale.values.map((value) => value.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
