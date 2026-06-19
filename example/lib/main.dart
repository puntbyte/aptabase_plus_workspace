import 'package:aptabase_plus_flutter/aptabase_plus_flutter.dart';
import 'package:aptabase_plus_hive_ce/aptabase_plus_hive_ce.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const appKey = String.fromEnvironment('APTABASE_APP_KEY', defaultValue: 'A-DEV-0000000000');

  // 1. Initialize persistent storage for Flutter
  // (Hive CE handles the directory path automatically in Flutter)
  final storage = await HiveCeAptabaseStorage.open();

  // 2. Initialize the client using the Flutter extension!
  await Aptabase.initFlutter(
    appKey,
    storage: storage,
    options: const AptabaseOptions(debugLogEnabled: true),
  );

  runApp(const App());
}
