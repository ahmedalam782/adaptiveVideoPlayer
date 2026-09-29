import 'package:flutter/material.dart';

/// Visual feedback overlay displayed when seeking via double tap or keyboard (+10s, +20s, +30s, etc.).
class AdaptiveSeekFeedbackOverlay extends StatelessWidget {
  final int seekDirection;
  final int seekSeconds;

  const AdaptiveSeekFeedbackOverlay({
    super.key,
    required this.seekDirection,
    this.seekSeconds = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (seekDirection == 0) return const SizedBox.shrink();

    final isForward = seekDirection == 1;

    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          children: [
            // Left (Backward Seek)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: !isForward
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.transparent,
                child: !isForward
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '- $seekSeconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            // Right (Forward Seek)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isForward
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.transparent,
                child: isForward
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+ $seekSeconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
