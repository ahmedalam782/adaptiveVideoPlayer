import 'package:flutter/material.dart';

/// Seek button widget used in both normal and fullscreen player
class SeekButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const SeekButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

/// Seek buttons overlay that shows -10s and +10s buttons
class SeekButtonsOverlay extends StatelessWidget {
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  const SeekButtonsOverlay({
    super.key,
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SeekButton(icon: Icons.forward_10, onTap: onSeekForward, size: 35),
          SeekButton(icon: Icons.replay_10, onTap: onSeekBackward, size: 35),
        ],
      ),
    );
  }
}

/// Loading widget for YouTube player
class PlayerLoadingWidget extends StatelessWidget {
  final Color loadingIndicatorColor;
  final Color backgroundColor;

  const PlayerLoadingWidget({
    super.key,
    required this.loadingIndicatorColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              color: loadingIndicatorColor,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}

/// Error widget for YouTube player
class PlayerErrorWidget extends StatelessWidget {
  final String errorMessage;
  final Color errorIconColor;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? errorTextStyle;

  const PlayerErrorWidget({
    super.key,
    required this.errorMessage,
    required this.errorIconColor,
    required this.backgroundColor,
    required this.textColor,
    this.errorTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: errorIconColor, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: errorTextStyle ??
                        TextStyle(color: textColor, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
