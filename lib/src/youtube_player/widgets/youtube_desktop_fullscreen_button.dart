import 'package:flutter/material.dart';

/// Fullscreen toggle button for YouTube desktop player overlay.
class YouTubeDesktopFullscreenButton extends StatelessWidget {
  final bool isFullScreenMode;
  final VoidCallback onTap;

  const YouTubeDesktopFullscreenButton({
    super.key,
    required this.isFullScreenMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            isFullScreenMode ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
