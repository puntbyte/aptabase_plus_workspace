import 'package:aptabase_plus_flutter/aptabase_plus_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AptabaseFlutterExtension', () {
    test('throws before initialization', () {
      expect(() => Aptabase.instance, throwsStateError);
    });
  });
}
