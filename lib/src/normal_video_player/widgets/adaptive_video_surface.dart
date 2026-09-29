import 'package:flutter/material.dart';

import '../adaptive_controls.dart';
import '../utils/video_player_web_safe.dart';

/// Video display surface rendering the underlying VideoPlayer and optional closed captions.
class AdaptiveVideoSurface extends StatelessWidget {
  final VideoPlayerController controller;
  final SubtitleBuilder? subtitleBuilder;

  const AdaptiveVideoSurface({
    super.key,
    required this.controller,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(
            controller,
            key: ValueKey(controller),
          ),

          // Built-in Subtitle/ClosedCaption overlay Layer
          if (subtitleBuilder != null)
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, VideoPlayerValue value, child) {
                return subtitleBuilder!(context, value.caption.text);
              },
            ),
        ],
      ),
    );
  }
}
