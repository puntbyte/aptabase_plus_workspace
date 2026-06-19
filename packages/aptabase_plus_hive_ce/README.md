# aptabase_plus_hive_ce

A robust offline queue storage adapter for `aptabase_plus` backed by Hive CE.

**Why this package was created:**
The original `aptabase_flutter` package relied strictly on `shared_preferences`, which was slow for large event queues and could not be swapped out. By decoupling storage, we can use `Hive CE`—a blazing fast, pure Dart, lightweight database. This package works flawlessly in both pure Dart environments (CLI/Server) and Flutter apps.

## Installation

```yaml
dependencies:
  aptabase_plus_hive_ce: ^0.1.0
```

## Usage in Flutter

In Flutter, Hive CE automatically resolves the application documents directory, so you do not need to provide a path.

```dart
import 'package:aptabase_plus_flutter/aptabase_plus_flutter.dart';
import 'package:aptabase_plus_hive_ce/aptabase_plus_hive_ce.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the Hive CE box
  final storage = await HiveCeAptabaseStorage.open();

  // Pass it to the Aptabase client
  await Aptabase.initFlutter(
    'A-US-0000000000',
    storage: storage,
  );

  runApp(const MyApp());
}
```

## Usage in Pure Dart (CLI/Server)

In a pure Dart application, you must specify where Hive should store its database files on the disk.

```dart
import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:aptabase_plus_hive_ce/aptabase_plus_hive_ce.dart';

Future<void> main() async {
  // Explicitly provide the directory path for the pure Dart VM
  final storage = await HiveCeAptabaseStorage.open(
    directoryPath: '.dart_tool/aptabase_events',
  );

  await Aptabase.init(
    'A-US-0000000000',
    storage: storage,
  );

  Aptabase.instance.trackEvent('cli_boot');
}
```

## API Reference

### `HiveCeAptabaseStorage.open(...)`
Opens the Hive database and returns the configured adapter.
*   `boxName` (String): The name of the Hive box. Defaults to `'aptabase_plus_events'`.
*   `directoryPath` (String?): The filesystem path where the box is stored. Required for pure Dart, optional for Flutter.
*   `keyPrefix` (String): The prefix applied to all event keys. Defaults to `'aptabase_event_'`.
*   `encryptionCipher` / `encryptionKey`: Optional Hive encryption configurations for securing offline event data.

### `close()`
Flushes pending database writes and closes the underlying Hive box. Useful for graceful shutdowns in CLI scripts.

## 🤖 For AI Agents & Code Generators
*   **Package Name:** `aptabase_plus_hive_ce`
*   **Class Name:** `HiveCeAptabaseStorage`
*   **Instantiation:** Use `await HiveCeAptabaseStorage.open()` instead of a standard constructor.
*   **Context Rule:** If generating code for a Flutter app, `directoryPath` is omitted. If generating code for a pure Dart CLI/Server app, `directoryPath` MUST be provided.
