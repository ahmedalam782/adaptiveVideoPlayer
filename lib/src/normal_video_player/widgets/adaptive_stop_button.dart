import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/player_style_config.dart';
import 'adaptive_circle_pill_button.dart';

/// An adaptive stop button widget that pauses playback and seeks to start.
class AdaptiveStopButton extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final String? tooltip;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final Color? pillColor;

  const AdaptiveStopButton({
    super.key,
    required this.controller,
    this.styling,
    this.tooltip,
    this.onAnalyticsEvent,
    this.pillColor,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCirclePillButton(
      backgroundColor: pillColor ?? styling?.controlsBackgroundColor ?? const Color(0x8C000000),
      playerIcon: styling?.icons.stopIcon,
      icon: Icons.stop_rounded,
      tooltip: tooltip ?? PlayerStrings.stop,
      size: 20,
      onTap: () {
        controller.pause();
        controller.seekTo(Duration.zero);
        onAnalyticsEvent?.call(PlayerEvents.videoStopped, {
          PlayerEvents.paramPosition: 0,
        });
      },
    );
  }
}
