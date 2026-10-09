import 'dart:async';

import '../../normal_video_player/models/video_file_extension.dart';
import '../../normal_video_player/utils/video_player_web_safe.dart';

/// Pre-buffering service that warms up video streams in the background
/// to deliver instant (0ms startup latency) video playback.
class AdaptiveVideoPreloader {
  AdaptiveVideoPreloader._();

  static final Map<String, VideoPlayerController> _cache = {};
  static final Map<String, Future<VideoPlayerController?>> _inProgress = {};

  /// Preloads a video by URL in the background.
  ///
  /// Initializes the video pipeline and caches the ready [VideoPlayerController]
  /// in memory. When the player opens this URL, it consumes the pre-warmed controller
  /// immediately without any loading spinner.
  static Future<VideoPlayerController?> preload(
    String url, {
    VideoFileExtension? extension,
    int maxCached = 4,
  }) async {
    if (url.isEmpty ||
        (!url.startsWith('http://') &&
            !url.startsWith('https://') &&
            !url.startsWith('asset://'))) {
      return null;
    }

    // Already cached and initialized
    if (_cache.containsKey(url)) {
      final existing = _cache[url]!;
      if (existing.value.isInitialized) {
        return existing;
      }
    }

    // In-flight initialization
    if (_inProgress.containsKey(url)) {
      return _inProgress[url];
    }

    final completer = Completer<VideoPlayerController?>();
    _inProgress[url] = completer.future;

    try {
      final isHls =
          extension == VideoFileExtension.hls || url.contains('.m3u8');
      final isDash =
          extension == VideoFileExtension.dash || url.contains('.mpd');
      final formatHint = isHls
          ? VideoFormat.hls
          : isDash
              ? VideoFormat.dash
              : null;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        formatHint: formatHint,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
          mixWithOthers: true,
        ),
      );

      await controller.initialize();

      // Evict oldest entry if exceeding cache capacity
      if (_cache.length >= maxCached) {
        final oldestKey = _cache.keys.first;
        final old = _cache.remove(oldestKey);
        try {
          await old?.dispose();
        } catch (_) {}
      }

      _cache[url] = controller;
      completer.complete(controller);
      return controller;
    } catch (e) {
      completer.complete(null);
      return null;
    } finally {
      _inProgress.remove(url);
    }
  }

  /// Takes and removes a pre-warmed controller from the cache, transferring
  /// ownership to the calling player widget.
  static VideoPlayerController? take(String url) {
    return _cache.remove(url);
  }

  /// Checks if a warmed controller is cached and ready for the given [url].
  static bool isPreloaded(String url) {
    final c = _cache[url];
    return c != null && c.value.isInitialized;
  }

  /// Disposes and clears all preloaded video controllers from memory.
  static Future<void> disposeAll() async {
    for (final controller in _cache.values) {
      try {
        await controller.dispose();
      } catch (_) {}
    }
    _cache.clear();
    _inProgress.clear();
  }
}
