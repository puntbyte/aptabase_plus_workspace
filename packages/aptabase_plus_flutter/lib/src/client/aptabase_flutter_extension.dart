import 'dart:developer' as developer;

import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:flutter/widgets.dart';

import '../lifecycle/flutter_aptabase_lifecycle.dart';
import '../system/flutter_aptabase_system_info_provider.dart';

FlutterAptabaseLifecycle? _flutterLifecycle;

/// Adds Flutter-specific initialization to the global [Aptabase] facade.
extension AptabaseFlutterExtension on AptabaseCore {
  /// Initializes Aptabase with Flutter lifecycle and system information plugins.
  Future<AptabaseClient> initFlutter(
      String appKey, {
        AptabaseOptions options = const AptabaseOptions(),
        AptabaseStorage? storage,
        AptabaseSystemInfoProvider? systemInfoProvider,
        AptabaseTransport? transport,
        SessionIdGenerator? sessionIdGenerator,
        bool startTimer = true,
        bool attachLifecycle = true,
      }) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (storage == null) {
      developer.log(
        '⚠️ WARNING: Aptabase is using MemoryAptabaseStorage.\n'
            'Events will be lost if the app is closed before flushing.\n'
            'Please provide a persistent storage adapter (e.g., SharedPreferencesAptabaseStorage '
            'or HiveCeAptabaseStorage) for production.',
        name: 'Aptabase',
        level: 900,
      );
    }

    // Call the core Dart initialization method
    final client = await init(
      appKey,
      options: options,
      storage: storage,
      systemInfoProvider: systemInfoProvider ?? FlutterAptabaseSystemInfoProvider(),
      transport: transport,
      sessionIdGenerator: sessionIdGenerator,
      startTimer: startTimer,
    );

    // Wire up Flutter app lifecycle
    _flutterLifecycle?.detach();
    if (attachLifecycle) {
      _flutterLifecycle = FlutterAptabaseLifecycle(client)..attach();
    } else {
      _flutterLifecycle = null;
    }

    return client;
  }
}