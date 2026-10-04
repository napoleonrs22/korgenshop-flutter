import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/features/splash/presentation/screens/splash_screen.dart';

/// Заставка сама уводит на главную, поэтому в тесте ей нужен роутер —
/// иначе `context.go` не найдёт делегата и упадёт.
GoRouter _router({required List<String> visited}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          visited.add('/home');
          return const Scaffold(body: Text('главная'));
        },
      ),
    ],
  );
}

Future<void> pumpSplash(WidgetTester tester, List<String> visited) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp.router(routerConfig: _router(visited: visited)));
  await tester.pump();
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('знак и подпись проявляются, потом уводит на главную', (
    tester,
  ) async {
    final visited = <String>[];
    await pumpSplash(tester, visited);

    // Середина анимации: знак уже виден, подпись ещё набирает прозрачность.
    await tester.pump(const Duration(milliseconds: 620));
    await expectLater(
      find.byType(SplashScreen),
      matchesGoldenFile('shots/splash_mid.png'),
    );

    // Конец анимации: оба элемента на месте.
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(SplashScreen),
      matchesGoldenFile('shots/splash_end.png'),
    );

    expect(visited, isEmpty, reason: 'до конца анимации никуда не уходим');

    // Ещё кадр — контроллер досчитал, заставка уступает место главной.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(visited, ['/home']);
    expect(find.text('главная'), findsOneWidget);
  });
}
