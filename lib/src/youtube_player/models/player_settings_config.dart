import 'package:flutter/material.dart';

/// Configuration class for player settings bottom sheet.
class PlayerSettingsConfig {
  final bool autoPlay;
  final bool loop;
  final bool forceHD;
  final bool enableCaption;
  final bool isMuted;

  // Visibility settings
  final bool showAutoPlaySetting;
  final bool showLoopSetting;
  final bool showForceHDSetting;
  final bool showCaptionsSetting;
  final bool showMuteSetting;

  // Colors
  final Color settingsBackgroundColor;
  final Color settingItemBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color? switchInactiveThumbColor;
  final Color? switchInactiveTrackColor;

  // Text customization
  final String playerSettingsText;
  final String autoPlayText;
  final String loopVideoText;
  final String forceHdQualityText;
  final String enableCaptionsText;
  final String muteAudioText;

  // Text styles
  final TextStyle? settingsTitleStyle;
  final TextStyle? settingItemTextStyle;
  final TextDirection? textDirection;

  const PlayerSettingsConfig({
    required this.autoPlay,
    required this.loop,
    required this.forceHD,
    required this.enableCaption,
    required this.isMuted,
    this.showAutoPlaySetting = true,
    this.showLoopSetting = true,
    this.showForceHDSetting = true,
    this.showCaptionsSetting = true,
    this.showMuteSetting = true,
    this.settingsBackgroundColor = const Color(0xFF1D1D1D),
    this.settingItemBackgroundColor = const Color(0xFF0D0D0D),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.switchInactiveThumbColor,
    this.switchInactiveTrackColor,
    this.playerSettingsText = 'Player Settings',
    this.autoPlayText = 'Auto Play',
    this.loopVideoText = 'Loop Video',
    this.forceHdQualityText = 'Force HD Quality',
    this.enableCaptionsText = 'Enable Captions',
    this.muteAudioText = 'Mute Audio',
    this.settingsTitleStyle,
    this.settingItemTextStyle,
    this.textDirection,
  });

  /// Creates a copy with updated values
  PlayerSettingsConfig copyWith({
    bool? autoPlay,
    bool? loop,
    bool? forceHD,
    bool? enableCaption,
    bool? isMuted,
    TextDirection? textDirection,
  }) {
    return PlayerSettingsConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      forceHD: forceHD ?? this.forceHD,
      enableCaption: enableCaption ?? this.enableCaption,
      isMuted: isMuted ?? this.isMuted,
      showAutoPlaySetting: showAutoPlaySetting,
      showLoopSetting: showLoopSetting,
      showForceHDSetting: showForceHDSetting,
      showCaptionsSetting: showCaptionsSetting,
      showMuteSetting: showMuteSetting,
      settingsBackgroundColor: settingsBackgroundColor,
      settingItemBackgroundColor: settingItemBackgroundColor,
      iconColor: iconColor,
      textColor: textColor,
      switchInactiveThumbColor: switchInactiveThumbColor,
      switchInactiveTrackColor: switchInactiveTrackColor,
      playerSettingsText: playerSettingsText,
      autoPlayText: autoPlayText,
      loopVideoText: loopVideoText,
      forceHdQualityText: forceHdQualityText,
      enableCaptionsText: enableCaptionsText,
      muteAudioText: muteAudioText,
      settingsTitleStyle: settingsTitleStyle,
      settingItemTextStyle: settingItemTextStyle,
      textDirection: textDirection ?? this.textDirection,
    );
  }
}
