import 'dart:ui';
import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Center play/pause button overlay with smooth state transitions and modern glassmorphic aesthetic.
class AdaptiveCenterPlayPause extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final bool isFullScreen;
  final VoidCallback? onPlayPause;

  const AdaptiveCenterPlayPause({
    super.key,
    required this.controller,
    this.styling,
    this.onAnalyticsEvent,
    this.isFullScreen = false,
    this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final isPlaying = value.isPlaying;
        final buttonSize = isFullScreen ? 64.0 : 52.0;
        final iconSize = isFullScreen ? 38.0 : 30.0;
        final blurSigma = isFullScreen ? 12.0 : 8.0;

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (isPlaying) {
                controller.pause();
                onAnalyticsEvent?.call('video_paused',
                    {'position': controller.value.position.inSeconds});
              } else {
                if (value.position >= value.duration &&
                    value.duration > Duration.zero) {
                  controller.seekTo(Duration.zero);
                }
                controller.play();
                onAnalyticsEvent?.call('video_played',
                    {'position': controller.value.position.inSeconds});
              }
              onPlayPause?.call();
            },
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: isFullScreen ? 24 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(isPlaying ? 0.0 : 2.0, 0.0),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: styling?.iconColor ?? Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
