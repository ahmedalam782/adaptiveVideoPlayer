import 'package:flutter/material.dart';

import '../../youtube_player/models/player_text_config.dart';
import '../utils/fullscreen_utils_export.dart';
import '../utils/video_player_web_safe.dart';
import 'pip_playback_chrome.dart';

/// Wraps the player surface with native OS Picture-in-Picture playback chrome and controls.
class NormalNativePipView extends StatelessWidget {
  final VideoPlayerController controller;
  final Widget playerView;
  final PlayerTextConfig messages;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  const NormalNativePipView({
    super.key,
    required this.controller,
    required this.playerView,
    required this.messages,
    required this.onClose,
    required this.onExpand,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final durationMs = value.duration.inMilliseconds;
        final progress = durationMs > 0
            ? (value.position.inMilliseconds / durationMs).clamp(0.0, 1.0)
            : 0.0;
        return Stack(
          fit: StackFit.expand,
          children: [
            playerView,
            PipPlaybackChrome(
              isPlaying: value.isPlaying,
              progress: progress,
              closeTooltip: messages.closeMiniPlayerText,
              expandTooltip: messages.expandPlayerText,
              playTooltip: messages.playText,
              pauseTooltip: messages.pauseText,
              onClose: onClose,
              onExpand: onExpand,
              onPlayPause: onPlayPause,
              onSeekBackward: onSeekBackward,
              onSeekForward: onSeekForward,
              onDragUpdate: (details) => moveDesktopPipWindow(
                details.delta.dx.round(),
                details.delta.dy.round(),
              ),
            ),
          ],
        );
      },
    );
  }
}
