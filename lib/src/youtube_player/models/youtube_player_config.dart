import 'package:flutter/material.dart';

import 'player_playback_config.dart';
import 'player_style_config.dart';
import 'player_text_config.dart';
import 'player_visibility_config.dart';

export 'fullscreen_result.dart';
export 'player_bottom_actions_config.dart';
export 'player_icon_config.dart';
export 'player_playback_config.dart';
export 'player_style_config.dart';
export 'player_text_config.dart';
export 'player_visibility_config.dart';

/// Builder type definitions for customizing player widgets.
typedef YouTubeLoadingBuilder = Widget Function(BuildContext context);
typedef YouTubeErrorBuilder = Widget Function(
    BuildContext context, String errorMessage);
typedef YouTubeReplayBuilder = Widget Function(
    BuildContext context, VoidCallback onRestart);
typedef YouTubeLiveBadgeBuilder = Widget Function(
  BuildContext context, {
  required bool isLive,
  String? viewerCount,
});

/// Complete configuration model for YouTube player (Composite / Facade Pattern).
/// Combines style, text, visibility, playback, and custom builders into one model.
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

  /// Optional custom builder for the loading widget
  final YouTubeLoadingBuilder? loadingBuilder;

  /// Optional custom builder for the error display
  final YouTubeErrorBuilder? errorBuilder;

  /// Optional custom builder for the replay overlay when video ends
  final YouTubeReplayBuilder? replayBuilder;

  /// Optional custom builder for the live indicator badge
  final YouTubeLiveBadgeBuilder? liveBadgeBuilder;

  const YouTubePlayerConfig({
    this.style = const PlayerStyleConfig(),
    this.text = const PlayerTextConfig(),
    this.visibility = const PlayerVisibilityConfig(),
    this.playback = const PlayerPlaybackConfig(),
    this.loadingBuilder,
    this.errorBuilder,
    this.replayBuilder,
    this.liveBadgeBuilder,
    this.videoId,
  });

  /// Creates a copy with updated values
  YouTubePlayerConfig copyWith({
    PlayerStyleConfig? style,
    PlayerTextConfig? text,
    PlayerVisibilityConfig? visibility,
    PlayerPlaybackConfig? playback,
    YouTubeLoadingBuilder? loadingBuilder,
    YouTubeErrorBuilder? errorBuilder,
    YouTubeReplayBuilder? replayBuilder,
    YouTubeLiveBadgeBuilder? liveBadgeBuilder,
    String? videoId,
  }) {
    return YouTubePlayerConfig(
      style: style ?? this.style,
      text: text ?? this.text,
      visibility: visibility ?? this.visibility,
      playback: playback ?? this.playback,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      replayBuilder: replayBuilder ?? this.replayBuilder,
      liveBadgeBuilder: liveBadgeBuilder ?? this.liveBadgeBuilder,
      videoId: videoId ?? this.videoId,
    );
  }

  /// Default configuration
  static const YouTubePlayerConfig defaultConfig = YouTubePlayerConfig();
}

/// Generic alias for [YouTubePlayerConfig]
typedef PlayerConfig = YouTubePlayerConfig;
