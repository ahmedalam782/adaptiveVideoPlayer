import 'package:flutter/material.dart';

import '../../youtube_player/models/player_icon_config.dart';

/// A circular pill button used across player control bars.
///
/// Implements [StatelessWidget] adhering to Flutter performance guidelines
/// and Single Responsibility Principle (SRP).
class AdaptiveCirclePillButton extends StatelessWidget {
  final PlayerIcon? playerIcon;
  final IconData? icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final Color backgroundColor;
  final double size;
  final Offset offset;

  const AdaptiveCirclePillButton({
    super.key,
    this.playerIcon,
    this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.backgroundColor = const Color(0x8C000000),
    this.size = 20,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: Transform.translate(
                offset: offset,
                child: Builder(
                  builder: (context) {
                    return PlayerIcon.resolve(
                      context,
                      icon: playerIcon,
                      fallbackIcon: icon ?? Icons.circle,
                      defaultColor: color ?? Colors.white,
                      defaultSize: size,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
