import 'package:flutter/material.dart';

/// A circular button with icon and tooltip used in PiP overlays.
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
    this.backgroundColor = const Color(0xCC2E2E2E),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
