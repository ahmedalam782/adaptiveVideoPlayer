import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Error display widget for normal video player.
class NormalPlayerErrorWidget extends StatelessWidget {
  final String errorMessage;
  final PlayerStyleConfig? styling;
  final Widget Function(BuildContext context, String errorMessage)? customBuilder;

  const NormalPlayerErrorWidget({
    super.key,
    required this.errorMessage,
    this.styling,
    this.customBuilder,
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
                Icon(
                  Icons.error_outline,
                  color: styling?.errorIconColor ??
                      const Color.fromRGBO(255, 0, 0, 0.7),
                  size: 48,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
