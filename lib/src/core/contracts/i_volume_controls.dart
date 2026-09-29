/// Segregated interface for volume and audio operations (ISP)
abstract class IVolumeControls {
  /// Set audio volume between 0.0 (silent) and 1.0 (max)
  Future<void> setVolume(double volume);

  /// Toggle mute on / off
  Future<void> toggleMute();

  /// Set explicit mute state
  Future<void> setMute(bool mute);
}
