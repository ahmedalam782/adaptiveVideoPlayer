import 'dart:ui';
import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import 'seek_feedback_icon.dart';

/// Visual feedback overlay displayed when seeking via double tap or keyboard (+10s, +20s, +30s, etc.).
class AdaptiveSeekFeedbackOverlay extends StatelessWidget {
  final int seekDirection;
  final int seekSeconds;
  final PlayerStyleConfig? styling;
  final Color? fallbackColor;

  const AdaptiveSeekFeedbackOverlay({
    super.key,
    required this.seekDirection,
    this.seekSeconds = 10,
    this.styling,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    if (seekDirection == 0) return const SizedBox.shrink();

    final isForward = seekDirection == 1;
    final textColor = styling?.textColor ?? Colors.white;
    final iconColor = styling?.iconColor ?? Colors.white;

    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          children: [
            // Left (Backward Seek)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: !isForward
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.transparent,
                child: !isForward
                    ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.30),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SeekFeedbackIcon(
                                    isForward: false,
                                    iconColor: iconColor,
                                    configuredIcon: styling?.icons.skipBackwardIcon,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '- $seekSeconds',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.transparent,
                child: isForward
                    ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.30),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+ $seekSeconds',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SeekFeedbackIcon(
                                    isForward: true,
                                    iconColor: iconColor,
                                    configuredIcon: styling?.icons.skipForwardIcon,
                                  ),
                                ],
                              ),
                            ),
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