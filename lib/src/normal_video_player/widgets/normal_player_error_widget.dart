import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Error display widget for normal video player.
class NormalPlayerErrorWidget extends StatelessWidget {
  final String errorMessage;
  final PlayerStyleConfig? styling;
  final Widget Function(BuildContext context, String errorMessage)? customBuilder;
  final VoidCallback? onRetry;

  const NormalPlayerErrorWidget({
    super.key,
    required this.errorMessage,
    this.styling,
    this.customBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (customBuilder != null) {
      return customBuilder!(context, errorMessage);
    }

    return Container(
      decoration: BoxDecoration(
        color: styling?.backgroundColor ?? Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerIcon.resolve(
                  context,
                  icon: styling?.icons.errorIcon,
                  fallbackIcon: Icons.error_outline,
                  defaultColor: styling?.errorIconColor ??
                      const Color.fromRGBO(255, 0, 0, 0.7),
                  defaultSize: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: styling?.textColor ??
                        const Color.fromRGBO(255, 0, 0, 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onRetry,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: styling?.iconColor ?? Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: styling?.textColor ?? Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
