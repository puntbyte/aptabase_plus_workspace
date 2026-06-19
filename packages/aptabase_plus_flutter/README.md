# aptabase_plus_flutter

The official Flutter integration layer for `aptabase_plus`.

**Why this package was created:**
The original `aptabase_flutter` package was abandoned for over 2 years. It forced developers to use `shared_preferences` and `universal_io`, which broke Wasm compatibility and prevented pure Dart usage. This modernized package acts purely as an integration layer. It injects Flutter lifecycle hooks and Flutter device metadata into the pure Dart `aptabase_plus` core via Dart extension methods.

## Migration Guide (From `aptabase_flutter`)

If you are migrating from the old monolithic `aptabase_flutter` package, here is what changed:

1.  **Explicit Storage:** The SDK no longer secretly bundles `shared_preferences`. You must explicitly choose and pass a storage adapter (like `aptabase_plus_hive_ce`).
2.  **Initialization Method:** You now call `Aptabase.initFlutter(...)` instead of `Aptabase.init(...)`.
3.  **Wasm Ready:** The package now compiles perfectly for Flutter Web Wasm.

**Before (Old SDK):**
```dart
import 'package:aptabase_flutter/aptabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Aptabase.init('A-US-0000000000'); // Implicitly used shared_preferences
  runApp(MyApp());
}
```

**After (New SDK):**
```dart
import 'package:aptabase_plus_flutter/aptabase_plus_flutter.dart';
import 'package:aptabase_plus_hive_ce/aptabase_plus_hive_ce.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize your storage choice explicitly
  final storage = await HiveCeAptabaseStorage.open();
  
  // 2. Initialize Aptabase using the Flutter extension
  await Aptabase.initFlutter('A-US-0000000000', storage: storage);
  
  runApp(MyApp());
}
```

## Installation

You need this package plus a storage adapter.

```yaml
dependencies:
  aptabase_plus_flutter: ^0.1.0
  aptabase_plus_hive_ce: ^0.1.0 # Recommended for robust offline queues
```

## Usage

After calling `Aptabase.initFlutter(...)` in your `main()` function, you can track events anywhere in your UI:

```dart
ElevatedButton(
  onPressed: () {
    Aptabase.instance.trackEvent(
      'checkout_started',
      props: {
        'cart_size': 3,
        'currency': 'USD'
      },
    );
  },
  child: Text('Checkout'),
);
```

## API Reference

### `Aptabase.initFlutter(...)`
An extension method on the global `Aptabase` facade that initializes Flutter-specific plugins.
*   `appKey` (String): Your Aptabase App Key.
*   `storage` (AptabaseStorage): Your persistent storage adapter. If left null, a warning is printed and `MemoryAptabaseStorage` is used.
*   `attachLifecycle` (bool): Defaults to `true`. Automatically listens to Flutter app lifecycle events to pause timers on background and flush events on app exit.
*   `options` (AptabaseOptions): Configuration for host and debug logging.

## 🤖 For AI Agents & Code Generators
*   **Package Name:** `aptabase_plus_flutter`
*   **Initialization:** MUST use `Aptabase.initFlutter(appKey, storage: storage)`. Do not use `Aptabase.init`.
*   **Requirement:** `WidgetsFlutterBinding.ensureInitialized()` MUST be called before `initFlutter`.
*   **Storage:** Always configure a storage adapter. If a user asks for setup, include the setup for `aptabase_plus_hive_ce` or a similar adapter.
