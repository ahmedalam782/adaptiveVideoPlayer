import 'package:flutter/material.dart';

import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_visibility_config.dart';
import '../models/video_chapter.dart';

/// A widget displaying the current playback position, total duration, and active chapter.
class AdaptiveDurationDisplay extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isWide;
  final PlayerStyleConfig? styling;
  final PlayerVisibilityConfig? visibility;
  final List<VideoChapter>? chapters;

  const AdaptiveDurationDisplay({
    super.key,
    required this.position,
    required this.duration,
    required this.isWide,
    this.styling,
    this.visibility,
    this.chapters,
  });

  static String formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final style = styling?.timeTextStyle ??
        styling?.settingItemTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        );

    final textColor = styling?.textColor ?? Colors.white;
    final activeChapter = VideoChapter.findChapterAt(chapters, position);
    final canShowChapter = isWide &&
        activeChapter != null &&
        (visibility?.showChapterTitle ?? true);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(position),
            style: style.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' / ',
            style: style.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          Text(
            formatDuration(duration),
            style: style.copyWith(
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          if (canShowChapter) ...[
            Text(
              '  •  ',
              style: style.copyWith(
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                activeChapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
