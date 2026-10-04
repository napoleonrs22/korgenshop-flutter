import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/core/l10n/app_locale.dart';
import 'package:test_app/core/l10n/app_strings.dart';
import 'package:test_app/core/l10n/locale_providers.dart';
import 'package:test_app/core/network/network_providers.dart';
import 'package:test_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:test_app/features/orders/domain/entities/order.dart';
import 'package:test_app/features/orders/presentation/providers/orders_providers.dart';
import 'package:test_app/features/orders/presentation/screens/orders_screen.dart';

import 'support/fake_api.dart';

/// Экран истории заказов рендерится только для вошедшего пользователя,
/// поэтому состояние авторизации подменяем напрямую.
Future<void> pumpOrders(
  WidgetTester tester, {
  required List<Order> orders,
  bool signedIn = true,
}) async {
  SharedPreferences.setMockInitialValues({});

  final strings = await AppStrings.load(AppLocale.ru);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...await buildAppOverrides(),
        apiClientProvider.overrideWithValue(createFakeApiClient()),
        isSignedInProvider.overrideWithValue(signedIn),
        ordersProvider.overrideWith((ref) => Future.value(orders)),
      ],
      child: MaterialApp(
        locale: strings.locale.locale,
        home: const OrdersScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('заказ показывает позиции, количество и сумму', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpOrders(
      tester,
      orders: [
        Order(
          id: 1452,
          statusTitle: 'Новый',
          total: 1147500,
          totalCount: 3,
          createdAt: DateTime.parse('2026-08-31T10:15:00+05:00'),
          city: 'Шымкент',
          address: 'ул. Абая, 1',
          items: const [
            OrderItem(
              title: 'Apex V-300 Dome',
              quantity: 2,
              price: 429000,
              lineTotal: 858000,
            ),
            OrderItem(
              title: 'Hikvision NVR 8ch',
              quantity: 1,
              price: 289500,
              lineTotal: 289500,
            ),
          ],
        ),
      ],
    );

    expect(find.text('Заказ №1452'), findsOneWidget);
    expect(find.text('Новый'), findsOneWidget);
    expect(find.text('31.08.2026'), findsOneWidget);

    // Обе позиции с количеством и построчной суммой.
    expect(find.text('Apex V-300 Dome'), findsOneWidget);
    expect(find.text('2 × 429 000 ₸'), findsOneWidget);
    expect(find.text('858 000 ₸'), findsOneWidget);
    expect(find.text('Hikvision NVR 8ch'), findsOneWidget);

    expect(find.text('Товаров: 3'), findsOneWidget);
    expect(find.text('1 147 500 ₸'), findsOneWidget);
    expect(find.text('Шымкент, ул. Абая, 1'), findsOneWidget);
  });

  testWidgets('без заказов предлагает открыть каталог', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpOrders(tester, orders: const []);

    expect(find.text('Открыть каталог'), findsOneWidget);
  });

  testWidgets('гостю предлагает войти', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpOrders(tester, orders: const [], signedIn: false);

    expect(
      find.text('Войдите в аккаунт, чтобы увидеть историю заказов.'),
      findsOneWidget,
    );
  });

  test('разбор ответа сервера', () {
    final order = Order.fromJson({
      'id': 7,
      'status': 'new',
      'status_title': 'Новый',
      'summa': 100,
      'total_count': 2,
      'created_at': '2026-08-31T10:15:00+05:00',
      'city': 'Шымкент',
      'address': '',
      'items': [
        {'title': 'Камера', 'quantity': 2, 'price': 50},
      ],
    });

    expect(order.id, 7);
    expect(order.items.single.title, 'Камера');
    // line_total сервер не прислал — считаем сами.
    expect(order.items.single.lineTotal, 100);
    // Пустой адрес в строку места не попадает.
    expect(order.place, 'Шымкент');
  });
}
