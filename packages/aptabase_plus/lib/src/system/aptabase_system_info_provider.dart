import 'aptabase_system_info.dart';

/// Supplies runtime metadata for events.
abstract interface class AptabaseSystemInfoProvider {
  Future<AptabaseSystemInfo> getSystemInfo();
}

/// Static provider for Dart-only runtimes where the host app owns system info.
class StaticAptabaseSystemInfoProvider implements AptabaseSystemInfoProvider {
  const StaticAptabaseSystemInfoProvider(this.systemInfo);

  /// Minimal default values for CLI/tests. Production apps should provide their
  /// real app version, build number, locale, and runtime details.
  const StaticAptabaseSystemInfoProvider.defaults()
    : systemInfo = const AptabaseSystemInfo(
        osName: 'dart',
        osVersion: '',
        locale: 'en',
        appVersion: '0.0.0',
        appBuildNumber: '0',
        isDebug: false,
      );

  final AptabaseSystemInfo systemInfo;

  @override
  Future<AptabaseSystemInfo> getSystemInfo() async => systemInfo;
}
