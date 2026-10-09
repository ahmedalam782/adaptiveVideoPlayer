import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';

/// Next Episode button (>|) in bottom controls row matching Netflix player.
class AdaptiveNextEpisodeButton extends StatelessWidget {
  final VoidCallback? onNextEpisode;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;

  const AdaptiveNextEpisodeButton({
    super.key,
    required this.onNextEpisode,
    this.styling,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (onNextEpisode == null) return const SizedBox.shrink();

    final tooltip = messages?.nextEpisodeText ?? 'Next Episode';
    final iconColor = styling?.iconColor ?? Colors.white;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onNextEpisode,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Icon(
            Icons.skip_next_rounded,
            color: iconColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
