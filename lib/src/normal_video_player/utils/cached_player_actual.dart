import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'video_player_web_safe.dart';

/// Creates an initialized VideoPlayerController backed by CachedVideoPlayerPlus.
Future<VideoPlayerController?> createCachedVideoController(
  Uri uri, {
  VideoPlayerOptions? videoPlayerOptions,
}) async {
  final cachedPlayer = CachedVideoPlayerPlus.networkUrl(
    uri,
    videoPlayerOptions: videoPlayerOptions,
  );
  await cachedPlayer.initialize();
  return cachedPlayer.controller;
}

/// Clears the video disk cache using CachedVideoPlayerPlus.cacheManager.
Future<void> clearVideoDiskCache() async {
  await CachedVideoPlayerPlus.cacheManager.emptyCache();
}
