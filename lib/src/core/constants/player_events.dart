/// Centralized analytics event names and parameter keys used across the video player package.
///
/// Ensures consistent telemetry reporting and prevents typographical errors in event strings.
class PlayerEvents {
  const PlayerEvents._();

  // Playback Events
  static const String videoPlayed = 'video_played';
  static const String videoPaused = 'video_paused';
  static const String videoStopped = 'video_stopped';
  static const String videoSeek = 'video_seek';
  static const String videoCompleted = 'video_completed';

  // Navigation / Mode Events
  static const String switchedToLive = 'switched_to_live';
  static const String fullscreenEntered = 'fullscreen_entered';
  static const String fullscreenExited = 'fullscreen_exited';
  static const String pipEntered = 'pip_entered';
  static const String pipExited = 'pip_exited';

  // Settings & Interaction Events
  static const String settingsOpened = 'settings_opened';
  static const String resolutionSettingsClicked = 'resolution_settings_clicked';
  static const String subtitleSettingsClicked = 'subtitle_settings_clicked';
  static const String speedChanged = 'speed_changed';
  static const String qualityChanged = 'quality_changed';
  static const String subtitleChanged = 'subtitle_changed';

  // Parameter Keys
  static const String paramPosition = 'position';
  static const String paramToPosition = 'to_position';
  static const String paramQuality = 'quality';
  static const String paramSpeed = 'speed';
  static const String paramSubtitle = 'subtitle';
}
