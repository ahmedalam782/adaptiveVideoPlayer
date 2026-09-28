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
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: styling?.iconColor ?? Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
