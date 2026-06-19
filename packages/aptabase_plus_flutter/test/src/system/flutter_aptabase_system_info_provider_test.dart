import 'package:aptabase_plus_flutter/aptabase_plus_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterAptabaseSystemInfoProvider', () {
    test('can be constructed', () {
      expect(FlutterAptabaseSystemInfoProvider(), isA<AptabaseSystemInfoProvider>());
    });
  });
}
