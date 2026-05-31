import 'package:aptabase_flutter_plus/aptabase_flutter_plus.dart';
import 'package:aptabase_storage_shared_preferences_plus/aptabase_storage_shared_preferences_plus.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const appKey = String.fromEnvironment('APTABASE_APP_KEY', defaultValue: 'A-DEV-0000000000');

  await Aptabase.init(
    appKey,
    options: const AptabaseOptions(debugLogEnabled: true),
    storage: SharedPreferencesAptabaseStorage(),
  );

  runApp(const AptabaseExampleApp());
}

class AptabaseExampleApp extends StatelessWidget {
  const AptabaseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aptabase Flutter Plus',
      theme: ThemeData(useMaterial3: true),
      home: const AptabaseExamplePage(),
    );
  }
}

class AptabaseExamplePage extends StatefulWidget {
  const AptabaseExamplePage({super.key});

  @override
  State<AptabaseExamplePage> createState() => _AptabaseExamplePageState();
}

class _AptabaseExamplePageState extends State<AptabaseExamplePage> {
  int _count = 0;

  Future<void> _trackTap() async {
    setState(() => _count++);

    await Aptabase.instance.trackEvent('example_button_tapped', props: {'count': _count});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aptabase Flutter Plus')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tracked taps: $_count'),
            const SizedBox(height: 16),
            FilledButton(onPressed: _trackTap, child: const Text('Track event')),
          ],
        ),
      ),
    );
  }
}
