import 'package:http/http.dart' as http;

import 'aptabase_transport.dart';

/// Standard Dart check for web environments without needing Flutter imports.
const bool _kIsWeb = bool.fromEnvironment('dart.library.js_interop');

/// HTTP implementation of [AptabaseTransport] using `package:http`.
class HttpAptabaseTransport implements AptabaseTransport {
  HttpAptabaseTransport({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AptabaseTransportResult> sendEvents({
    required Uri endpoint,
    required String appKey,
    required String sdkVersion,
    required List<String> events,
  }) async {
    final headers = {
      'App-Key': appKey,
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // Browsers often block or warn when manually overriding the User-Agent.
    // We replicate the original SDK's behavior by skipping it on the Web.
    if (!_kIsWeb) {
      headers['User-Agent'] = sdkVersion;
    }

    final response = await _client.post(
      endpoint,
      headers: headers,
      body: '[${events.join(',')}]',
    );

    return AptabaseTransportResult(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  void close() => _client.close();
}
