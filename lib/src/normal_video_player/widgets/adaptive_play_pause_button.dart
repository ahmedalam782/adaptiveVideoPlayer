import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import 'adaptive_circle_pill_button.dart';

/// An adaptive play/pause button widget for the video player bottom bar.
class AdaptivePlayPauseButton extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final Color? pillColor;

  const AdaptivePlayPauseButton({
    super.key,
    required this.controller,
    required this.isPlaying,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
    this.pillColor,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCirclePillButton(
      backgroundColor: pillColor ?? styling?.controlsBackgroundColor ?? const Color(0x8C000000),
      playerIcon: isPlaying ? styling?.icons.pauseIcon : styling?.icons.playIcon,
      icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
      tooltip: isPlaying
          ? (messages?.pauseText ?? PlayerStrings.pause)
          : (messages?.playText ?? PlayerStrings.play),
      size: 22,
      onTap: () {
        if (isPlaying) {
          controller.pause();
          onAnalyticsEvent?.call(PlayerEvents.videoPaused, {
            PlayerEvents.paramPosition: controller.value.position.inSeconds,
          });
        } else {
          final pos = controller.value.position;
          final dur = controller.value.duration;
          if (pos >= dur && dur > Duration.zero) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
          onAnalyticsEvent?.call(PlayerEvents.videoPlayed, {
            PlayerEvents.paramPosition: controller.value.position.inSeconds,
          });
        }
      },
    );
  }
}
