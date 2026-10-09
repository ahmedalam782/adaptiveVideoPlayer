import 'package:flutter/material.dart';

import '../../normal_video_player/widgets/adaptive_circular_percentage_loader.dart';

/// Loading indicator widget for YouTube player.
class PlayerLoadingWidget extends StatelessWidget {
  final Color loadingIndicatorColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double? size;
  final Widget Function(BuildContext context)? builder;
  final double? progress;
  final bool showPercentage;
  final TextStyle? textStyle;

  const PlayerLoadingWidget({
    super.key,
    required this.loadingIndicatorColor,
    required this.backgroundColor,
    this.strokeWidth = 4.0,
    this.size,
    this.builder,
    this.progress,
    this.showPercentage = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: AdaptiveCircularPercentageLoader(
              color: loadingIndicatorColor,
              strokeWidth: strokeWidth,
              size: size,
              progress: progress,
              showPercentage: showPercentage,
              textStyle: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

