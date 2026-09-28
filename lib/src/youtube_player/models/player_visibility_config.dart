/// Configuration model for player control visibility and timeout settings (SRP)
class PlayerVisibilityConfig {
  /// Whether to show video controls
  final bool showControls;

  /// Whether to show fullscreen button
  final bool showFullscreenButton;

  /// Whether to show settings button
  final bool showSettingsButton;

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
    this.showAutoPlaySetting = true,
    this.showLoopSetting = true,
    this.showForceHDSetting = true,
    this.showCaptionsSetting = true,
    this.showMuteSetting = true,
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
    bool? showAutoPlaySetting,
    bool? showLoopSetting,
    bool? showForceHDSetting,
    bool? showCaptionsSetting,
    bool? showMuteSetting,
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
      showAutoPlaySetting: showAutoPlaySetting ?? this.showAutoPlaySetting,
      showLoopSetting: showLoopSetting ?? this.showLoopSetting,
      showForceHDSetting: showForceHDSetting ?? this.showForceHDSetting,
      showCaptionsSetting: showCaptionsSetting ?? this.showCaptionsSetting,
      showMuteSetting: showMuteSetting ?? this.showMuteSetting,
      showVolumeFeedback: showVolumeFeedback ?? this.showVolumeFeedback,
      showSkipButtons: showSkipButtons ?? this.showSkipButtons,
      skipDuration: skipDuration ?? this.skipDuration,
      controlsHideTimeout: controlsHideTimeout ?? this.controlsHideTimeout,
      volumeFeedbackTimeout:
          volumeFeedbackTimeout ?? this.volumeFeedbackTimeout,
    );
  }
}
