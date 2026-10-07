import 'package:flutter/material.dart';

import '../../core/widgets/adaptive_glassmorphic_container.dart';

/// A circular glassmorphic button with icon and tooltip used in PiP overlays.
class PipCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  const PipCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.backgroundColor = const Color(0x8C1E1E1E),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AdaptiveGlassmorphicContainer(
          shape: BoxShape.circle,
          width: size,
          height: size,
          blur: 14.0,
          color: backgroundColor,
          borderColor: Colors.white.withValues(alpha: 0.22),
          borderWidth: 1.0,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
