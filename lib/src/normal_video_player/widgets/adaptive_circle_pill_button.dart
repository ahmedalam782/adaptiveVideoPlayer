import 'dart:ui';
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
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: backgroundColor.withValues(
                  alpha: backgroundColor.a < 0.01
                      ? 0.40
                      : backgroundColor.a,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
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
      ),
    );
  }
}
