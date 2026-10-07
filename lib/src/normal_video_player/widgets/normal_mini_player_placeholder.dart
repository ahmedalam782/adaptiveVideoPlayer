import 'package:flutter/material.dart';

/// A widget shown in place of the normal player when the video is floating in MiniPlayer mode.
class NormalMiniPlayerPlaceholder extends StatelessWidget {
  final String restoreText;
  final VoidCallback onRestore;

  const NormalMiniPlayerPlaceholder({
    super.key,
    required this.restoreText,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRestore,
      child: Material(
        color: Colors.black87,
        child: InkWell(
          onTap: onRestore,
          hoverColor: Colors.white.withValues(alpha: 0.05),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.picture_in_picture_alt_rounded,
                  color: Colors.white54,
                  size: 36,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(
                    Icons.open_in_full_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    restoreText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
