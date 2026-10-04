import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/l10n/app_locale.dart';
import 'package:test_app/core/l10n/app_strings.dart';
import 'package:test_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:test_app/features/catalog/data/datasources/product_api.dart';

import 'support/fake_api.dart';

import 'package:test_app/features/quiz/data/datasources/quiz_mock.dart';
import 'package:test_app/features/quiz/domain/services/quiz_estimator.dart';
import 'package:test_app/features/quiz/presentation/state/quiz_wizard_state.dart';

void main() {
  late AppStrings strings;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    strings = await AppStrings.load(AppLocale.ru);
  });

  group('QuizWizardNotifier', () {
    late QuizWizardNotifier notifier;

    setUp(() async {
      final quiz = await QuizMockDataSource(strings).fetchQuizById('cctv');
      notifier = QuizWizardNotifier(quiz!, const QuizEstimator());
    });

    test('стартует на первом шаге и не пускает дальше без ответа', () {
      expect(notifier.state.currentStep, 0);
      // Четыре вопроса, шаг с фотографиями и экран сметы.
      expect(notifier.state.quiz.totalSteps, 6);
      expect(notifier.state.canGoNext, isFalse);

      notifier.next();
      expect(notifier.state.currentStep, 0);
    });

    test('проходит все шаги до сметы', () {
      for (var i = 0; i < notifier.state.quiz.steps.length; i++) {
        expect(notifier.state.isResultStep, isFalse);
        notifier.select(notifier.state.step!.options.first);
        notifier.next();
      }

      // Шаг с фотографиями: необязательный, поэтому дальше пускает сразу.
      expect(notifier.state.isPhotoStep, isTrue);
      expect(notifier.state.isResultStep, isFalse);
      expect(notifier.state.canGoNext, isTrue);
      notifier.next();

      expect(notifier.state.isResultStep, isTrue);
      expect(notifier.state.currentStep, 5);
      expect(notifier.state.progress, 1.0);
      expect(notifier.estimate.total, greaterThan(0));
    });

    test('снимки копятся, не дублируются и ограничены десятью', () {
      notifier.addPhotos(['/tmp/a.jpg', '/tmp/b.jpg', '/tmp/a.jpg']);
      expect(notifier.state.photos, ['/tmp/a.jpg', '/tmp/b.jpg']);

      notifier.removePhoto('/tmp/a.jpg');
      expect(notifier.state.photos, ['/tmp/b.jpg']);

      notifier.addPhotos([for (var i = 0; i < 20; i++) '/tmp/$i.jpg']);
      expect(notifier.state.photos.length, 10);
    });

    test('reset возвращает визард в начало', () {
      notifier.select(notifier.state.step!.options.first);
      notifier.next();
      notifier.reset();

      expect(notifier.state.currentStep, 0);
      expect(notifier.state.answers, isEmpty);
    });
  });

  test('корзина складывает количество по позициям', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(cartCountProvider), 0);

    final api = ProductApiDataSource(createFakeApiClient());
    final products = [
      ...(await api.fetchProducts()).items,
      ...(await api.fetchProducts(page: 2)).items,
    ];
    final cart = container.read(cartProvider.notifier)
      ..add(products.first)
      ..add(products.first)
      ..add(products[1]);

    expect(container.read(cartCountProvider), 3);
    expect(container.read(cartProvider).length, 2);

    cart.remove(products.first.id);
    expect(container.read(cartCountProvider), 1);
  });
}
