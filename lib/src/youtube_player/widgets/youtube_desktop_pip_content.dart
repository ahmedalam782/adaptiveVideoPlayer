import 'package:flutter/material.dart';

import '../../core/constants/player_strings.dart';
import '../../normal_video_player/widgets/pip_playback_chrome.dart';

/// Presentation widget for YouTube desktop Picture-in-Picture window content.
class YouTubeDesktopPipContent extends StatelessWidget {
  final bool isOsPipWindow;
  final Widget child;
  final bool isPlaying;
  final double progress;
  final String closeTooltip;
  final String expandTooltip;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final VoidCallback onPlayPause;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;
  final GestureDragUpdateCallback? onDragUpdate;

  const YouTubeDesktopPipContent({
    super.key,
    required this.isOsPipWindow,
    required this.child,
    required this.isPlaying,
    required this.progress,
    this.closeTooltip = PlayerStrings.closeMiniPlayer,
    this.expandTooltip = PlayerStrings.expand,
    required this.onClose,
    required this.onExpand,
    required this.onPlayPause,
    this.onSeekBackward,
    this.onSeekForward,
    this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      elevation: isOsPipWindow ? 0 : 14,
      borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: isOsPipWindow ? double.infinity : 300,
        height: isOsPipWindow ? double.infinity : 170,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
          border: isOsPipWindow
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            PipPlaybackChrome(
              isPlaying: isPlaying,
              progress: progress,
              closeTooltip: closeTooltip,
              expandTooltip: expandTooltip,
              onClose: onClose,
              onExpand: onExpand,
              onPlayPause: onPlayPause,
              onSeekBackward: onSeekBackward,
              onSeekForward: onSeekForward,
              onDragUpdate: onDragUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
