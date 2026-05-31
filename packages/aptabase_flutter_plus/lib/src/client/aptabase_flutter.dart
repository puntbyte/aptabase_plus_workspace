import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:flutter/widgets.dart';

import '../lifecycle/flutter_aptabase_lifecycle.dart';
import '../system/flutter_aptabase_system_info_provider.dart';

/// Flutter-oriented Aptabase facade.
///
/// This package wires Flutter lifecycle callbacks and Flutter system metadata
/// into the pure Dart [AptabaseClient]. Storage is intentionally injected so
/// apps can choose the persistence backend that fits their runtime and offline
/// requirements.
class AptabaseFlutter {
  AptabaseFlutter._();

  static const sdkVersion = 'aptabase_flutter_plus@0.1.0';

  static AptabaseClient? _client;
  static FlutterAptabaseLifecycle? _lifecycle;

  static AptabaseClient get instance {
    final client = _client;
    if (client == null) {
      throw StateError('Aptabase.init must be called before Aptabase.instance.');
    }

    return client;
  }

  static Future<AptabaseClient> init(
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

    final client = AptabaseClient(
      appKey: appKey,
      options: options,
      storage: storage,
      systemInfoProvider: systemInfoProvider ?? FlutterAptabaseSystemInfoProvider(),
      transport: transport,
      sessionIdGenerator: sessionIdGenerator,
      sdkVersion: sdkVersion,
    );

    await client.init(startTimer: startTimer);

    _lifecycle?.detach();
    _client = client;

    if (attachLifecycle) {
      _lifecycle = FlutterAptabaseLifecycle(client)..attach();
    } else {
      _lifecycle = null;
    }

    return client;
  }

  static Future<void> dispose({bool flush = true}) async {
    _lifecycle?.detach();
    _lifecycle = null;

    final client = _client;
    _client = null;
    await client?.dispose(flush: flush);
  }
}
