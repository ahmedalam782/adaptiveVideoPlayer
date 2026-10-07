import 'package:flutter/material.dart';

import '../../core/constants/player_strings.dart';
import 'pip_circle_button.dart';

/// YouTube-style controls drawn over a picture-in-picture window.
class PipPlaybackChrome extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final VoidCallback onPlayPause;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;
  final GestureDragUpdateCallback? onDragUpdate;
  final String closeTooltip;
  final String expandTooltip;
  final String playTooltip;
  final String pauseTooltip;

  const PipPlaybackChrome({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.onClose,
    required this.onExpand,
    required this.onPlayPause,
    this.onSeekBackward,
    this.onSeekForward,
    this.onDragUpdate,
    this.closeTooltip = PlayerStrings.close,
    this.expandTooltip = PlayerStrings.expand,
    this.playTooltip = PlayerStrings.play,
    this.pauseTooltip = PlayerStrings.pause,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 150;
          final side = compact ? 32.0 : 40.0;
          final skip = compact ? 40.0 : 52.0;
          final play = compact ? 52.0 : 68.0;

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: onDragUpdate == null
                ? null
                : (event) {
                    if (event.buttons == 0) return;
                    onDragUpdate!(
                      DragUpdateDetails(
                        globalPosition: event.position,
                        localPosition: event.localPosition,
                        delta: event.delta,
                        sourceTimeStamp: event.timeStamp,
                      ),
                    );
                  },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 8 : 12,
                compact ? 6 : 10,
                compact ? 8 : 12,
                compact ? 8 : 12,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PipCircleButton(
                        icon: Icons.close_rounded,
                        tooltip: closeTooltip,
                        onTap: onClose,
                        size: side,
                        iconSize: compact ? 16 : 20,
                      ),
                      PipCircleButton(
                        icon: Icons.picture_in_picture_alt_rounded,
                        tooltip: expandTooltip,
                        onTap: onExpand,
                        size: side,
                        iconSize: compact ? 16 : 18,
                      ),
                    ],
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onPlayPause,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PipCircleButton(
                            icon: Icons.replay_10_rounded,
                            tooltip: PlayerStrings.back10Seconds,
                            onTap: onSeekBackward,
                            size: skip,
                            iconSize: compact ? 20 : 26,
                          ),
                          SizedBox(width: compact ? 12 : 22),
                          PipCircleButton(
                            icon: isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            tooltip: isPlaying ? pauseTooltip : playTooltip,
                            onTap: onPlayPause,
                            size: play,
                            iconSize: compact ? 28 : 36,
                          ),
                          SizedBox(width: compact ? 12 : 22),
                          PipCircleButton(
                            icon: Icons.forward_10_rounded,
                            tooltip: PlayerStrings.forward10Seconds,
                            onTap: onSeekForward,
                            size: skip,
                            iconSize: compact ? 20 : 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: compact ? 3 : 4,
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF3A3A3A),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
