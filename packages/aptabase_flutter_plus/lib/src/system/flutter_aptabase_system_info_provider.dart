import 'package:aptabase_plus/aptabase_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Flutter implementation of [AptabaseSystemInfoProvider].
class FlutterAptabaseSystemInfoProvider implements AptabaseSystemInfoProvider {
  FlutterAptabaseSystemInfoProvider({
    DeviceInfoPlugin? deviceInfo,
    Future<PackageInfo>? packageInfo,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _packageInfo = packageInfo;

  static const _androidOsName = 'Android';
  static const _iPadOsName = 'iPadOS';
  static const _iPhoneOsName = 'iOS';
  static const _macOsName = 'macOS';
  static const _windowsOsName = 'Windows';
  static const _fuchsiaOsName = 'Fuchsia';
  static const _unknownOsVersion = '';
  static const _iPadModelToken = 'ipad';

  final DeviceInfoPlugin _deviceInfo;
  final Future<PackageInfo>? _packageInfo;

  @override
  Future<AptabaseSystemInfo> getSystemInfo() async {
    final osInfo = await _getOsInfo();
    final packageInfo = await (_packageInfo ?? PackageInfo.fromPlatform());

    return AptabaseSystemInfo(
      osName: osInfo.name,
      osVersion: osInfo.version,
      locale: PlatformDispatcher.instance.locale.toLanguageTag(),
      appVersion: packageInfo.version,
      appBuildNumber: packageInfo.buildNumber,
      isDebug: kDebugMode,
    );
  }

  Future<({String name, String version})> _getOsInfo() async {
    if (kIsWeb) {
      final info = await _deviceInfo.webBrowserInfo;
      return (name: info.browserName.name, version: info.appVersion ?? _unknownOsVersion);
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidInfo(),
      TargetPlatform.iOS => _iosInfo(),
      TargetPlatform.macOS => _macOsInfo(),
      TargetPlatform.windows => _windowsInfo(),
      TargetPlatform.linux => _linuxInfo(),
      TargetPlatform.fuchsia => Future.value((name: _fuchsiaOsName, version: _unknownOsVersion)),
    };
  }

  Future<({String name, String version})> _androidInfo() async {
    final info = await _deviceInfo.androidInfo;
    return (name: _androidOsName, version: info.version.release);
  }

  Future<({String name, String version})> _iosInfo() async {
    final info = await _deviceInfo.iosInfo;
    final isIPad = info.model.toLowerCase().contains(_iPadModelToken);
    return (name: isIPad ? _iPadOsName : _iPhoneOsName, version: info.systemVersion);
  }

  Future<({String name, String version})> _macOsInfo() async {
    final info = await _deviceInfo.macOsInfo;
    return (
      name: _macOsName,
      version: '${info.majorVersion}.${info.minorVersion}.${info.patchVersion}',
    );
  }

  Future<({String name, String version})> _windowsInfo() async {
    final info = await _deviceInfo.windowsInfo;
    return (
      name: _windowsOsName,
      version: '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
    );
  }

  Future<({String name, String version})> _linuxInfo() async {
    final info = await _deviceInfo.linuxInfo;
    return (name: info.name, version: info.versionId ?? _unknownOsVersion);
  }
}
