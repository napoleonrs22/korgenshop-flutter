import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/app.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/l10n/locale_providers.dart';
import 'package:test_app/core/navigation/app_router.dart';

import 'support/fake_api.dart';

import 'package:test_app/core/network/network_providers.dart';

/// Hero-слайдер крутит Timer.periodic, поэтому pumpAndSettle здесь зависает —
/// прокручиваем кадры вручную.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> pumpApp(WidgetTester tester) async {
  final overrides = [
    ...await buildAppOverrides(),
    apiClientProvider.overrideWithValue(createFakeApiClient()),
  ];
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const KorgenShopApp()),
  );
  await settle(tester);

  // Приложение стартует с заставки. Ждать её анимацию в тесте незачем —
  // уходим на главную сразу, чтобы проверки не зависели от таймингов.
  appRouter.go(AppRoutes.home);
  await settle(tester);
  await settle(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    configureDependencies();
  });

  testWidgets('нижний бар переключает вкладки, квиз проходится до конца', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    expect(find.text('Каталог оборудования'), findsOneWidget);

    await tester.tap(find.text('Каталог').last);
    await settle(tester);
    expect(find.text('Фильтры'), findsOneWidget);

    await tester.tap(find.text('Квизы').last);
    await settle(tester);
    expect(find.text('Инструменты расчета'), findsOneWidget);

    await tester.tap(find.text('Корзина').last);
    await settle(tester);

    await tester.tap(find.text('Профиль').last);
    await settle(tester);

    await tester.tap(find.text('Квизы').last);
    await settle(tester);

    await tester.tap(
      find.text('Квиз: Расчет стоимости видеонаблюдения'),
      warnIfMissed: false,
    );
    await settle(tester);

    const answers = <String>[
      'Квартира',
      'До 100 м²',
      '2 МП — Full HD',
      '7 дней',
    ];

    for (var i = 0; i < answers.length; i++) {
      expect(find.text('Шаг ${i + 1} из 6'), findsOneWidget);
      await tester.ensureVisible(find.text(answers[i]));
      await settle(tester);
      await tester.tap(find.text(answers[i]));
      await settle(tester);
      await tester.tap(find.text('Следующий шаг'));
      await settle(tester);
    }

    // Пятый шаг — фотографии объекта. Снимать в тесте нечего, но кнопки
    // должны быть на месте, а дальше он пускает без ответа.
    expect(find.text('Шаг 5 из 6'), findsOneWidget);
    expect(find.text('Снять фото'), findsOneWidget);
    await tester.tap(find.text('Следующий шаг'));
    await settle(tester);

    expect(find.text('Шаг 6 из 6'), findsOneWidget);
    expect(find.text('Ваша предварительная смета'), findsOneWidget);
  });

  testWidgets('переключение на казахский меняет интерфейс и контент', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    await tester.tap(find.text('Профиль').last);
    await settle(tester);
    expect(
      find.text('Заказы, профиль и история — после входа в аккаунт.'),
      findsOneWidget,
    );

    // Переключатель компактный: коды языков вместо полных названий.
    await tester.tap(find.text('KZ'));
    await settle(tester);
    await settle(tester);

    // Интерфейс переехал на казахский…
    expect(
      find.text('Тапсырыстар, профиль және тарих — аккаунтқа кіргеннен кейін.'),
      findsOneWidget,
    );
    expect(find.text('KZ'), findsOneWidget);

    // …включая заголовки на главной. Контент каталога приходит из API и
    // одноязычен, поэтому проверяем только интерфейс.
    await tester.tap(find.text('Басты').last);
    await settle(tester);
    await settle(tester);
    expect(find.text('Жабдық каталогы'), findsOneWidget);

    // Выбор сохранён.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleController.storageKey), 'kk');
  });
}
