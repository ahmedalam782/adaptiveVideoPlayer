/// Centralized UI strings, labels, and tooltips used across the video player package.
///
/// Follows Clean Architecture and Single Responsibility Principle (SRP)
/// by keeping all user-facing default texts in a single maintainable location.
class PlayerStrings {
  const PlayerStrings._();

  // Playback actions
  static const String play = 'Play';
  static const String pause = 'Pause';
  static const String stop = 'Stop';
  static const String replay = 'Replay';
  static const String loopVideo = 'Loop Video';

  // Seeking & Navigation
  static const String seekBackward = 'Seek backward';
  static const String seekForward = 'Seek forward';
  static const String back10Seconds = 'Back 10 seconds';
  static const String forward10Seconds = 'Forward 10 seconds';
  static const String back5Seconds = 'Back 5 seconds';
  static const String forward5Seconds = 'Forward 5 seconds';
  static const String back30Seconds = 'Back 30 seconds';
  static const String forward30Seconds = 'Forward 30 seconds';

  // Audio / Volume
  static const String mute = 'Mute';
  static const String unmute = 'Unmute';
  static const String muteAudio = 'Mute Audio';
  static const String unmuteAudio = 'Unmute Audio';
  static const String volume = 'Volume';

  // Screen Modes
  static const String fullscreen = 'Fullscreen';
  static const String exitFullscreen = 'Exit fullscreen';
  static const String miniPlayer = 'Miniplayer';
  static const String closeMiniPlayer = 'Close miniplayer';
  static const String expand = 'Expand';
  static const String close = 'Close';

  // Settings & Options
  static const String settings = 'Settings';
  static const String playerSettings = 'Player Settings';
  static const String quality = 'Quality';
  static const String subtitles = 'Subtitles';
  static const String playbackSpeed = 'Playback Speed';
  static const String autoPlay = 'Auto Play';
  static const String forceHdQuality = 'Force HD Quality';
  static const String enableCaptions = 'Enable Captions';

  // Status & Qualifiers
  static const String live = 'LIVE';
  static const String auto = 'Auto';
  static const String off = 'Off';
  static const String normal = 'Normal';
  static const String defaultSubtitle = 'Default';
  static const String noQualitiesAvailable = 'No qualities available';
  static const String noSubtitlesAvailable = 'No subtitles available';

  // Error Messages
  static const String error = 'Error';
  static const String loadFailed = 'Failed to load video';
  static const String videoUnavailable = 'Video unavailable';
  static const String videoNotCompatible = 'Video format not compatible';
  static const String securityPolicyBlocked =
      'Video cannot be loaded due to security policy';
  static const String invalidYoutubeUrl = 'Invalid YouTube URL';
  static const String retry = 'Retry';
}
