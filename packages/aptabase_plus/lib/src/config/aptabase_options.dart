const _defaultTickDuration = Duration(seconds: 30);
const _maxBatchLength = 25;

/// Options used to configure an [AptabaseClient].
class AptabaseOptions {
  const AptabaseOptions({
    this.host,
    this.tickDuration = _defaultTickDuration,
    this.batchLength = _maxBatchLength,
    this.debugLogEnabled = false,
  }) : assert(
         batchLength > 0 && batchLength <= _maxBatchLength,
         'batchLength must be between 1 and $_maxBatchLength.',
       );

  /// Required only when the app key uses the self-hosted `SH` region.
  final String? host;

  /// How often queued events are flushed while the client is running.
  final Duration tickDuration;

  /// Maximum number of queued events to send per request.
  final int batchLength;

  /// Whether verbose SDK logs should be printed through `dart:developer`.
  final bool debugLogEnabled;
}
