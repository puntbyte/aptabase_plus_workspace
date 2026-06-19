import 'dart:async';

import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:flutter/widgets.dart';

/// Bridges Flutter app lifecycle changes to an Aptabase client.
class FlutterAptabaseLifecycle {
  FlutterAptabaseLifecycle(this.client);

  final AptabaseClient client;
  AppLifecycleListener? _listener;

  void attach() {
    _listener?.dispose();
    _listener = AppLifecycleListener(
      // Trigger flush as soon as the app loses focus. Doing this onInactive instead
      // of onPause gives the HTTP request the maximum amount of time to complete
      // before the OS suspends the process entirely.
      onInactive: () => unawaited(client.flush(reason: 'lifecycle inactive')),

      // Stop the periodic flush timer once the app is fully backgrounded.
      onPause: client.stop,

      // Resume the periodic flush timer when the app comes back to the foreground.
      onResume: client.start,

      // Clean up and flush a final time if the Flutter engine is detached.
      onDetach: () => unawaited(client.dispose()),
    );
  }

  void detach() {
    _listener?.dispose();
    _listener = null;
  }
}
