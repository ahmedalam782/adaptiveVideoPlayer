import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Buffering loading indicator overlay shown while the player is loading or buffering.
class AdaptiveBufferingIndicator extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;

  const AdaptiveBufferingIndicator({
    super.key,
    required this.controller,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        if (value.isBuffering &&
            (value.isPlaying || value.position == Duration.zero)) {
          if (styling?.loadingIndicatorBuilder != null) {
            return Center(child: styling!.loadingIndicatorBuilder!(context));
          }
          final indicatorSize = styling?.loadingIndicatorSize;
          Widget indicator = CircularProgressIndicator(
            color: styling?.loadingIndicatorColor ??
                const Color.fromRGBO(255, 0, 0, 0.7),
            strokeWidth: styling?.loadingIndicatorStrokeWidth ?? 4.0,
            strokeCap: StrokeCap.round,
          );
          if (indicatorSize != null) {
            indicator = SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: indicator,
            );
          }
          return Center(child: indicator);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
