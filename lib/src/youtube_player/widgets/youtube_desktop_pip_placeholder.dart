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
          color: const Color(0xFF0F172A),
          child: InkWell(
            onTap: onRestore,
            hoverColor: Colors.white.withValues(alpha: 0.04),
            splashColor: Colors.white.withValues(alpha: 0.08),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E293B),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onRestore,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                      ),
                      label: Text(
                        restorePlayerText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
