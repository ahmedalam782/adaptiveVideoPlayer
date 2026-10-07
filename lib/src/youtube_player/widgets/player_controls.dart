import 'package:flutter/material.dart';

export 'player_error_widget.dart';
export 'player_loading_widget.dart';

/// Seek button widget used in controls overlay.
class SeekButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const SeekButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Container(
          width: size + 20,
          height: size + 20,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

/// Seek buttons overlay that shows -10s and +10s buttons.
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
          SeekButton(
            icon: Icons.replay_10_rounded,
            onTap: onSeekBackward,
            size: 36,
          ),
          SeekButton(
            icon: Icons.forward_10_rounded,
            onTap: onSeekForward,
            size: 36,
          ),
        ],
      ),
    );
  }
}
