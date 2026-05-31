import 'package:http/http.dart' as http;

import 'aptabase_transport.dart';

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
    final response = await _client.post(
      endpoint,
      headers: {'App-Key': appKey, 'Content-Type': 'application/json; charset=UTF-8'},
      body: '[${events.join(',')}]',
    );

    return AptabaseTransportResult(statusCode: response.statusCode, body: response.body);
  }

  void close() => _client.close();
}
