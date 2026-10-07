import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/player_text_config.dart';
import 'adaptive_video_surface.dart';
import 'pip_playback_chrome.dart';

/// Presentation widget rendering the contents of a native mini player overlay.
class NormalMiniPlayerContent extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isOsPipWindow;
  final PlayerTextConfig? messages;
  final bool controlsVisible;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final void Function(int seconds) onSeekBy;
  final ValueChanged<Offset>? onDragDelta;

  const NormalMiniPlayerContent({
    super.key,
    required this.controller,
    required this.isOsPipWindow,
    this.messages,
    this.controlsVisible = true,
    required this.onClose,
    required this.onExpand,
    required this.onSeekBy,
    this.onDragDelta,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 360.0;
    final miniWidth = isOsPipWindow
        ? double.infinity
        : (screenWidth < 600
            ? (screenWidth * 0.58).clamp(190.0, 240.0)
            : 280.0);
    final miniHeight = isOsPipWindow ? double.infinity : (miniWidth * 9 / 16);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (event.buttons == 0) return;
        onDragDelta?.call(event.delta);
      },
      child: Material(
        color: Colors.transparent,
        elevation: isOsPipWindow ? 0 : 14,
        borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: miniWidth,
          height: miniHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
            border: isOsPipWindow
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
          ),
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, _) {
              final durationMs = value.duration.inMilliseconds.toDouble();
              final positionMs = value.position.inMilliseconds.toDouble();
              final progress = durationMs > 0
                  ? (positionMs / durationMs).clamp(0.0, 1.0)
                  : 0.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                          (value.isInitialized && value.aspectRatio > 0)
                              ? value.aspectRatio
                              : 16 / 9,
                      child: VideoPlayer(
                        controller,
                        key: AdaptiveVideoSurface.keyForController(controller),
                      ),
                    ),
                  ),
                  if (controlsVisible)
                    PipPlaybackChrome(
                      isPlaying: value.isPlaying,
                      progress: progress,
                      closeTooltip: messages?.closeMiniPlayerText ??
                          PlayerStrings.closeMiniPlayer,
                      expandTooltip: messages?.expandPlayerText ??
                          PlayerStrings.expand,
                      playTooltip: messages?.playText ?? PlayerStrings.play,
                      pauseTooltip: messages?.pauseText ?? PlayerStrings.pause,
                      onClose: onClose,
                      onExpand: onExpand,
                      onPlayPause: () {
                        if (value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
                      onSeekBackward: () => onSeekBy(-10),
                      onSeekForward: () => onSeekBy(10),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
