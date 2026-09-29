import 'package:flutter/material.dart';

/// Replay overlay widget displayed when video playback ends.
class YouTubeReplayOverlay extends StatelessWidget {
  final VoidCallback onRestart;
  final Color iconColor;
  final double iconSize;

  const YouTubeReplayOverlay({
    super.key,
    required this.onRestart,
    required this.iconColor,
    this.iconSize = 48,
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
              child: Icon(
                Icons.replay,
                color: iconColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
