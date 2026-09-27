import 'package:flutter/material.dart';

/// Configuration model for YouTube player styling
class PlayerStyleConfig {
  /// Progress bar played color
  final Color progressBarPlayedColor;

  /// Progress bar handle color
  final Color progressBarHandleColor;

  /// Loading indicator color
  final Color loadingIndicatorColor;

  /// Error icon color
  final Color errorIconColor;

  /// Icon color for controls
  final Color iconColor;

  /// Text color for time displays
  final Color textColor;

  /// Background color for player
  final Color backgroundColor;

  /// Background color for settings sheet
  final Color settingsBackgroundColor;

  /// Background color for setting items
  final Color settingItemBackgroundColor;

  /// Switch inactive thumb color
  final Color? switchInactiveThumbColor;

  /// Switch inactive track color
  final Color? switchInactiveTrackColor;

  /// Text style for time displays
  final TextStyle? timeTextStyle;

  /// Text style for settings title
  final TextStyle? settingsTitleStyle;

  /// Text style for setting items
  final TextStyle? settingItemTextStyle;

  /// Text style for error message
  final TextStyle? errorTextStyle;

  const PlayerStyleConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.loadingIndicatorColor = const Color(0xFFFF0000),
    this.errorIconColor = const Color(0xFFFF0000),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xFF1D1D1D),
    this.settingsBackgroundColor = const Color(0xFF1D1D1D),
    this.settingItemBackgroundColor = const Color(0xFF0D0D0D),
    this.switchInactiveThumbColor,
    this.switchInactiveTrackColor,
    this.timeTextStyle,
    this.settingsTitleStyle,
    this.settingItemTextStyle,
    this.errorTextStyle,
  });

  /// Creates a copy with updated values
  PlayerStyleConfig copyWith({
    Color? progressBarPlayedColor,
    Color? progressBarHandleColor,
    Color? loadingIndicatorColor,
    Color? errorIconColor,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
    Color? settingsBackgroundColor,
    Color? settingItemBackgroundColor,
    Color? switchInactiveThumbColor,
    Color? switchInactiveTrackColor,
    TextStyle? timeTextStyle,
    TextStyle? settingsTitleStyle,
    TextStyle? settingItemTextStyle,
    TextStyle? errorTextStyle,
  }) {
    return PlayerStyleConfig(
      progressBarPlayedColor:
          progressBarPlayedColor ?? this.progressBarPlayedColor,
      progressBarHandleColor:
          progressBarHandleColor ?? this.progressBarHandleColor,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      errorIconColor: errorIconColor ?? this.errorIconColor,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      settingsBackgroundColor:
          settingsBackgroundColor ?? this.settingsBackgroundColor,
      settingItemBackgroundColor:
          settingItemBackgroundColor ?? this.settingItemBackgroundColor,
      switchInactiveThumbColor:
          switchInactiveThumbColor ?? this.switchInactiveThumbColor,
      switchInactiveTrackColor:
          switchInactiveTrackColor ?? this.switchInactiveTrackColor,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      settingsTitleStyle: settingsTitleStyle ?? this.settingsTitleStyle,
      settingItemTextStyle: settingItemTextStyle ?? this.settingItemTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
    );
  }
}

/// Configuration model for YouTube player text/localization
class PlayerTextConfig {
  /// Text for invalid YouTube URL error
  final String invalidYoutubeUrlText;

  /// Text for video load failed error
  final String videoLoadFailedText;

  /// Text for video unavailable error
  final String videoUnavailableText;

  /// Text for video not compatible error
  final String videoNotCompatibleText;

  /// Text for video cannot be loaded due to security policy
  final String videoCannotBeLoadedSecurityPolicyText;

  /// Text for player settings title
  final String playerSettingsText;

  /// Text for auto play setting
  final String autoPlayText;

  /// Text for loop video setting
  final String loopVideoText;

  /// Text for force HD quality setting
  final String forceHdQualityText;

  /// Text for enable captions setting
  final String enableCaptionsText;

  /// Text for mute audio setting
  final String muteAudioText;

  /// Text when no video qualities are available
  final String noQualitiesAvailableText;

  /// Text when no subtitles are available
  final String noSubtitlesAvailableText;

  /// Text for quality setting title
  final String qualityText;

  /// Text for subtitles setting title
  final String subtitlesText;

  /// Text for auto quality
  final String autoText;

  /// Text for off subtitle
  final String offText;

  const PlayerTextConfig({
    this.invalidYoutubeUrlText = 'Invalid YouTube URL',
    this.videoLoadFailedText = 'Failed to load video',
    this.videoUnavailableText = 'Video unavailable',
    this.videoNotCompatibleText = 'Video format not compatible',
    this.videoCannotBeLoadedSecurityPolicyText =
        'Video cannot be loaded due to security policy',
    this.playerSettingsText = 'Player Settings',
    this.autoPlayText = 'Auto Play',
    this.loopVideoText = 'Loop Video',
    this.forceHdQualityText = 'Force HD Quality',
    this.enableCaptionsText = 'Enable Captions',
    this.muteAudioText = 'Mute Audio',
    this.noQualitiesAvailableText = 'No qualities available',
    this.noSubtitlesAvailableText = 'No subtitles available',
    this.qualityText = 'Quality (Resolution)',
    this.subtitlesText = 'Subtitles',
    this.autoText = 'Auto',
    this.offText = 'Off',
  });

  /// Creates a copy with updated values
  PlayerTextConfig copyWith({
    String? invalidYoutubeUrlText,
    String? videoLoadFailedText,
    String? videoUnavailableText,
    String? videoNotCompatibleText,
    String? videoCannotBeLoadedSecurityPolicyText,
    String? playerSettingsText,
    String? autoPlayText,
    String? loopVideoText,
    String? forceHdQualityText,
    String? enableCaptionsText,
    String? muteAudioText,
    String? noQualitiesAvailableText,
    String? noSubtitlesAvailableText,
    String? qualityText,
    String? subtitlesText,
    String? autoText,
    String? offText,
  }) {
    return PlayerTextConfig(
      invalidYoutubeUrlText:
          invalidYoutubeUrlText ?? this.invalidYoutubeUrlText,
      videoLoadFailedText: videoLoadFailedText ?? this.videoLoadFailedText,
      videoUnavailableText: videoUnavailableText ?? this.videoUnavailableText,
      videoNotCompatibleText:
          videoNotCompatibleText ?? this.videoNotCompatibleText,
      videoCannotBeLoadedSecurityPolicyText:
          videoCannotBeLoadedSecurityPolicyText ??
              this.videoCannotBeLoadedSecurityPolicyText,
      playerSettingsText: playerSettingsText ?? this.playerSettingsText,
      autoPlayText: autoPlayText ?? this.autoPlayText,
      loopVideoText: loopVideoText ?? this.loopVideoText,
      forceHdQualityText: forceHdQualityText ?? this.forceHdQualityText,
      enableCaptionsText: enableCaptionsText ?? this.enableCaptionsText,
      muteAudioText: muteAudioText ?? this.muteAudioText,
      noQualitiesAvailableText:
          noQualitiesAvailableText ?? this.noQualitiesAvailableText,
      noSubtitlesAvailableText:
          noSubtitlesAvailableText ?? this.noSubtitlesAvailableText,
      qualityText: qualityText ?? this.qualityText,
      subtitlesText: subtitlesText ?? this.subtitlesText,
      autoText: autoText ?? this.autoText,
      offText: offText ?? this.offText,
    );
  }
}

/// Configuration model for YouTube player visibility settings
class PlayerVisibilityConfig {
  /// Whether to show video controls (native YouTube controls)
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

  const PlayerVisibilityConfig({
    this.showControls = true,
    this.showFullscreenButton = true,
    this.showSettingsButton = true,
    this.showAutoPlaySetting = true,
    this.showLoopSetting = true,
    this.showForceHDSetting = true,
    this.showCaptionsSetting = true,
    this.showMuteSetting = true,
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
    );
  }
}

/// Configuration model for YouTube player playback settings
class PlayerPlaybackConfig {
  /// Whether to auto-play the video
  final bool autoPlay;

  /// Whether to loop the video
  final bool loop;

  /// Whether to mute the video initially
  final bool mute;

  /// Whether to force HD quality
  final bool forceHD;

  /// Whether to enable captions
  final bool enableCaption;

  /// Whether to force the player to behave like a desktop player on mobile.
  /// This will use the WebView player instead of the native YouTube player on mobile.
  final bool forceDesktopMode;

  /// Whether to allow opening external links (like clicking the YouTube logo) in the system browser
  final bool allowExternalLinks;

  const PlayerPlaybackConfig({
    this.autoPlay = false,
    this.loop = false,
    this.mute = false,
    this.forceHD = false,
    this.enableCaption = false,
    this.forceDesktopMode = false,
    this.allowExternalLinks = true,
  });

  /// Creates a copy with updated values
  PlayerPlaybackConfig copyWith({
    bool? autoPlay,
    bool? loop,
    bool? mute,
    bool? forceHD,
    bool? enableCaption,
    bool? forceDesktopMode,
    bool? allowExternalLinks,
  }) {
    return PlayerPlaybackConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      mute: mute ?? this.mute,
      forceHD: forceHD ?? this.forceHD,
      enableCaption: enableCaption ?? this.enableCaption,
      forceDesktopMode: forceDesktopMode ?? this.forceDesktopMode,
      allowExternalLinks: allowExternalLinks ?? this.allowExternalLinks,
    );
  }
}

/// Complete configuration model for YouTube player
/// Combines all configuration aspects into one clean model
class YouTubePlayerConfig {
  final String? videoId;

  /// Styling configuration
  final PlayerStyleConfig style;

  /// Text/localization configuration
  final PlayerTextConfig text;

  /// Visibility configuration
  final PlayerVisibilityConfig visibility;

  /// Playback configuration
  final PlayerPlaybackConfig playback;

  const YouTubePlayerConfig({
    this.style = const PlayerStyleConfig(),
    this.text = const PlayerTextConfig(),
    this.visibility = const PlayerVisibilityConfig(),
    this.playback = const PlayerPlaybackConfig(),
    this.videoId,
  });

  /// Creates a copy with updated values
  YouTubePlayerConfig copyWith({
    PlayerStyleConfig? style,
    PlayerTextConfig? text,
    PlayerVisibilityConfig? visibility,
    PlayerPlaybackConfig? playback,
  }) {
    return YouTubePlayerConfig(
      style: style ?? this.style,
      text: text ?? this.text,
      visibility: visibility ?? this.visibility,
      playback: playback ?? this.playback,
    );
  }

  /// Default configuration
  static const YouTubePlayerConfig defaultConfig = YouTubePlayerConfig();
}

/// Configuration class for player bottom actions styling
class PlayerBottomActionsConfig {
  final Color progressBarPlayedColor;
  final Color progressBarHandleColor;
  final Color iconColor;
  final Color textColor;
  final TextStyle? timeTextStyle;

  const PlayerBottomActionsConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.timeTextStyle,
  });
}

class FullScreenResult {
  final Duration position;
  final bool wasPlaying;
  final bool isMuted;
  final bool autoPlay;
  final bool loop;
  final bool forceHD;
  final bool enableCaption;
  final bool videoEnded;

  FullScreenResult({
    required this.position,
    required this.wasPlaying,
    required this.isMuted,
    required this.autoPlay,
    required this.loop,
    required this.forceHD,
    required this.enableCaption,
    this.videoEnded = false,
  });
}
