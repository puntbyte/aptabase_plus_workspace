# aptabase_plus

`aptabase_plus` is the pure Dart core SDK for sending analytics events to Aptabase. It contains no Flutter imports and no Flutter plugin dependencies.

This package is responsible for analytics behaviour only: event modelling, queueing, batching, flushing, endpoint resolution, transport, storage abstraction, and system-info abstraction. Platform-specific concerns are provided by companion packages.

## When to use this package

Use `aptabase_plus` directly when you are building:

- a Dart CLI app;
- a server-side Dart process;
- a Jaspr or Dart-only web app;
- a test harness;
- a Flutter app that wants complete control over storage and metadata providers.

For normal Flutter apps, install `aptabase_flutter_plus` as well so app lifecycle and system metadata can be handled automatically.

## Installation

```yaml
dependencies:
  aptabase_plus:
    path: ../aptabase_plus
```

When published, replace the path dependency with the published version constraint.

## Basic Dart usage

```dart
import 'package:aptabase_plus/aptabase_plus.dart';

Future<void> main() async {
  final client = await Aptabase.init(
    'A-US-0000000000',
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

  await client.trackEvent(
    'app_started',
    props: {'source': 'dart'},
  );

  await client.flush();
  await Aptabase.dispose();
}
```

## Storage

The core package depends on the `AptabaseStorage` interface instead of a concrete persistence mechanism.

```dart
abstract interface class AptabaseStorage {
  Future<void> init();
  Future<Iterable<MapEntry<String, String>>> getItems(int length);
  Future<void> addEvent(String key, String event);
  Future<void> deleteEvents(Set<String> keys);
}
```

A `MemoryAptabaseStorage` implementation is included for tests, examples, and short-lived processes. It is not persistent, so queued events are lost if the process exits before a flush succeeds.

Use one of the companion storage packages for persistent queues:

- `aptabase_storage_shared_preferences_plus` for simple Flutter key-value persistence;
- `aptabase_storage_hive_ce_plus` for Dart/Flutter Hive CE persistence.

## System information

The core package does not guess app version, operating system, build number, or locale. Instead, it depends on `AptabaseSystemInfoProvider`.

For Dart-only usage, pass a static provider:

```dart
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
```

For Flutter usage, `aptabase_flutter_plus` provides `FlutterAptabaseSystemInfoProvider` using Flutter-compatible plugins.

## Transport

`AptabaseTransport` is responsible for sending batched events. The default implementation uses `package:http`, but tests and specialised runtimes can inject their own transport.

```dart
final client = AptabaseClient(
  appKey: 'A-US-0000000000',
  transport: MyAptabaseTransport(),
);
```

## Options

`AptabaseOptions` controls operational behaviour:

- `host` for self-hosted Aptabase deployments;
- `tickDuration` for periodic flush cadence;
- `batchLength` for maximum events per flush;
- `debugLogEnabled` for local diagnostics.

```dart
await Aptabase.init(
  'A-US-0000000000',
  options: const AptabaseOptions(
    debugLogEnabled: true,
    batchLength: 25,
  ),
);
```

## Session behaviour

The client keeps a generated session ID and rotates it after a long period of inactivity. Each tracked event includes the current session ID and the system metadata returned by the configured provider.

## Testing

Tests are organised to mirror `lib/src`:

```text
test/src/client/
test/src/config/
test/src/storage/
```

Run tests from the workspace root or package directory:

```bash
dart test packages/aptabase_plus
```

## Design principle

`aptabase_plus` should stay small, portable, and dependency-light. Avoid adding Flutter plugins, storage libraries, or runtime-specific discovery logic to this package. Add those concerns as companion adapters instead.
