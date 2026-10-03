import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Fullscreen toggle button widget for the adaptive player bottom bar.
class AdaptiveFullscreenButton extends StatelessWidget {
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const AdaptiveFullscreenButton({
    super.key,
    required this.isFullScreen,
    this.styling,
    this.messages,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final tooltip = isFullScreen
        ? (messages?.exitFullscreenText ?? 'Exit Fullscreen')
        : (messages?.fullscreenText ?? 'Fullscreen');

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
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
          child: PlayerIcon.resolve(
            context,
            icon: isFullScreen
                ? styling?.icons.exitFullscreenIcon
                : styling?.icons.fullscreenIcon,
            fallbackIcon:
                isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            defaultColor: styling?.iconColor ?? Colors.white,
            defaultSize: 20,
          ),
        ),
      ),
    );
  }
}
