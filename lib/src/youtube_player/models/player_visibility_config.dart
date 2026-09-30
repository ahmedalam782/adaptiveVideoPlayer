/// Configuration model for player control visibility and timeout settings (SRP)
class PlayerVisibilityConfig {
  /// Whether to show video controls
  final bool showControls;

  /// Whether to show fullscreen button
  final bool showFullscreenButton;

  /// Whether to show settings button
  final bool showSettingsButton;

  /// Whether to show miniplayer (Picture-in-Picture) button
  final bool showMiniPlayerButton;

  /// Whether to show volume / mute control button
  final bool showVolumeButton;

  /// Whether to show time duration display (position / duration)
  final bool showTimeDisplay;

  /// Whether to show timeline progress bar slider
  final bool showProgressBar;

  /// Whether to show center play/pause indicator overlay
  final bool showCenterPlayPause;

  /// Whether to show LIVE status indicator badge
  final bool showLiveBadge;

  /// Whether to show auto play setting in settings sheet
  final bool showAutoPlaySetting;

  /// Whether to show loop video setting in settings sheet
  final bool showLoopSetting;

  /// Whether to show force HD quality setting in settings sheet
  final bool showForceHDSetting;

  /// Whether to show enable captions setting in settings sheet
  final bool showCaptionsSetting;

  /// Whether to show mute audio setting in settings sheet
  final bool showMuteSetting;

  /// Whether to show quality / resolution setting in settings sheet
  final bool showQualitySetting;

  /// Whether to show subtitles setting in settings sheet
  final bool showSubtitlesSetting;

  /// Whether to show playback speed setting in settings sheet
  final bool showPlaybackSpeedSetting;

  /// Whether to show the chapter title in the bottom bar time display
  final bool showChapterTitle;

  /// Whether to show volume HUD feedback on volume adjustment
  final bool showVolumeFeedback;

  /// Whether to show -10s and +10s seek buttons in bottom controls
  final bool showSkipButtons;

  /// Duration to seek when skip buttons are tapped (default 10s)
  final Duration skipDuration;

  /// Timeout duration before controls automatically hide
  final Duration controlsHideTimeout;

  /// Timeout duration for volume feedback HUD overlay
  final Duration volumeFeedbackTimeout;

  const PlayerVisibilityConfig({
    this.showControls = true,
    this.showFullscreenButton = true,
    this.showSettingsButton = true,
    this.showMiniPlayerButton = true,
    this.showVolumeButton = true,
    this.showTimeDisplay = true,
    this.showProgressBar = true,
    this.showCenterPlayPause = true,
    this.showLiveBadge = true,
    this.showAutoPlaySetting = true,
    this.showLoopSetting = true,
    this.showForceHDSetting = true,
    this.showCaptionsSetting = true,
    this.showMuteSetting = true,
    this.showQualitySetting = true,
    this.showSubtitlesSetting = true,
    this.showPlaybackSpeedSetting = true,
    this.showChapterTitle = true,
    this.showVolumeFeedback = true,
    this.showSkipButtons = true,
    this.skipDuration = const Duration(seconds: 10),
    this.controlsHideTimeout = const Duration(seconds: 3),
    this.volumeFeedbackTimeout = const Duration(milliseconds: 1200),
  });

  /// Creates a copy with updated values
  PlayerVisibilityConfig copyWith({
    bool? showControls,
    bool? showFullscreenButton,
    bool? showSettingsButton,
    bool? showMiniPlayerButton,
    bool? showVolumeButton,
    bool? showTimeDisplay,
    bool? showProgressBar,
    bool? showCenterPlayPause,
    bool? showLiveBadge,
    bool? showAutoPlaySetting,
    bool? showLoopSetting,
    bool? showForceHDSetting,
    bool? showCaptionsSetting,
    bool? showMuteSetting,
    bool? showQualitySetting,
    bool? showSubtitlesSetting,
    bool? showPlaybackSpeedSetting,
    bool? showChapterTitle,
    bool? showVolumeFeedback,
    bool? showSkipButtons,
    Duration? skipDuration,
    Duration? controlsHideTimeout,
    Duration? volumeFeedbackTimeout,
  }) {
    return PlayerVisibilityConfig(
      showControls: showControls ?? this.showControls,
      showFullscreenButton: showFullscreenButton ?? this.showFullscreenButton,
      showSettingsButton: showSettingsButton ?? this.showSettingsButton,
      showMiniPlayerButton: showMiniPlayerButton ?? this.showMiniPlayerButton,
      showVolumeButton: showVolumeButton ?? this.showVolumeButton,
      showTimeDisplay: showTimeDisplay ?? this.showTimeDisplay,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      showCenterPlayPause: showCenterPlayPause ?? this.showCenterPlayPause,
      showLiveBadge: showLiveBadge ?? this.showLiveBadge,
      showAutoPlaySetting: showAutoPlaySetting ?? this.showAutoPlaySetting,
      showLoopSetting: showLoopSetting ?? this.showLoopSetting,
      showForceHDSetting: showForceHDSetting ?? this.showForceHDSetting,
      showCaptionsSetting: showCaptionsSetting ?? this.showCaptionsSetting,
      showMuteSetting: showMuteSetting ?? this.showMuteSetting,
      showQualitySetting: showQualitySetting ?? this.showQualitySetting,
      showSubtitlesSetting: showSubtitlesSetting ?? this.showSubtitlesSetting,
      showPlaybackSpeedSetting:
          showPlaybackSpeedSetting ?? this.showPlaybackSpeedSetting,
      showChapterTitle: showChapterTitle ?? this.showChapterTitle,
      showVolumeFeedback: showVolumeFeedback ?? this.showVolumeFeedback,
      showSkipButtons: showSkipButtons ?? this.showSkipButtons,
      skipDuration: skipDuration ?? this.skipDuration,
      controlsHideTimeout: controlsHideTimeout ?? this.controlsHideTimeout,
      volumeFeedbackTimeout:
          volumeFeedbackTimeout ?? this.volumeFeedbackTimeout,
    );
  }
}
