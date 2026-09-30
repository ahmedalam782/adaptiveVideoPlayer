import 'package:flutter/material.dart';

import '../adaptive_controls.dart';
import '../utils/video_player_web_safe.dart';

/// Video display surface rendering the underlying VideoPlayer and optional closed captions.
class AdaptiveVideoSurface extends StatelessWidget {
  final VideoPlayerController controller;
  final SubtitleBuilder? subtitleBuilder;

  static final Expando<GlobalKey> _controllerKeys =
      Expando<GlobalKey>('AdaptiveVideoSurfaceKey');

  /// Returns a persistent [GlobalKey] bound to [controller] so reparenting
  /// between inline, fullscreen, and mini-player overlays never detaches
  /// the underlying platform view (especially `<video>` on Flutter Web).
  static GlobalKey keyForController(VideoPlayerController controller) {
    return _controllerKeys[controller] ??= GlobalKey();
  }

  const AdaptiveVideoSurface({
    super.key,
    required this.controller,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final aspectRatio = (value.isInitialized && value.aspectRatio > 0)
            ? value.aspectRatio
            : 16 / 9;
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(
                controller,
                key: keyForController(controller),
              ),

              // Built-in Subtitle/ClosedCaption overlay Layer
              if (subtitleBuilder != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: subtitleBuilder!(context, value.caption.text),
                ),
            ],
          ),
        );
      },
    );
  }
}
