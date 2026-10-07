import 'package:flutter/material.dart';

import '../models/player_icon_config.dart';

/// A circular button following YouTube desktop design styling.
class YouTubeDesktopStyleButton extends StatelessWidget {
  final PlayerIcon? playerIcon;
  final IconData? fallbackIcon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  const YouTubeDesktopStyleButton({
    super.key,
    this.playerIcon,
    this.fallbackIcon,
    required this.tooltip,
    required this.onTap,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Builder(
                builder: (context) {
                  return PlayerIcon.resolve(
                    context,
                    icon: playerIcon,
                    fallbackIcon: fallbackIcon ?? Icons.circle,
                    defaultColor: Colors.white.withValues(alpha: 0.95),
                    defaultSize: size,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
