import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/player_settings_config.dart';
import '../widgets/player_settings_helper.dart';

export '../models/player_settings_config.dart';

/// Utility functions for YouTube player operations, URL parsing, and platform system UI.
class PlayerUtils {
  const PlayerUtils._();

  /// Checks if the URL is a YouTube video or a YouTube video ID.
  ///
  /// [url] - URL or video ID to check.
  ///
  /// Returns true if it's a valid YouTube URL or video ID.
  static bool isYouTubeUrl(String url) {
    final lowerUrl = url.toLowerCase().trim();
    if (lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('youtube-nocookie.com')) {
      return true;
    }
    // Check if it's a YouTube video ID (11 characters, alphanumeric with dashes/underscores)
    if (url.trim().length == 11 &&
        !url.contains('/') &&
        !url.contains('.') &&
        RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) {
      return true;
    }
    return false;
  }

  /// Extracts the 11-character video ID from a YouTube URL or string using pure Dart regex.
  ///
  /// [url] - YouTube URL or video ID.
  ///
  /// Returns video ID or null if invalid.
  static String? extractVideoId(String url) {
    try {
      final trimmed = url.trim();
      if (trimmed.isEmpty) return null;

      // Already an 11-character video ID
      if (trimmed.length == 11 &&
          !trimmed.contains('/') &&
          !trimmed.contains('.') &&
          !trimmed.contains('?') &&
          !trimmed.contains('&') &&
          RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
        return trimmed;
      }

      // Regex matching all common YouTube URL formats:
      // - youtube.com/watch?v=ID
      // - youtu.be/ID
      // - youtube.com/embed/ID
      // - youtube.com/v/ID
      // - youtube.com/shorts/ID
      // - m.youtube.com/...
      final regExp = RegExp(
        r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(trimmed);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }

      // Fallback query parameter parser if needed
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.queryParameters.containsKey('v')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.length == 11) return v;
      }

      return null;
    } catch (e) {
      debugPrint('Extract video ID error: $e');
      return null;
    }
  }

  /// Shows the player settings bottom sheet.
  static Future<void> showSettings({
    required BuildContext context,
    required PlayerSettingsConfig config,
    required Future<void> Function(bool) onAutoPlayChanged,
    required Future<void> Function(bool) onLoopChanged,
    required Future<void> Function(bool) onForceHDChanged,
    required Future<void> Function(bool) onEnableCaptionChanged,
    required void Function(bool) onMutedChanged,
  }) {
    return showPlayerSettingsSheet(
      context: context,
      autoPlay: config.autoPlay,
      loop: config.loop,
      forceHD: config.forceHD,
      enableCaption: config.enableCaption,
      isMuted: config.isMuted,
      settingsBackgroundColor: config.settingsBackgroundColor,
      settingItemBackgroundColor: config.settingItemBackgroundColor,
      iconColor: config.iconColor,
      textColor: config.textColor,
      switchInactiveThumbColor: config.switchInactiveThumbColor,
      switchInactiveTrackColor: config.switchInactiveTrackColor,
      titleTextStyle: config.settingsTitleStyle,
      itemTextStyle: config.settingItemTextStyle,
      textDirection: config.textDirection,
      playerSettingsText: config.playerSettingsText,
      autoPlayText: config.autoPlayText,
      loopVideoText: config.loopVideoText,
      forceHdQualityText: config.forceHdQualityText,
      enableCaptionsText: config.enableCaptionsText,
      muteAudioText: config.muteAudioText,
      showAutoPlaySetting: config.showAutoPlaySetting,
      showLoopSetting: config.showLoopSetting,
      showForceHDSetting: config.showForceHDSetting,
      showCaptionsSetting: config.showCaptionsSetting,
      showMuteSetting: config.showMuteSetting,
      onAutoPlayChanged: onAutoPlayChanged,
      onLoopChanged: onLoopChanged,
      onForceHDChanged: onForceHDChanged,
      onEnableCaptionChanged: onEnableCaptionChanged,
      onMutedChanged: onMutedChanged,
    );
  }

  /// Hides system UI for immersive fullscreen experience.
  static Future<void> hideSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
  }

  /// Shows system UI when exiting fullscreen.
  static Future<void> showSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Sets device orientation to landscape for fullscreen.
  static Future<void> setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sets device orientation to portrait for normal mode.
  static Future<void> setPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  /// Sets all orientations (allows both portrait and landscape).
  static Future<void> setAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
