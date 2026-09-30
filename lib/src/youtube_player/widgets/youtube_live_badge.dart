import 'package:flutter/material.dart';

/// Live badge and viewer count indicator for YouTube player.
class YouTubeLiveBadge extends StatelessWidget {
  final bool isLive;
  final String? viewerCount;
  final String liveText;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? textColor;

  const YouTubeLiveBadge({
    super.key,
    this.isLive = false,
    this.viewerCount,
    this.liveText = 'LIVE',
    this.badgeColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLive && viewerCount == null) return const SizedBox.shrink();

    final effectiveBadgeColor = badgeColor ?? Colors.red;
    final effectiveIconColor = iconColor ?? Colors.white;
    final effectiveTextColor = textColor ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLive)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: effectiveBadgeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  liveText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (viewerCount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: effectiveIconColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  viewerCount!,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
