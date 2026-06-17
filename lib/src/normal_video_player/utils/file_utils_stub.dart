import 'video_player_web_safe.dart';

/// Checks if a file exists locally. Always returns false on Web.
bool checkFileExists(String path) {
  return false;
}

/// Returns a VideoPlayerController for a local file. Unsupported on Web.
VideoPlayerController getFileVideoController(String path) {
  throw UnsupportedError('Local file playback is not supported on Web');
}
