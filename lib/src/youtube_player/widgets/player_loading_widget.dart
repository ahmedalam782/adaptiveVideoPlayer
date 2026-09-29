import 'package:flutter/material.dart';

/// Loading indicator widget for YouTube player.
class PlayerLoadingWidget extends StatelessWidget {
  final Color loadingIndicatorColor;
  final Color backgroundColor;

  const PlayerLoadingWidget({
    super.key,
    required this.loadingIndicatorColor,
    required this.backgroundColor,
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
            child: CircularProgressIndicator(
              color: loadingIndicatorColor,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}
