import 'dart:async';

import '../config/aptabase_app_key.dart';
import '../config/aptabase_options.dart';
import '../event/aptabase_event.dart';
import '../storage/aptabase_storage.dart';
import '../storage/memory_aptabase_storage.dart';
import '../system/aptabase_system_info_provider.dart';
import '../transport/aptabase_transport.dart';
import '../transport/http_aptabase_transport.dart';
import '../utils/aptabase_logger.dart';
import '../utils/session_id_generator.dart';
import 'aptabase_send_result.dart';

/// Pure Dart Aptabase client.
class AptabaseClient {
  AptabaseClient({
    required this.appKey,
    AptabaseOptions options = const AptabaseOptions(),
    AptabaseStorage? storage,
    AptabaseSystemInfoProvider? systemInfoProvider,
    AptabaseTransport? transport,
    SessionIdGenerator? sessionIdGenerator,
    this.sdkVersion = defaultSdkVersion,
  }) : options = options,
        storage = storage ?? MemoryAptabaseStorage(),
        systemInfoProvider = systemInfoProvider ?? StaticAptabaseSystemInfoProvider.defaults(),
        transport = transport ?? HttpAptabaseTransport(),
        sessionIdGenerator = sessionIdGenerator ?? RandomSessionIdGenerator(),
        _logger = AptabaseLogger(options) {
    _sessionId = this.sessionIdGenerator.generate();
  }

  static const defaultSdkVersion = 'aptabase_plus@0.1.0';
  static const _sessionTimeout = Duration(hours: 1);

  final String appKey;
  final AptabaseOptions options;
  final AptabaseStorage storage;
  final AptabaseSystemInfoProvider systemInfoProvider;
  final AptabaseTransport transport;
  final SessionIdGenerator sessionIdGenerator;
  final String sdkVersion;

  final AptabaseLogger _logger;

  Timer? _timer;
  bool _isFlushRunning = false;
  bool _isInitialized = false;
  late String _sessionId;
  DateTime _lastTouchAt = DateTime.now().toUtc();

  AptabaseAppKey? get _parsedAppKey => AptabaseAppKey.tryParse(appKey);

  Uri? get _eventsEndpoint => _parsedAppKey?.eventsEndpoint(selfHostedHost: options.host);

  bool get isEnabled => _eventsEndpoint != null;

  /// Initializes storage, flushes pending events, and starts the auto-flush timer.
  Future<void> init({bool startTimer = true}) async {
    if (!isEnabled) {
      _logger.error(
        'The Aptabase App Key is invalid or self-hosted host is missing. '
        'Tracking will be disabled.',
      );
      return;
    }

    await storage.init();
    _isInitialized = true;

    await flush(reason: 'init');

    if (startTimer) start();

    _logger.info('Aptabase initialized.');
  }

  /// Starts the periodic flush timer.
  void start() {
    if (!isEnabled || _timer != null) return;

    _timer = Timer.periodic(options.tickDuration, (_) => unawaited(flush(reason: 'timer')));
  }

  /// Stops the periodic flush timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Flushes queued events immediately.
  Future<void> flush({String reason = 'manual'}) async {
    if (!isEnabled || !_isInitialized) return;

    _logger.debug('Checking queued events ($reason).');

    if (_isFlushRunning) {
      _logger.debug('Flush already running; skipping duplicate call.');
      return;
    }

    _isFlushRunning = true;

    try {
      final items = await storage.getItems(options.batchLength);
      if (items.isEmpty) return;

      final events = items.map((entry) => entry.value).toList(growable: false);
      final result = await _send(events);

      switch (result) {
        case AptabaseSendResult.disabled:
          stop();
        case AptabaseSendResult.retry:
          break;
        case AptabaseSendResult.success:
        case AptabaseSendResult.discard:
          await storage.deleteEvents(items.map((entry) => entry.key).toSet());
      }
    } catch (error, stackTrace) {
      _logger.error('Error while flushing Aptabase events: $error', error, stackTrace);
    } finally {
      _isFlushRunning = false;
    }
  }

  /// Records an event with the given name and optional properties.
  Future<void> trackEvent(String eventName, {Map<String, Object?>? props}) async {
    if (!isEnabled || !_isInitialized) {
      _logger.info('Tracking is disabled or the client has not been initialized.');
      return;
    }

    final timestamp = DateTime.now().toUtc();
    final systemInfo = (await systemInfoProvider.getSystemInfo()).copyWith(sdkVersion: sdkVersion);
    final event = AptabaseEvent(
      timestamp: timestamp,
      sessionId: _evaluateSessionId(),
      eventName: eventName,
      systemInfo: systemInfo,
      props: props,
    );

    final key = _eventStorageKey(timestamp);
    await storage.addEvent(key, event.toJsonString());
  }

  /// Stops timers and optionally flushes queued events.
  Future<void> dispose({bool flush = true}) async {
    stop();

    if (flush) {
      await this.flush(reason: 'dispose');
    }
  }

  Future<AptabaseSendResult> _send(List<String> events) async {
    final endpoint = _eventsEndpoint;
    if (endpoint == null) return AptabaseSendResult.disabled;

    try {
      _logger.debug('Sending ${events.length} Aptabase event(s).');

      final result = await transport.sendEvents(
        endpoint: endpoint,
        appKey: appKey,
        sdkVersion: sdkVersion,
        events: events,
      );

      if (result.isSuccess) {
        _logger.debug('Aptabase events sent successfully.');
        return AptabaseSendResult.success;
      }

      if (result.isRetryable) {
        _logger.error('Aptabase send failed with status ${result.statusCode}. Will retry later.');
        return AptabaseSendResult.retry;
      }

      _logger.error(
        'Aptabase send failed with status ${result.statusCode}. '
        'Queued events will be discarded. Response: ${result.body}',
      );
      return AptabaseSendResult.discard;
    } on Exception catch (error, stackTrace) {
      _logger.error('Aptabase transport exception: $error', error, stackTrace);
      return AptabaseSendResult.retry;
    }
  }

  String _evaluateSessionId() {
    final now = DateTime.now().toUtc();
    final elapsed = now.difference(_lastTouchAt);

    if (elapsed > _sessionTimeout) {
      _sessionId = sessionIdGenerator.generate();
      _logger.debug('New Aptabase session ID generated: $_sessionId');
    }

    _lastTouchAt = now;
    return _sessionId;
  }

  String _eventStorageKey(DateTime timestamp) {
    final micros = timestamp.microsecondsSinceEpoch;
    final suffix = sessionIdGenerator.generate();
    return 'aptabase_event_${micros}_$suffix';
  }
}
