import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/app.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/l10n/app_locale.dart';
import 'package:test_app/core/l10n/app_strings.dart';
import 'package:test_app/core/l10n/locale_providers.dart';
import 'package:test_app/core/navigation/app_router.dart';
import 'package:test_app/features/quiz/presentation/widgets/option_grid.dart';

import 'support/fake_api.dart';

import 'package:test_app/core/network/network_providers.dart';

/// Обход всех экранов на реальном размере телефона.
///
/// Смысл теста — поймать переполнения вёрстки: подписи на русском и казахском
/// длиннее английских из макета и легко ломают контейнеры фиксированной высоты.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    configureDependencies();
  });

  for (final locale in AppLocale.values) {
    testWidgets('вёрстка без переполнений (${locale.code})', (tester) async {
      SharedPreferences.setMockInitialValues({
        LocaleController.storageKey: locale.code,
      });

      // Размер обычного телефона, а не бесконечный холст: только так
      // переполнения проявляются так же, как на устройстве.
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final strings = await AppStrings.load(locale);
      final overrides = [
        ...await buildAppOverrides(),
        apiClientProvider.overrideWithValue(createFakeApiClient()),
      ];
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const KorgenShopApp()),
      );
      await settle(tester);

      Future<void> go(String location) async {
        appRouter.go(location);
        await settle(tester);
        await settle(tester);
      }

      // Вкладки и вложенные экраны.
      for (final route in [
        AppRoutes.splash,
        AppRoutes.home,
        AppRoutes.catalog,
        AppRoutes.quizzes,
        AppRoutes.cart,
        AppRoutes.profile,
        AppRoutes.projects,
        AppRoutes.support,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.verifyEmail,
        AppRoutes.forgotPassword,
        AppRoutes.orders,
      ]) {
        await go(route);
      }

      // Восстановление пароля — три шага в одном экране, поэтому код
      // и новый пароль иначе в обход не попадут.
      await go(AppRoutes.forgotPassword);
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.tap(find.text(strings.t('auth.reset.sendCode')));
      await settle(tester);

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text(strings.t('auth.reset.continueLabel')));
      await settle(tester);

      expect(find.text(strings.t('auth.reset.save')), findsOneWidget);

      // Каждый товар каталога: названия и бейджи разной длины.
      for (final id in strings.keys('content.products')) {
        await go(AppRoutes.product(id));
      }

      // Оба квиза целиком: именно здесь подписи вариантов переносятся.
      for (final quizId in strings.keys('content.quizzes')) {
        await go(AppRoutes.quiz(quizId));

        final steps = strings.keys('content.quizzes.$quizId.steps');
        for (var i = 0; i < steps.length; i++) {
          final option = find
              .descendant(
                of: find.byType(OptionGrid),
                matching: find.byType(InkWell),
              )
              .first;
          await tester.tap(option, warnIfMissed: false);
          await settle(tester);

          await tester.tap(find.text(strings.t('quiz.next')));
          await settle(tester);
        }

        // Шаг с фотографиями объекта: снимки необязательны, поэтому
        // проходим его насквозь — проверяем только вёрстку.
        expect(find.text(strings.t('quiz.photo.camera')), findsOneWidget);
        await tester.tap(find.text(strings.t('quiz.next')));
        await settle(tester);

        // Экран сметы.
        expect(find.text(strings.t('quiz.estimateTitle')), findsOneWidget);
      }
    });
  }
}
