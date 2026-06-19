# aptabase_plus

The pure Dart core SDK for sending analytics events to Aptabase.

**Why this package was created:**
The original `aptabase_flutter` package was architecturally monolithic—mixing pure Dart HTTP logic with Flutter-specific plugins and hardcoding `shared_preferences` for storage. This made it impossible to use in pure Dart environments (CLI, Server, Wasm) and prevented Dependency Injection.

`aptabase_plus` solves this by completely decoupling the analytics core. It has zero Flutter dependencies and relies entirely on injected interfaces for storage, transport, and system metadata.

---

## Installation

```yaml
dependencies:
  aptabase_plus: ^0.1.0
```

*(Note: If you are building a Flutter app, you should also install `aptabase_plus_flutter` for lifecycle hooks and device info).*

---

## Usage Styles

You can use `aptabase_plus` in two ways: via the **Global Singleton Facade** (easiest for small scripts) or by instantiating the **`AptabaseClient` directly** (best for Dependency Injection and large apps).

### 1. Global Singleton (Quick Start)

Use `Aptabase.init()` to configure the global instance.

```dart
import 'package:aptabase_plus/aptabase_plus.dart';

Future<void> main() async {
  // IMPORTANT: Use a persistent storage adapter in production!
  // (e.g., HiveCeAptabaseStorage from aptabase_plus_hive_ce)
  final storage = MemoryAptabaseStorage(); 

  // Initialize the singleton
  await Aptabase.init(
    'A-US-0000000000',
    storage: storage,
    options: const AptabaseOptions(debugLogEnabled: true),
  );

  // Track an event anywhere in your app
  await Aptabase.instance.trackEvent('app_started', props: {'runtime': 'dart'});
  
  // Flush before exiting (useful for short-lived CLI tools)
  await Aptabase.instance.flush();
}
```

### 2. Dependency Injection (Recommended)

If you prefer to avoid global state, you can instantiate the `AptabaseClient` directly. This is highly recommended when wrapping Aptabase in a unified telemetry interface.

```dart
import 'package:aptabase_plus/aptabase_plus.dart';

Future<void> main() async {
  final client = AptabaseClient(
    appKey: 'A-US-0000000000',
    storage: MemoryAptabaseStorage(), // Inject persistence
    options: const AptabaseOptions(batchLength: 10),
  );

  await client.init(); // Starts the background flush timer

  await client.trackEvent('user_signup', props: {'source': 'cli'});
}
```

---

## Comprehensive API Reference

### Core Client (`AptabaseClient`)
The worker class that handles event queuing, session generation, and HTTP transport.
*   `init({bool startTimer = true})`: Initializes storage, flushes pending offline events, and starts the background flush timer.
*   `trackEvent(String eventName, {Map<String, Object?>? props})`: Queues an event. **Note:** Aptabase strictly requires `props` values to be `String`, `int`, or `double`.
*   `flush({String reason})`: Forces the queue to immediately send all pending batches to the server.
*   `start()` / `stop()`: Manually controls the background flush timer.
*   `dispose({bool flush = true})`: Stops timers and safely shuts down the client.

### Configuration (`AptabaseOptions`)
Passed to the client during initialization.
*   `host`: Custom domain for Self-Hosted Aptabase instances.
*   `tickDuration`: How often the background timer flushes events (Default: 30 seconds).
*   `batchLength`: Max number of events to send in a single HTTP request (Default & Max: 25).
*   `debugLogEnabled`: Enables verbose `dart:developer` logs for tracking queue states and network errors.

---

## Pluggable Interfaces (Advanced)

The true power of `aptabase_plus` is that every system interaction is abstracted behind an interface. You can inject your own implementations into the `AptabaseClient` constructor.

### `AptabaseStorage`
Handles offline queue persistence.
*   **Provided:** `MemoryAptabaseStorage` (Drops events on app exit).
*   **Ecosystem:** Use `aptabase_plus_hive_ce` for robust cross-platform offline persistence.

### `AptabaseSystemInfoProvider`
Supplies OS name, version, app version, and locale for every event.
*   **Provided:** `StaticAptabaseSystemInfoProvider.defaults()` (Hardcoded for CLI/Server).
*   **Ecosystem:** The `aptabase_plus_flutter` package automatically injects a provider that reads native device metadata.

### `AptabaseTransport`
Handles the actual HTTP requests to the Aptabase API.
*   **Provided:** `HttpAptabaseTransport` (Uses `package:http`).

### `SessionIdGenerator`
Generates unique identifiers for user sessions.
*   **Provided:** `RandomSessionIdGenerator` (Resets automatically after 1 hour of inactivity).

---

## 🤖 For AI Agents & Code Generators

**Context:** You are generating code for the `aptabase_plus` package, a pure Dart analytics core.

**Strict Architecture Rules:**
1.  **No Flutter:** Do NOT use `Aptabase.initFlutter()` in this package. That method belongs exclusively to the `aptabase_plus_flutter` wrapper.
2.  **Property Data Types:** `trackEvent` properties MUST evaluate to `String`, `int`, or `double`. If the user wants to pass `bool`, `List`, or `Map`, you MUST write an adapter/sanitizer to cast them to `String` (e.g., `value.toString()`). Aptabase will reject nested objects.
3.  **Dependency Injection:** If the user asks for a testable architecture, instantiate `AptabaseClient(appKey: ..., storage: ...)` directly instead of using the `Aptabase.instance` global singleton.
4.  **Storage Mandate:** If you write initialization code, *always* leave a comment warning the user to implement or import a persistent `AptabaseStorage` adapter. Do not let them silently fail with `MemoryAptabaseStorage` in production.
5.  **Global Properties / Identity:** The Aptabase API does not have native endpoints for `identifyUser` or `setGlobalContext`. If a user requests this functionality, implement it locally by keeping a `Map<String, Object>` in memory and merging it into the `props` map on every `trackEvent` call.
