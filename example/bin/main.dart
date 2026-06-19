import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:aptabase_plus_hive_ce/aptabase_plus_hive_ce.dart';

Future<void> main(List<String> args) async {
  // Read the app key from the environment, defaulting to DEV
  const appKey = String.fromEnvironment('APTABASE_APP_KEY', defaultValue: 'A-DEV-0000000000');

  // 1. Initialize persistent storage for pure Dart
  final storage = await HiveCeAptabaseStorage.open(
    directoryPath: '.dart_tool/aptabase_events',
  );

  // 2. Initialize the core client
  await Aptabase.init(
    appKey,
    storage: storage,
    options: const AptabaseOptions(debugLogEnabled: true),
    startTimer: false, // We will manually flush for this short-lived CLI script
  );

  print('Tracking event from Dart CLI...');

  // 3. Track events using the global singleton
  await Aptabase.instance.trackEvent(
    'dart_example_started',
    props: {
      'runtime': 'dart',
      'argumentCount': args.length,
    },
  );

  print('Flushing events...');
  await Aptabase.instance.flush();

  print('Shutting down...');
  await Aptabase.dispose(flush: false);
  await storage.close();
}