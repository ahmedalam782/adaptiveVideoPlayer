import 'dart:io';
import 'video_player_web_safe.dart';

/// Checks if a file exists locally.
bool checkFileExists(String path) {
  return File(path).existsSync();
}

/// Returns a VideoPlayerController for a local file.
VideoPlayerController getFileVideoController(String path) {
  return VideoPlayerController.file(
    File(path),
    videoPlayerOptions: VideoPlayerOptions(
      allowBackgroundPlayback: true,
      mixWithOthers: true,
    ),
  );
}
