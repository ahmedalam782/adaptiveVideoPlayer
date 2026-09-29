import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../normal_video_player/models/video_config.dart';
import '../../normal_video_player/utils/file_utils_export.dart';
import '../../normal_video_player/utils/video_player_web_safe.dart';
import '../../youtube_player/utils/player_utils.dart';
import '../adapters/native_player_adapter.dart';
import '../adapters/youtube_player_adapter.dart';
import '../contracts/i_video_player_controller.dart';

/// Strategy definition for creating an [IVideoPlayerController] (Strategy & Factory Pattern).
typedef PlayerStrategy = IVideoPlayerController Function(VideoConfig config);

/// Factory for instantiating the appropriate [IVideoPlayerController] strategy (OCP & Factory Pattern).
class PlayerControllerFactory {
  static final Map<String, PlayerStrategy> _customStrategies = {};

  /// Register a custom player strategy (OCP)
  static void registerStrategy(String scheme, PlayerStrategy strategy) {
    _customStrategies[scheme] = strategy;
  }

  /// Remove a custom strategy
  static void unregisterStrategy(String scheme) {
    _customStrategies.remove(scheme);
  }

  /// Resolve and construct an [IVideoPlayerController] instance based on the [VideoConfig]
  static IVideoPlayerController create(VideoConfig config) {
    // Check if any registered custom strategy matches
    for (final entry in _customStrategies.entries) {
      if (config.videoUrl.startsWith(entry.key)) {
        return entry.value(config);
      }
    }

    // 1. YouTube strategy
    final youtubeId = PlayerUtils.extractVideoId(config.videoUrl);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      return YouTubePlayerAdapter(
        videoId: youtubeId,
        config: config.playerConfig,
        isLiveStream: config.isLive,
        viewerCount: config.viewerCount,
      );
    }

    // 2. Native / Direct video strategy
    VideoPlayerController rawController;
    if (config.videoBytes != null && config.videoBytes!.isNotEmpty) {
      final base64Video =
          'data:video/mp4;base64,${base64Encode(config.videoBytes!)}';
      rawController = VideoPlayerController.networkUrl(Uri.parse(base64Video));
    } else if (config.isFile && !kIsWeb) {
      rawController = getFileVideoController(config.videoUrl);
    } else if (config.videoUrl.startsWith('assets/')) {
      rawController = VideoPlayerController.asset(config.videoUrl);
    } else {
      final isHls = config.videoUrl.contains('.m3u8');
      final formatHint = isHls ? VideoFormat.hls : null;
      rawController = VideoPlayerController.networkUrl(
        Uri.parse(config.videoUrl),
        formatHint: formatHint,
      );
    }

    return NativePlayerAdapter(
      controller: rawController,
      qualities: config.qualities,
      initialQuality: config.initialQuality,
      subtitles: config.subtitles,
      initialSubtitle: config.initialSubtitle,
      isLive: config.isLive,
    );
  }
}
