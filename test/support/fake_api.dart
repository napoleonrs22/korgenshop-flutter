import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test_app/core/network/api_client.dart';

/// Подставной транспорт для тестов: отвечает заранее заготовленным JSON
/// вместо похода в сеть.
class FakeApiAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    final page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
    final body = path == '/products'
        ? _productsPage(page)
        : _routes[_match(path)] ?? {'data': <dynamic>[]};

    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  /// Две страницы по одному товару — этого хватает, чтобы проверить
  /// подгрузку и признак «есть ещё».
  Map<String, dynamic> _productsPage(int page) {
    final all = (_routes['/products']!['data'] as List<dynamic>);
    final index = (page - 1).clamp(0, all.length - 1);

    return {
      'data': [all[index]],
      'meta': {
        'current_page': page,
        'last_page': all.length,
        'per_page': 1,
        'total': all.length,
      },
    };
  }

  String _match(String path) {
    if (path.startsWith('/products/')) return '/products/{slug}';
    if (path.startsWith('/categories/')) return '/categories/{slug}';
    if (path.startsWith('/projects/')) return '/projects/{slug}';
    return path;
  }

  @override
  void close({bool force = false}) {}

  static final _routes = <String, Map<String, dynamic>>{
    '/orders': {
      'data': [
        {
          'id': 1452,
          'status': 'new',
          'status_title': 'Новый',
          'city': 'Шымкент',
          'address': 'ул. Абая, 1',
          'payment_method': 'kaspi_remote',
          'total_count': 3,
          'summa': 1147500,
          'currency': 'KZT',
          'created_at': '2026-08-31T10:15:00+05:00',
          'items': [
            {
              'product_id': 134,
              'title': 'Apex V-300 Dome',
              'image': 'https://example.test/apex.jpg',
              'quantity': 2,
              'price': 429000,
              'line_total': 858000,
            },
            {
              'product_id': 133,
              'title': 'Hikvision NVR 8ch',
              'image': 'https://example.test/nvr.jpg',
              'quantity': 1,
              'price': 289500,
              'line_total': 289500,
            },
          ],
        },
      ],
    },
    '/auth/password/forgot': {
      'message': 'Если аккаунт существует, код отправлен на почту',
      'retry_after': 60,
    },
    '/auth/password/code': {'message': 'Код подтверждён'},
    '/payment-methods': {
      'data': [
        {'value': 'bank_card', 'title': 'Банковская карта', 'kaspi': null},
        {
          'value': 'kaspi_remote',
          'title': 'Kaspi',
          'kaspi': {
            'qr': 'https://example.test/kaspi-qr.png',
            'url': null,
            'hint': 'Отсканируйте QR в приложении Kaspi.',
          },
        },
      ],
    },
    '/categories': {
      'data': [
        {
          'id': 2,
          'slug': 'kamery',
          'title': 'Камеры',
          'image': 'https://example.test/kamery.png',
          'products_count': 2,
        },
        {
          'id': 1,
          'slug': 'turnikety',
          'title': 'Турникеты',
          'image': 'https://example.test/turnikety.png',
          'products_count': 1,
        },
      ],
    },
    '/sliders': {
      'data': [
        {
          'id': 1,
          'type': 'сервис',
          'content': 'Расчет видеонаблюдения за 10 минут',
          'image': 'https://example.test/hero.jpg',
          'order': 1,
        },
      ],
    },
    '/projects': {
      'data': [
        {
          'id': 6,
          'slug': 'shlagbaum',
          'title': 'Shlangbaum',
          'badge': 'СКУД',
          // Длинная подпись: на такой карточка в карусели переполнялась.
          'subtitle': 'Распознавание номеров и автоматический шлагбаум',
          'description': 'Периметральная охрана предприятия.',
          'cover_image': 'https://example.test/project.jpg',
        },
      ],
    },
    '/products': {
      'data': [
        {
          'id': 134,
          'slug': 'apex-v300-dome',
          'title': 'Apex V-300 Dome',
          'price': 429000,
          'currency': 'KZT',
          'category_id': 2,
          'image': 'https://example.test/apex.jpg',
          'is_active': true,
        },
        {
          'id': 133,
          'slug': 'hik-nvr-8',
          'title': 'Hikvision NVR 8ch',
          'price': 289500,
          'currency': 'KZT',
          'category_id': 3,
          'image': 'https://example.test/nvr.jpg',
          'is_active': true,
        },
      ],
      'meta': {'current_page': 1, 'last_page': 1, 'per_page': 20, 'total': 2},
    },
    '/products/{slug}': {
      'data': {
        'id': 134,
        'slug': 'apex-v300-dome',
        'title': 'Apex V-300 Dome',
        'description': 'Купольная камера 4K. Работает при низкой освещённости.',
        'price': 429000,
        'currency': 'KZT',
        'category_id': 2,
        'category': {'id': 2, 'slug': 'kamery', 'title': 'Камеры'},
        'images': ['https://example.test/apex.jpg'],
        'details': {'Разрешение': '8 МП', 'Питание': 'PoE'},
        'is_active': true,
        'reviews': [
          {
            'id': 12,
            'name': 'Арман',
            'rating': 5,
            'advantages': 'Ночью видно номера',
            'disadvantages': null,
            'comment': 'Поставили на въезд, работает вторую зиму без нареканий.',
            'created_at': '2026-08-20T09:30:00+05:00',
          },
          {
            'id': 9,
            'name': 'Сергей',
            'rating': 4,
            'advantages': null,
            'disadvantages': 'Кронштейн в комплекте хлипкий',
            'comment': 'Картинка хорошая, но крепление пришлось менять.',
            'created_at': '2026-08-02T14:10:00+05:00',
          },
        ],
      },
    },
  };
}

/// Клиент поверх подставного транспорта.
ApiClient createFakeApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api/v1',
      validateStatus: (status) => status != null && status < 500,
    ),
  )..httpClientAdapter = FakeApiAdapter();

  return ApiClient(dio: dio);
}
