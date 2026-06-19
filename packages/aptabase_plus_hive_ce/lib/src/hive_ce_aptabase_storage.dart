import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:hive_ce/hive_ce.dart';

/// Hive CE storage adapter for queued Aptabase events.
///
/// The adapter stores event payloads as strings in a Hive box. Keys are supplied
/// by [AptabaseClient], and [keyPrefix] is used when reading from a box that may
/// contain other values.
class HiveCeAptabaseStorage implements AptabaseStorage {
  HiveCeAptabaseStorage({required Box<String> box, this.keyPrefix = defaultKeyPrefix}) : _box = box;

  /// Opens a Hive CE box and wraps it in [HiveCeAptabaseStorage].
  ///
  /// On Flutter web and other runtimes that already configure Hive globally,
  /// [directoryPath] can be omitted. In Dart VM tests or command-line apps,
  /// pass [directoryPath] to keep the storage files in a known location.
  static Future<HiveCeAptabaseStorage> open({
    String boxName = defaultBoxName,
    String? directoryPath,
    HiveCipher? encryptionCipher,
    List<int>? encryptionKey,
    String keyPrefix = defaultKeyPrefix,
  }) async {
    final box = await Hive.openBox<String>(
      boxName,
      path: directoryPath,
      encryptionCipher: encryptionCipher,
      encryptionKey: encryptionKey,
    );

    return HiveCeAptabaseStorage(box: box, keyPrefix: keyPrefix);
  }

  static const defaultBoxName = 'aptabase_plus_events';
  static const defaultKeyPrefix = 'aptabase_event_';

  final Box<String> _box;
  final String keyPrefix;

  /// Returns the underlying Hive box.
  Box<String> get box => _box;

  @override
  Future<void> init() async {
    // The Hive box is opened before this adapter is created, so there is no
    // additional initialisation step required here.
  }

  @override
  Future<void> addEvent(String key, String event) async {
    await _box.put(key, event);
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    await _box.deleteAll(keys);
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    final keys = _box.keys.whereType<String>().where((key) => key.startsWith(keyPrefix)).toList()
      ..sort();

    final entries = <MapEntry<String, String>>[];

    for (final key in keys.take(length)) {
      final value = _box.get(key);
      if (value != null) {
        entries.add(MapEntry(key, value));
      }
    }

    return entries;
  }

  /// Flushes pending Hive writes and closes the box.
  Future<void> close() async {
    await _box.flush();
    await _box.close();
  }
}
