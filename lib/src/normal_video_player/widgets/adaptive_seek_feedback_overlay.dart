import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Visual feedback overlay displayed when seeking via double tap or keyboard (+10s, +20s, +30s, etc.).
class AdaptiveSeekFeedbackOverlay extends StatelessWidget {
  final int seekDirection;
  final int seekSeconds;
  final PlayerStyleConfig? styling;

  const AdaptiveSeekFeedbackOverlay({
    super.key,
    required this.seekDirection,
    this.seekSeconds = 10,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    if (seekDirection == 0) return const SizedBox.shrink();

    final isForward = seekDirection == 1;
    final containerColor =
        styling?.controlsBackgroundColor ?? const Color(0xFF1B313F);
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBackwardIcon(context, iconColor),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                              _buildForwardIcon(context, iconColor),
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

  Widget _buildBackwardIcon(BuildContext context, Color iconColor) {
    final configured = styling?.icons.skipBackwardIcon;
    final isNumberedIcon = configured?.iconData == Icons.replay_10_rounded ||
        configured?.iconData == Icons.replay_5_rounded ||
        configured?.iconData == Icons.replay_30_rounded;
    if (configured != null && !isNumberedIcon) {
      return configured.build(
        context,
        defaultColor: iconColor,
        defaultSize: 20,
        fallbackIcon: Icons.fast_rewind_rounded,
      );
    }
    return Icon(
      Icons.fast_rewind_rounded,
      color: iconColor,
      size: 20,
    );
  }

  Widget _buildForwardIcon(BuildContext context, Color iconColor) {
    final configured = styling?.icons.skipForwardIcon;
    final isNumberedIcon = configured?.iconData == Icons.forward_10_rounded ||
        configured?.iconData == Icons.forward_5_rounded ||
        configured?.iconData == Icons.forward_30_rounded;
    if (configured != null && !isNumberedIcon) {
      return configured.build(
        context,
        defaultColor: iconColor,
        defaultSize: 20,
        fallbackIcon: Icons.fast_forward_rounded,
      );
    }
    return Icon(
      Icons.fast_forward_rounded,
      color: iconColor,
      size: 20,
    );
  }
}

