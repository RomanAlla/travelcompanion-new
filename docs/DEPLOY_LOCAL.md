# Как развернуть Travel Companion локально (iOS/Android)

Демо/локальный запуск удобнее всего делать так: получить Flutter-сборку из репозитория, подготовить конфиги (Firebase + `.env` для Supabase/Yandex/Gemini) и запустить `flutter run`.

Репозиторий: [RomanAlla/travelcompanion-new](https://github.com/RomanAlla/travelcompanion-new)

## 1) Требования

1. **Flutter** (stable) — версия в проекте: `sdk: ^3.8.1`.
2. **Xcode** + **CocoaPods** (для iOS).
3. **Android SDK** (для Android).
4. На Mac обычно нужен **Ruby** (если CocoaPods установлен через gem).

Проверка окружения:

```bash
flutter --version
flutter doctor -v
```

Если появится предупреждение про Android licenses — выполните:

```bash
flutter doctor --android-licenses
```

## 2) Получить код

```bash
git clone https://github.com/RomanAlla/travelcompanion-new.git
cd travelcompanion-new
```

## 3) Конфигурации (важно)

### 3.1. `.env` для Supabase/Yandex/Gemini

В коде приложение загружает переменные окружения из:

- `assets/.env`

Ключи, которые должны присутствовать:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `YANDEX_GEOCODER_API_KEY`
- `GEMINI_API_KEY`
- `GEMINI_PROXY_URL`

Проверьте, что файл `assets/.env` существует и содержит эти переменные (значения вставьте свои).

> Важно: в публичных репозиториях **не коммитьте** реальные ключи. Для публичной публикации лучше хранить `.env` вне git и подменять его локально.

### 3.2. Firebase (iOS/Android)

Для Firebase в проекте уже подключены конфиги:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

Если этих файлов нет или вы переносите репозиторий между машинами — восстановите их (из консоли Firebase / через `flutterfire`).

## 4) Установить зависимости

```bash
flutter pub get
```

## 5) Запуск

Подключите устройство/эмулятор:

```bash
flutter devices
```

### 5.1. Android

```bash
flutter run
```

или явно указать устройство:

```bash
flutter run -d <device_id>
```

### 5.2. iOS (симулятор или девайс)

1. В некоторых случаях требуется подготовить pods:

```bash
cd ios
pod install
cd ..
```

2. Запуск:

```bash
flutter run -d <device_id>
```

Если iOS запускается, но не компилируется из‑за pods — обычно помогает повторный `pod install` из `ios/`.

## 6) Сборка релиза (пример)

### Android (apk)

```bash
flutter build apk --release
```

### Android (aab)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```


