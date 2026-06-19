import '../config/aptabase_options.dart';
import '../storage/aptabase_storage.dart';
import '../system/aptabase_system_info_provider.dart';
import '../transport/aptabase_transport.dart';
import '../utils/session_id_generator.dart';
import 'aptabase_client.dart';

/// The core facade for the Aptabase SDK.
class AptabaseCore {
  AptabaseCore._();

  AptabaseClient? _instance;

  /// Returns the initialized [AptabaseClient].
  /// Throws a [StateError] if [init] has not been called.
  AptabaseClient get instance {
    final client = _instance;
    if (client == null) {
      throw StateError('Aptabase has not been initialized.');
    }
    return client;
  }

  /// Initializes the Aptabase client for pure Dart/CLI applications.
  Future<AptabaseClient> init(
      String appKey, {
        AptabaseOptions options = const AptabaseOptions(),
        AptabaseStorage? storage,
        AptabaseSystemInfoProvider? systemInfoProvider,
        AptabaseTransport? transport,
        SessionIdGenerator? sessionIdGenerator,
        bool startTimer = true,
      }) async {
    final client = AptabaseClient(
      appKey: appKey,
      options: options,
      storage: storage,
      systemInfoProvider: systemInfoProvider,
      transport: transport,
      sessionIdGenerator: sessionIdGenerator,
    );

    await client.init(startTimer: startTimer);
    _instance = client;

    return client;
  }

  /// Flushes pending events and stops the background timer.
  Future<void> dispose({bool flush = true}) async {
    final client = _instance;
    _instance = null;
    await client?.dispose(flush: flush);
  }
}

/// Global singleton instance of the Aptabase facade.
// ignore: non_constant_identifier_names
final AptabaseCore Aptabase = AptabaseCore._();