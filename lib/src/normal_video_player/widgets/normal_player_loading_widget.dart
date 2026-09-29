import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Loading indicator widget for normal video player.
class NormalPlayerLoadingWidget extends StatelessWidget {
  final PlayerStyleConfig? styling;
  final Widget Function(BuildContext context)? customBuilder;

  const NormalPlayerLoadingWidget({
    super.key,
    this.styling,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (customBuilder != null) {
      return customBuilder!(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: styling?.backgroundColor ?? Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: CircularProgressIndicator(
            color: styling?.loadingIndicatorColor ??
                const Color.fromRGBO(255, 0, 0, 0.7),
            strokeCap: StrokeCap.round,
          ),
        ),
      ),
    );
  }
}
