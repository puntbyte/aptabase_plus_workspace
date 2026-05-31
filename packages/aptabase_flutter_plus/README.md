# aptabase_flutter_plus

`aptabase_flutter_plus` is the Flutter integration layer for `aptabase_plus`.

It keeps the familiar `Aptabase.init(...)` style while delegating core analytics behaviour to the pure Dart package. This package focuses only on Flutter-specific responsibilities: lifecycle handling and Flutter system metadata.

## What this package provides

- `Aptabase` compatibility facade for Flutter apps.
- `AptabaseFlutter` explicit Flutter facade.
- `FlutterAptabaseLifecycle` for app lifecycle flush/cleanup behaviour.
- `FlutterAptabaseSystemInfoProvider` for app/device/system metadata.

## What this package does not provide

This package intentionally does not bundle a persistent storage backend. Storage is injected through the core `AptabaseStorage` interface.

This keeps Flutter apps free to choose between:

- `aptabase_storage_shared_preferences_plus` for a simple default setup;
- `aptabase_storage_hive_ce_plus` for a stronger local queue backend;
- a custom adapter for secure storage, files, databases, or app-specific infrastructure.

If no storage is provided, the core client falls back to in-memory storage. That is acceptable for tests and short-lived examples, but persistent apps should pass a real storage adapter.

## Installation

```yaml
dependencies:
  aptabase_flutter_plus:
    path: ../aptabase_flutter_plus
  aptabase_storage_shared_preferences_plus:
    path: ../aptabase_storage_shared_preferences_plus
```

When published, replace path dependencies with published version constraints.

## Quick start with shared preferences storage

```dart
import 'package:aptabase_flutter_plus/aptabase_flutter_plus.dart';
import 'package:aptabase_storage_shared_preferences_plus/aptabase_storage_shared_preferences_plus.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Aptabase.init(
    'A-US-0000000000',
    storage: SharedPreferencesAptabaseStorage(),
  );

  runApp(const MyApp());
}
```

Track events from anywhere after initialisation:

```dart
await Aptabase.instance.trackEvent(
  'button_tapped',
  props: {'button': 'checkout'},
);
```

## Quick start with Hive CE storage

```dart
import 'package:aptabase_flutter_plus/aptabase_flutter_plus.dart';
import 'package:aptabase_storage_hive_ce_plus/aptabase_storage_hive_ce_plus.dart';

final storage = await HiveCeAptabaseStorage.open(
  boxName: 'aptabase_events',
);

await Aptabase.init(
  'A-US-0000000000',
  storage: storage,
);
```

## Lifecycle handling

By default, `Aptabase.init(...)` attaches `FlutterAptabaseLifecycle`. This allows the SDK to react to app lifecycle changes and flush queued events when appropriate.

Disable lifecycle attachment only when you want manual control:

```dart
await Aptabase.init(
  'A-US-0000000000',
  storage: SharedPreferencesAptabaseStorage(),
  attachLifecycle: false,
);
```

Then flush manually when needed:

```dart
await Aptabase.instance.flush();
```

## System metadata

`FlutterAptabaseSystemInfoProvider` collects Flutter app and device metadata using Flutter-compatible plugins. You can override it when you want custom app versioning, privacy filtering, or deterministic test metadata.

```dart
await Aptabase.init(
  'A-US-0000000000',
  storage: SharedPreferencesAptabaseStorage(),
  systemInfoProvider: const StaticAptabaseSystemInfoProvider(
    AptabaseSystemInfo(
      osName: 'flutter-test',
      osVersion: '0',
      locale: 'en',
      appVersion: '1.0.0',
      appBuildNumber: '1',
      isDebug: true,
    ),
  ),
);
```

## Migration from a bundled-storage SDK

Older single-package SDKs often bundled storage directly into the Flutter package. In this split design, add an explicit storage dependency and pass it to `Aptabase.init`.

Before:

```dart
await Aptabase.init('A-US-0000000000');
```

After:

```dart
await Aptabase.init(
  'A-US-0000000000',
  storage: SharedPreferencesAptabaseStorage(),
);
```

## Testing

Run Flutter tests from the workspace root:

```bash
flutter test packages/aptabase_flutter_plus
```

Storage adapter tests live in their own packages because storage is no longer part of this Flutter integration package.
