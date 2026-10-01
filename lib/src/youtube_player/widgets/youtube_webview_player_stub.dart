import 'package:flutter/material.dart';
import '../models/youtube_player_config.dart';

/// Stub for YouTubeWebViewPlayer — used on Web where dart:io is not available.
/// On Web, YouTube is handled via HTML iframe, so this widget is never actually used.
class YouTubeWebViewPlayer extends StatefulWidget {
  final String videoId;
  final YouTubePlayerConfig config;
  final int startAt;
  final bool? autoPlay;
  final VoidCallback? onEnded;
  final VoidCallback? onReady;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onSeekForward;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onTouchActivity;
  final ValueChanged<int>? onPositionUpdate;
  final ValueChanged<bool>? onPlayingStateChanged;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    required this.config,
    this.startAt = 0,
    this.autoPlay,
    this.onEnded,
    this.onReady,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onSeekForward,
    this.onSeekBackward,
    this.onToggleFullscreen,
    this.onTouchActivity,
    this.onPositionUpdate,
    this.onPlayingStateChanged,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => YouTubeWebViewPlayerState();
}

class YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  int currentPosition = 0;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void play() {}
  void pause() {}
  void seekTo(int seconds) {}
  void mute() {}
  void unMute() {}
  void exitFullscreen() {}
  Future<int?> getCurrentTime() async => currentPosition;
  Future<bool> isPlaying() async => true;
}
