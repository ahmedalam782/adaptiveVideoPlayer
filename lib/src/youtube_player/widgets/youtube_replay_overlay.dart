import 'package:flutter/material.dart';

import '../models/player_icon_config.dart';

/// Replay overlay widget displayed when video playback ends.
class YouTubeReplayOverlay extends StatelessWidget {
  final VoidCallback onRestart;
  final Color iconColor;
  final double iconSize;
  final PlayerIcon? replayIcon;

  const YouTubeReplayOverlay({
    super.key,
    required this.onRestart,
    required this.iconColor,
    this.iconSize = 48,
    this.replayIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onRestart,
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(iconSize * 0.33),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: PlayerIcon.resolve(
                context,
                icon: replayIcon,
                fallbackIcon: Icons.replay,
                defaultColor: iconColor,
                defaultSize: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
