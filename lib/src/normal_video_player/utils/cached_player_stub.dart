import 'video_player_web_safe.dart';

/// Creates an initialized VideoPlayerController backed by CachedVideoPlayerPlus.
///
/// Returns null on Web where CachedVideoPlayerPlus is unsupported, allowing
/// fallback to standard VideoPlayerController.
Future<VideoPlayerController?> createCachedVideoController(
  Uri uri, {
  VideoPlayerOptions? videoPlayerOptions,
}) async {
  return null;
}

/// Clears the video disk cache. No-op on Web.
Future<void> clearVideoDiskCache() async {}
