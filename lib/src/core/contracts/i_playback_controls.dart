/// Segregated interface for playback operations (ISP)
abstract class IPlaybackControls {
  /// Start or resume video playback
  Future<void> play();

  /// Pause video playback
  Future<void> pause();

  /// Seek to a specific timestamp
  Future<void> seekTo(Duration position);

  /// Change playback speed (e.g., 0.5x, 1.0x, 1.5x, 2.0x)
  Future<void> setPlaybackSpeed(double speed);
}
