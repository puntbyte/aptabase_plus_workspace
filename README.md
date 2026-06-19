# Aptabase Plus Workspace

Aptabase Plus is an experimental community split of the original Flutter SDK into a small pure Dart core, a Flutter integration package, and optional storage adapters.

The goal of this workspace is to keep analytics tracking portable across Dart runtimes while still giving Flutter apps a convenient integration layer. The package names intentionally use the `plus` suffix so the official Aptabase team can still adopt names such as `aptabase`, `aptabase_dart`, or `aptabase_core` in the future if they choose to publish an official split.

## Packages

| Package | Runtime | Purpose |
| --- | --- | --- |
| `aptabase_plus` | Dart | Core client, event model, queue abstraction, transport abstraction, system-info abstraction, memory storage, and static system-info provider. |
| `aptabase_flutter_plus` | Flutter | Flutter lifecycle handling and Flutter system-info collection using `package_info_plus` and `device_info_plus`. |
| `aptabase_storage_shared_preferences_plus` | Flutter | Queue persistence backed by `SharedPreferencesAsync`. Best for simple Flutter apps that want the smallest setup. |
| `aptabase_storage_hive_ce_plus` | Dart + Flutter | Queue persistence backed by Hive CE. Best for Dart-only apps, stronger offline queues, and projects that already use Hive CE. |

## Why the SDK is split

The original Flutter SDK was convenient, but it mixed several responsibilities into one package:

- event creation and queueing;
- HTTP transport;
- app/device/system metadata collection;
- persistent storage;
- Flutter lifecycle hooks.

That works for a Flutter-only SDK, but it blocks usage in pure Dart environments and makes it harder for apps to choose their own persistence backend. In this workspace, the core package owns the analytics behaviour while platform packages provide runtime-specific defaults.

## Recommended package combinations

### Flutter app with simple storage

Use this when you want the quickest Flutter setup.

```yaml
dependencies:
  aptabase_flutter_plus:
    path: packages/aptabase_flutter_plus
  aptabase_storage_shared_preferences_plus:
    path: packages/aptabase_storage_shared_preferences_plus
```

```dart
import 'package:aptabase_flutter_plus/aptabase_plus_flutter.dart';
import 'package:aptabase_storage_shared_preferences_plus/aptabase_storage_shared_preferences_plus.dart';

await Aptabase.init(
  'A-US-0000000000',
  storage: SharedPreferencesAptabaseStorage(),
);
```

### Flutter app with Hive CE storage

Use this when you want a stronger queue backend or your app already uses Hive CE.

```yaml
dependencies:
  aptabase_flutter_plus:
    path: packages/aptabase_flutter_plus
  aptabase_storage_hive_ce_plus:
    path: packages/aptabase_plus_hive_ce
```

```dart
final storage = await HiveCeAptabaseStorage.open(
  boxName: 'aptabase_events',
);

await Aptabase.init(
  'A-US-0000000000',
  storage: storage,
);
```

### Dart-only app

Use the core package directly and provide storage/system information explicitly.

```yaml
dependencies:
  aptabase_plus:
    path: packages/aptabase_plus
  aptabase_storage_hive_ce_plus:
    path: packages/aptabase_plus_hive_ce
```

```dart
final storage = await HiveCeAptabaseStorage.open(
  directoryPath: '.dart_tool/aptabase_events',
);

final client = await Aptabase.init(
  'A-US-0000000000',
  storage: storage,
  systemInfoProvider: const StaticAptabaseSystemInfoProvider(
    AptabaseSystemInfo(
      osName: 'dart',
      osVersion: '3.x',
      locale: 'en',
      appVersion: '1.0.0',
      appBuildNumber: '1',
      isDebug: false,
    ),
  ),
);
```

## Workspace structure

```text
packages/
  aptabase_plus/
    lib/src/client/
    lib/src/config/
    lib/src/event/
    lib/src/storage/
    lib/src/system/
    lib/src/transport/
    lib/src/utils/
    example/
    test/src/

  aptabase_flutter_plus/
    lib/src/client/
    lib/src/lifecycle/
    lib/src/system/
    example/
    test/src/

  aptabase_storage_shared_preferences_plus/
    lib/src/
    example/
    test/src/

  aptabase_storage_hive_ce_plus/
    lib/src/
    example/
    test/src/
```

Tests mirror the `lib/src` layout so implementation changes have an obvious test location.

## Development

Resolve dependencies from the workspace root:

```bash
dart pub get
```

Run pure Dart tests:

```bash
dart test packages/aptabase_plus
dart test packages/aptabase_plus_hive_ce
```

Run Flutter tests:

```bash
flutter test packages/aptabase_flutter_plus
flutter test packages/aptabase_storage_shared_preferences_plus
```

Run a package example:

```bash
cd packages/aptabase_plus/example
dart run -DAPTABASE_APP_KEY=A-US-0000000000 bin/main.dart

cd ../../aptabase_flutter_plus/example
flutter run -d chrome --dart-define=APTABASE_APP_KEY=A-US-0000000000
```

## Publishing notes

All packages currently set `publish_to: none` because this is a local fork workspace. Before publishing, review package names, repository URLs, SDK constraints, API stability, and the relationship to the official Aptabase SDK.

## Relationship to Aptabase

This workspace is designed as a clean fork/split pattern. It is not presented as an official Aptabase release. The public API keeps familiar naming where useful, but the internal structure is intentionally modular so the pattern can be proposed upstream later.
