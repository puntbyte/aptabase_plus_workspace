import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:test/test.dart';

void main() {
  group('AptabaseClient', () {
    test('queues events and flushes successful batches', () async {
      final storage = MemoryAptabaseStorage();
      final transport = _FakeTransport(const AptabaseTransportResult(statusCode: 200));
      final client = AptabaseClient(
        appKey: 'A-DEV-0123456789',
        storage: storage,
        transport: transport,
        systemInfoProvider: StaticAptabaseSystemInfoProvider.defaults(),
      );

      await client.init(startTimer: false);
      await client.trackEvent('unit_test', props: {'ok': true});

      expect(storage.length, 1);

      await client.flush();

      expect(storage.length, 0);
      expect(transport.sentBatches, hasLength(1));
      expect(transport.sentBatches.single.single, contains('unit_test'));
    });

    test('keeps events when transport returns retryable status', () async {
      final storage = MemoryAptabaseStorage();
      final transport = _FakeTransport(const AptabaseTransportResult(statusCode: 500));
      final client = AptabaseClient(
        appKey: 'A-DEV-0123456789',
        storage: storage,
        transport: transport,
        systemInfoProvider: StaticAptabaseSystemInfoProvider.defaults(),
      );

      await client.init(startTimer: false);
      await client.trackEvent('retry_me');
      await client.flush();

      expect(storage.length, 1);
    });
  });
}

class _FakeTransport implements AptabaseTransport {
  _FakeTransport(this.result);

  final AptabaseTransportResult result;
  final sentBatches = <List<String>>[];

  @override
  Future<AptabaseTransportResult> sendEvents({
    required Uri endpoint,
    required String appKey,
    required String sdkVersion,
    required List<String> events,
  }) async {
    sentBatches.add(events);
    return result;
  }
}
