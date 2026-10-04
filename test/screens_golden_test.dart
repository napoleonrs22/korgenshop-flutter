import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/app.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/l10n/locale_providers.dart';
import 'package:test_app/core/l10n/app_locale.dart';
import 'package:test_app/core/l10n/app_strings.dart';
import 'package:test_app/core/navigation/app_router.dart';
import 'package:test_app/features/quiz/presentation/widgets/option_grid.dart';

import 'support/fake_api.dart';

import 'package:test_app/core/network/network_providers.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    configureDependencies();
  });

  for (final code in ['ru', 'kk', 'en']) {
    testWidgets('снимки всех экранов ($code)', (tester) async {
      SharedPreferences.setMockInitialValues({
        LocaleController.storageKey: code,
      });

      tester.view.physicalSize = const Size(1170, 3200);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final overrides = [
        ...await buildAppOverrides(),
        apiClientProvider.overrideWithValue(createFakeApiClient()),
      ];
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const KorgenShopApp()),
      );
      await settle(tester);

      Future<void> shot(String name) async {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('shots/${code}_$name.png'),
        );
      }

      Future<void> go(String location) async {
        appRouter.go(location);
        await settle(tester);
        await settle(tester);
      }

      // appRouter — глобальный синглтон: после прогона предыдущего языка он
      // остаётся на последнем открытом экране. Возвращаем на главную, иначе
      // первый снимок каждого следующего языка снимает чужой экран.
      await go(AppRoutes.home);
      await shot('01_home');

      await go(AppRoutes.catalog);
      await shot('02_catalog');

      await go(AppRoutes.product('apex-v300-dome'));
      await shot('03_product');

      await go(AppRoutes.quizzes);
      await shot('04_quiz_select');

      await go(AppRoutes.quiz('cctv'));
      await shot('05_quiz_wizard');

      // Проходим вопросы, чтобы снять шаг с фотографиями объекта.
      final strings = await AppStrings.load(AppLocale.fromCode(code));
      for (final _ in strings.keys('content.quizzes.cctv.steps')) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(OptionGrid),
                matching: find.byType(InkWell),
              )
              .first,
          warnIfMissed: false,
        );
        await settle(tester);
        await tester.tap(find.text(strings.t('quiz.next')));
        await settle(tester);
      }
      await shot('05c_quiz_photo');

      // Квиз СКУД: самые длинные подписи вариантов — здесь ломалась вёрстка.
      await go(AppRoutes.quiz('access'));
      await shot('05b_quiz_access');

      await go(AppRoutes.projects);
      await shot('06_projects');

      await go(AppRoutes.support);
      await shot('07_support');

      await go(AppRoutes.profile);
      await shot('08_profile');

      await go(AppRoutes.login);
      await shot('09_login');

      await go(AppRoutes.register);
      await shot('10_register');

      await go(AppRoutes.verifyEmail);
      await shot('11_verify_email');

      await go(AppRoutes.forgotPassword);
      await shot('12_reset_email');

      await go(AppRoutes.orders);
      await shot('13_orders');
    });
  }
}
