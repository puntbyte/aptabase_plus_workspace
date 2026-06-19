# Aptabase Plus Example

This project demonstrates how to use `aptabase_plus` in both **pure Dart** (CLI) and **Flutter** environments from a single codebase.

## 🎯 Flutter Example

The Flutter example automatically attaches to app lifecycle events and collects device info (`osVersion`, `appVersion`, etc.).

Run the app on any supported platform (iOS, Android, macOS, Windows, Linux, Web):

```sh
flutter run --dart-define=APTABASE_APP_KEY=A-DEV-0000000000
```

## 💻 Pure Dart Example

The pure Dart example runs entirely in the terminal without importing `flutter/widgets.dart` or any platform-specific UI code.

Run the CLI script:

```sh
dart run --define=APTABASE_APP_KEY=A-DEV-0000000000 bin/main.dart
```
