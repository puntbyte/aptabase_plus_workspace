import 'dart:developer' as developer;

import '../config/aptabase_options.dart';

class AptabaseLogger {
  const AptabaseLogger(this.options);

  final AptabaseOptions options;

  void debug(String message) {
    if (!options.debugLogEnabled) return;

    developer.log(message, name: 'Aptabase', level: 500);
  }

  void info(String message) {
    developer.log(message, name: 'Aptabase', level: 800);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'Aptabase', level: 1000, error: error, stackTrace: stackTrace);
  }
}
