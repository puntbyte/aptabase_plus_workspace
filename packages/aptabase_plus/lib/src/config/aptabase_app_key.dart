import 'aptabase_region.dart';

/// Parsed Aptabase app key.
class AptabaseAppKey {
  const AptabaseAppKey._({required this.value, required this.region, required this.projectId});

  /// Raw app key value.
  final String value;

  /// Aptabase region parsed from the app key.
  final AptabaseRegion region;

  /// Project identifier segment from the app key.
  final String projectId;

  /// Parses keys with the shape `A-REGION-PROJECT_ID`.
  static AptabaseAppKey? tryParse(String value) {
    final parts = value.split('-');
    if (parts.length != 3 || parts.first != 'A' || parts.last.isEmpty) {
      return null;
    }

    final region = AptabaseRegion.fromCode(parts[1]);
    if (region == null) return null;

    return AptabaseAppKey._(value: value, region: region, projectId: parts[2]);
  }

  /// Returns the events endpoint for this key, or `null` when the key cannot be
  /// sent because a self-hosted key is missing a host.
  Uri? eventsEndpoint({String? selfHostedHost}) {
    final baseHost = switch (region) {
      AptabaseRegion.selfHosted => selfHostedHost,
      _ => region.host,
    };

    if (baseHost == null || baseHost.trim().isEmpty) return null;

    final normalizedHost = baseHost.endsWith('/')
        ? baseHost.substring(0, baseHost.length - 1)
        : baseHost;

    return Uri.parse('$normalizedHost/api/v0/events');
  }
}
