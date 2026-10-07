import 'package:flutter/material.dart';

import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../models/subtitle_track.dart';

/// A quick-toggle button for enabling or disabling subtitles (CC).
class AdaptiveSubtitlesButton extends StatelessWidget {
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final VoidCallback? onSettingsPressed;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;

  const AdaptiveSubtitlesButton({
    super.key,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.onSettingsPressed,
    this.styling,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitles = subtitles != null && subtitles!.isNotEmpty;
    final isSubtitlesActive = currentSubtitleTrack != null;

    return Tooltip(
      message: messages?.subtitlesText ?? PlayerStrings.subtitles,
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasSubtitles
            ? () {
                if (isSubtitlesActive) {
                  onSubtitleSelected?.call(null);
                } else {
                  onSubtitleSelected?.call(subtitles!.first);
                }
              }
            : onSettingsPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isSubtitlesActive
                  ? (styling?.progressBarPlayedColor ?? Colors.red)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
              border: isSubtitlesActive
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
            ),
            child: Text(
              'CC',
              style: TextStyle(
                color: isSubtitlesActive ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
