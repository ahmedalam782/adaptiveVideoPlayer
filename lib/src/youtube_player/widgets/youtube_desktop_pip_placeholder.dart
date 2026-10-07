import 'package:flutter/material.dart';

/// Restore button placeholder UI shown in desktop views when player is docked in PiP mode.
class YouTubeDesktopPipPlaceholder extends StatelessWidget {
  final VoidCallback onRestore;
  final String restorePlayerText;

  const YouTubeDesktopPipPlaceholder({
    super.key,
    required this.onRestore,
    required this.restorePlayerText,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onRestore();
      },
      child: GestureDetector(
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
                      restorePlayerText,
                      style: const TextStyle(color: Colors.white),
                    ),
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
