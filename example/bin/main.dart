import 'package:aptabase_plus/aptabase_plus.dart';

Future<void> main(List<String> args) async {
  const appKey = String.fromEnvironment('APTABASE_APP_KEY', defaultValue: 'A-DEV-0000000000');

  final client = await AptabaseCore.init(
    appKey,
    options: const AptabaseOptions(debugLogEnabled: true),
    systemInfoProvider: const StaticAptabaseSystemInfoProvider(
      AptabaseSystemInfo(
        osName: 'dart',
        osVersion: '3.x',
        locale: 'en',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        isDebug: true,
      ),
    ),
    startTimer: false,
  );

  await client.trackEvent(
    'dart_example_started',
    props: {'runtime': 'dart', 'argumentCount': args.length},
  );

  await client.flush();
  await AptabaseCore.dispose(flush: false);
}
