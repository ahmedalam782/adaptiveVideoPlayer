import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_circular_percentage_loader.dart';

/// Loading indicator widget for normal video player.
class NormalPlayerLoadingWidget extends StatelessWidget {
  final PlayerStyleConfig? styling;
  final Widget Function(BuildContext context)? customBuilder;
  final double? progress;
  final VideoPlayerController? controller;

  const NormalPlayerLoadingWidget({
    super.key,
    this.styling,
    this.customBuilder,
    this.progress,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final builder = customBuilder ?? styling?.loadingIndicatorBuilder;
    if (builder != null) {
      return builder(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: styling?.backgroundColor ?? Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: AdaptiveCircularPercentageLoader(
            progress: progress,
            controller: controller,
            styling: styling,
          ),
        ),
      ),
    );
  }
}

