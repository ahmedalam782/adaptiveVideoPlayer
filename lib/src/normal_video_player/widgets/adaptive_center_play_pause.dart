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

  const AdaptiveCenterPlayPause({
    super.key,
    required this.controller,
    this.styling,
    this.onAnalyticsEvent,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final isPlaying = value.isPlaying;
        final iconSize = isFullScreen ? 38.0 : 26.0;
        final padding = isFullScreen
            ? const EdgeInsets.all(14)
            : const EdgeInsets.all(10);
        final blurSigma = isFullScreen ? 12.0 : 8.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isPlaying) {
              controller.pause();
              onAnalyticsEvent?.call('video_paused',
                  {'position': controller.value.position.inSeconds});
            } else {
              controller.play();
              onAnalyticsEvent?.call('video_played',
                  {'position': controller.value.position.inSeconds});
            }
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
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
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: styling?.iconColor ?? Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
