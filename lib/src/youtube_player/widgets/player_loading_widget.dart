import 'package:flutter/material.dart';

/// Loading indicator widget for YouTube player.
class PlayerLoadingWidget extends StatelessWidget {
  final Color loadingIndicatorColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double? size;
  final Widget Function(BuildContext context)? builder;

  const PlayerLoadingWidget({
    super.key,
    required this.loadingIndicatorColor,
    required this.backgroundColor,
    this.strokeWidth = 4.0,
    this.size,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context);
    }

    Widget indicator = CircularProgressIndicator(
      color: loadingIndicatorColor,
      strokeWidth: strokeWidth,
      strokeCap: StrokeCap.round,
    );
    if (size != null) {
      indicator = SizedBox(
        width: size,
        height: size,
        child: indicator,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: backgroundColor,
          child: Center(
            child: indicator,
          ),
        ),
      ),
    );
  }
}
