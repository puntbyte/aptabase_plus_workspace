import 'dart:io';

import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:aptabase_plus_hive_ce/src/hive_ce_aptabase_storage.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:test/test.dart';

void main() {
  group('HiveCeAptabaseStorage', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('aptabase_hive_ce_test_');
    });

    tearDown(() async {
      await Hive.close();
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    test('is an AptabaseStorage adapter', () async {
      final storage = await HiveCeAptabaseStorage.open(
        boxName: 'aptabase_storage_adapter_test',
        directoryPath: directory.path,
      );

      expect(storage, isA<AptabaseStorage>());
    });

    test('stores and returns queued events', () async {
      final storage = await HiveCeAptabaseStorage.open(
        boxName: 'aptabase_storage_store_test',
        directoryPath: directory.path,
      );

      await storage.init();
      await storage.addEvent('aptabase_event_1', '{"name":"opened"}');
      await storage.addEvent('aptabase_event_2', '{"name":"clicked"}');

      final items = await storage.getItems(10);

      expect(
        items.map((entry) => entry.key),
        containsAll(<String>['aptabase_event_1', 'aptabase_event_2']),
      );
      expect(
        items.map((entry) => entry.value),
        containsAll(<String>['{"name":"opened"}', '{"name":"clicked"}']),
      );
    });

    test('returns only prefixed Aptabase event keys', () async {
      final storage = await HiveCeAptabaseStorage.open(
        boxName: 'aptabase_storage_prefix_test',
        directoryPath: directory.path,
      );

      await storage.init();
      await storage.box.put('other_key', 'ignore me');
      await storage.addEvent('aptabase_event_1', '{"name":"opened"}');

      final items = await storage.getItems(10);

      expect(items, hasLength(1));
      expect(items.single.key, 'aptabase_event_1');
    });

    test('deletes queued events', () async {
      final storage = await HiveCeAptabaseStorage.open(
        boxName: 'aptabase_storage_delete_test',
        directoryPath: directory.path,
      );

      await storage.init();
      await storage.addEvent('aptabase_event_1', '{"name":"opened"}');
      await storage.deleteEvents(<String>{'aptabase_event_1'});

      final items = await storage.getItems(10);

      expect(items, isEmpty);
    });
  });
}
