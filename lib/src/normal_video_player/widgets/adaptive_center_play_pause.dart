import 'package:flutter/material.dart';
import '../../core/constants/player_events.dart';
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
        final buttonSize = isFullScreen ? 72.0 : 60.0;
        final iconSize = isFullScreen ? 36.0 : 30.0;
        final buttonColor = styling?.centerButtonColor ?? Colors.white;
        final glyphColor = styling?.centerIconColor ?? const Color(0xFF1E88E5);

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (isPlaying) {
                controller.pause();
                onAnalyticsEvent?.call(PlayerEvents.videoPaused,
                    {PlayerEvents.paramPosition: controller.value.position.inSeconds});
              } else {
                if (value.position >= value.duration &&
                    value.duration > Duration.zero) {
                  controller.seekTo(Duration.zero);
                }
                controller.play();
                onAnalyticsEvent?.call(PlayerEvents.videoPlayed,
                    {PlayerEvents.paramPosition: controller.value.position.inSeconds});
              }
              onPlayPause?.call();
            },
            child: Ink(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PlayerIcon.resolve(
                  context,
                  icon: isPlaying
                      ? styling?.icons.pauseIcon
                      : styling?.icons.playIcon,
                  fallbackIcon: isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  defaultColor: glyphColor,
                  defaultSize: iconSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
