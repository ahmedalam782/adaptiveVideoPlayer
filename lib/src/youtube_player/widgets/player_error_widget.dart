import 'package:flutter/material.dart';

/// Error display widget for YouTube player.
class PlayerErrorWidget extends StatelessWidget {
  final String errorMessage;
  final Color errorIconColor;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? errorTextStyle;

  const PlayerErrorWidget({
    super.key,
    required this.errorMessage,
    required this.errorIconColor,
    required this.backgroundColor,
    required this.textColor,
    this.errorTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: errorIconColor, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: errorTextStyle ??
                        TextStyle(color: textColor, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
