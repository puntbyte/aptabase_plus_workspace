import 'aptabase_system_info.dart';

/// Resolves `true` only when the code is executed in debug mode.
bool get _isDartDebug {
  var debug = false;
  assert(() {
    debug = true;
    return true;
  }());
  return debug;
}

/// Supplies runtime metadata for events.
abstract interface class AptabaseSystemInfoProvider {
  Future<AptabaseSystemInfo> getSystemInfo();
}

/// Static provider for Dart-only runtimes where the host app owns system info.
class StaticAptabaseSystemInfoProvider implements AptabaseSystemInfoProvider {
  const StaticAptabaseSystemInfoProvider(this.systemInfo);

  /// Minimal default values for CLI/tests. Production apps should provide their
  /// real app version, build number, locale, and runtime details.
  StaticAptabaseSystemInfoProvider.defaults()
      : systemInfo = AptabaseSystemInfo(
    osName: 'dart',
    osVersion: '',
    locale: 'en',
    appVersion: '0.0.0',
    appBuildNumber: '0',
    isDebug: _isDartDebug,
  );

  final AptabaseSystemInfo systemInfo;

  @override
  Future<AptabaseSystemInfo> getSystemInfo() async => systemInfo;
}