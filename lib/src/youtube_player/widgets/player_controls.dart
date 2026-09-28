import 'package:flutter/material.dart';

export 'player_error_widget.dart';
export 'player_loading_widget.dart';

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
          SeekButton(icon: Icons.replay_10, onTap: onSeekBackward, size: 35),
          SeekButton(icon: Icons.forward_10, onTap: onSeekForward, size: 35),
        ],
      ),
    );
  }
}
