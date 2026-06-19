# aptabase_plus

The pure Dart core SDK for sending analytics events to Aptabase.

**Why this package was created:**
The original `aptabase_flutter` package has not been updated in over 2 years. It was architecturally monolithic—mixing pure Dart HTTP logic with Flutter-specific plugins and hardcoding `shared_preferences` for storage. This made it impossible to use in pure Dart environments (CLI, Server, Jaspr) and caused compilation issues for Wasm targets due to `universal_io`. 

`aptabase_plus` solves this by completely decoupling the analytics core. It is Wasm-ready, has zero Flutter dependencies, and relies on dependency injection for storage and system metadata.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  aptabase_plus: ^0.1.0
```

*Note: If you are building a Flutter app, you should also install `aptabase_plus_flutter`.*

## Initialization (Pure Dart / Server / CLI)

To initialize the SDK in a pure Dart environment, use `Aptabase.init()`. You must provide a storage adapter to prevent data loss.

```dart
import 'package:aptabase_plus/aptabase_plus.dart';

Future<void> main() async {
  // 1. Initialize your chosen storage adapter
  // (e.g., using aptabase_plus_hive_ce)
  final storage = MemoryAptabaseStorage(); // Use persistent storage in production!

  // 2. Initialize the core client
  await Aptabase.init(
    'A-US-0000000000',
    storage: storage,
    options: const AptabaseOptions(
      debugLogEnabled: true,
      batchLength: 25,
      tickDuration: Duration(seconds: 30),
    ),
  );

  // 3. Track events
  Aptabase.instance.trackEvent('server_started', props: {'runtime': 'dart'});
  
  // 4. Manual flush (Useful for short-lived CLI scripts)
  await Aptabase.instance.flush();
}
```

## API Reference

### `Aptabase.init(...)`
Initializes the global singleton.
*   `appKey` (String): Your Aptabase App Key.
*   `options` (AptabaseOptions): Configuration for batching and host routing.
*   `storage` (AptabaseStorage): The queue persistence adapter. Defaults to `MemoryAptabaseStorage` (not recommended for production).
*   `systemInfoProvider` (AptabaseSystemInfoProvider): Supplies OS and app metadata.
*   `transport` (AptabaseTransport): The HTTP transport layer.
*   `startTimer` (bool): Whether to start the background flush timer automatically.

### `Aptabase.instance.trackEvent(eventName, {props})`
Records an event.
*   `eventName` (String): The name of the event.
*   `props` (Map<String, Object?>?): Optional custom properties. Values must be Strings or Numbers.

### `Aptabase.instance.flush({reason})`
Forces the queue to send all pending events to the Aptabase API immediately.

### `Aptabase.dispose({flush})`
Stops the background timer and optionally flushes remaining events before shutting down.

## 🤖 For AI Agents & Code Generators
*   **Package Name:** `aptabase_plus`
*   **Architecture:** Singleton facade (`Aptabase`) holding an `AptabaseClient` instance.
*   **Constraints:**
    *   Do NOT use `Aptabase.initFlutter()`. That belongs to `aptabase_plus_flutter`.
    *   Property values passed to `trackEvent` MUST be `String`, `int`, or `double`. Booleans and nested Maps are not supported by the Aptabase API.
    *   Always remind the user to provide an `AptabaseStorage` implementation. Relying on the default `MemoryAptabaseStorage` will result in dropped events if the Dart process exits abruptly.
