import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Center play/pause button overlay with smooth state transitions.
class AdaptiveCenterPlayPause extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  const AdaptiveCenterPlayPause({
    super.key,
    required this.controller,
    this.styling,
    this.onAnalyticsEvent,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final isPlaying = value.isPlaying;
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: styling?.iconColor ?? Colors.white,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}
