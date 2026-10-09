import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../adaptive_controls.dart';
import '../utils/video_player_web_safe.dart';

/// Video display surface rendering the underlying VideoPlayer and optional closed captions.
class AdaptiveVideoSurface extends StatelessWidget {
  final VideoPlayerController controller;
  final SubtitleBuilder? subtitleBuilder;
  final BoxFit fit;

  static final Expando<GlobalKey> _controllerKeys =
      Expando<GlobalKey>('AdaptiveVideoSurfaceKey');

  /// Returns a persistent [GlobalKey] bound to [controller] on Flutter Web so reparenting
  /// between inline, fullscreen, and mini-player overlays never detaches
  /// the underlying HTML `<video>` DOM element.
  /// On mobile/desktop (Android, iOS, Windows, macOS, Linux), returns null so
  /// Flutter manages the native Texture/Surface without surface detachment or black screens.
  static GlobalKey? keyForController(VideoPlayerController controller) {
    if (!kIsWeb) return null;
    return _controllerKeys[controller] ??= GlobalKey();
  }

  const AdaptiveVideoSurface({
    super.key,
    required this.controller,
    this.subtitleBuilder,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      key: ValueKey(controller),
      valueListenable: controller,
      builder: (context, value, _) {
        final aspectRatio = (value.isInitialized &&
                value.aspectRatio > 0 &&
                !value.size.isEmpty &&
                value.size.width > 0 &&
                value.size.height > 0)
            ? value.aspectRatio
            : 16 / 9;

        Widget videoWidget = VideoPlayer(
          controller,
          key: keyForController(controller),
        );

        if (fit == BoxFit.cover) {
          final width = value.size.width > 0 ? value.size.width : 1600.0;
          final height = value.size.height > 0 ? value.size.height : 900.0;
          videoWidget = SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: width,
                height: height,
                child: videoWidget,
              ),
            ),
          );
        } else if (fit == BoxFit.fill) {
          videoWidget = SizedBox.expand(child: videoWidget);
        } else {
          videoWidget = AspectRatio(
            aspectRatio: aspectRatio,
            child: videoWidget,
          );
        }

        final stackContent = Stack(
          fit: (fit == BoxFit.cover || fit == BoxFit.fill)
              ? StackFit.expand
              : StackFit.loose,
          alignment: Alignment.bottomCenter,
          children: [
            videoWidget,

            // Built-in Subtitle/ClosedCaption overlay Layer
            if (subtitleBuilder != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: subtitleBuilder!(context, value.caption.text),
              ),
          ],
        );

        if (fit == BoxFit.cover || fit == BoxFit.fill) {
          return SizedBox.expand(child: stackContent);
        }
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: stackContent,
        );
      },
    );
  }
}
