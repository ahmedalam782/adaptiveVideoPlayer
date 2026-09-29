import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Fullscreen toggle button widget for the adaptive player bottom bar.
class AdaptiveFullscreenButton extends StatelessWidget {
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const AdaptiveFullscreenButton({
    super.key,
    required this.isFullScreen,
    this.styling,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isFullScreen) {
          onExitFullscreen?.call();
        } else {
          onEnterFullscreen?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: styling?.iconColor ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
