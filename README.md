# Korgen Shop

Flutter-приложение магазина систем видеонаблюдения. Исходный код приложения находится в `lib/`, точка входа — `lib/main.dart`.

## Что понадобится

- Flutter SDK с Dart 3.13.1 или новее. Проект создан на Flutter 3.47.1 (stable).
- Для Android: Android SDK, эмулятор или подключённое устройство. Сборка использует Java 17.
- Для iOS: macOS, Xcode и iOS Simulator или подключённый iPhone.

Проверьте окружение:

```bash
flutter doctor
flutter devices
```

## Запуск

Из корня проекта установите зависимости и запустите приложение на выбранном устройстве:

```bash
flutter pub get
flutter run -d DEVICE_ID
```

Замените `DEVICE_ID` на идентификатор из вывода `flutter devices`. Если подключено только одно устройство, достаточно `flutter run`.

По умолчанию приложение обращается к `https://korgenshop.kz/api/v1`. Для другого API передайте `API_BASE_URL` при запуске:

```bash
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=https://example.com/api/v1
```

Адрес должен включать `/api/v1`. Настройка читается во время сборки из `lib/core/config/app_config.dart`, поэтому после смены адреса запустите приложение заново с новым флагом.

### Локальный API на Android

Если API запущен на компьютере на порту `8000`, для Android-эмулятора используйте адрес хост-машины `10.0.2.2`:

```bash
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Для Android-устройства, подключённого по USB, сначала перенаправьте порт:

```bash
adb reverse tcp:8000 tcp:8000
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Для устройства в той же сети можно указать LAN-адрес компьютера, например `http://192.168.0.10:8000/api/v1`; API должен слушать сетевой интерфейс и быть доступен с телефона. HTTP-трафик разрешён в Android debug-сборке.

### Особенность Android-сборки

Текущая Gradle-конфигурация требует `android/key.properties` и файл keystore **даже при debug-запуске**. Эти локальные файлы исключены из Git. Если их нет, получите данные для подписи у сопровождающего проекта и укажите в `android/key.properties` значения `keyAlias`, `keyPassword`, `storeFile` и `storePassword`. `storeFile` должен указывать на существующий keystore. Не добавляйте эти файлы в репозиторий.

## Проверка

```bash
flutter analyze
flutter test
```
