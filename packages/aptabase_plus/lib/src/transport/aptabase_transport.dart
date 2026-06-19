/// Sends queued events to Aptabase.
abstract interface class AptabaseTransport {
  Future<AptabaseTransportResult> sendEvents({
    required Uri endpoint,
    required String appKey,
    required String sdkVersion,
    required List<String> events,
  });
}

/// Result returned by an Aptabase event transport.
class AptabaseTransportResult {
  const AptabaseTransportResult({required this.statusCode, this.body = ''});

  final int statusCode;
  final String body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isRetryable => statusCode >= 500;
}
