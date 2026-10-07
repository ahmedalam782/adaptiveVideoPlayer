import 'package:flutter/material.dart';
import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';

/// Live badge indicator with optional "GO LIVE" button.
class AdaptiveLiveIndicator extends StatelessWidget {
  final bool isLive;
  final List<VideoQuality>? qualities;
  final void Function(VideoQuality)? onQualitySelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final PlayerTextConfig? messages;
  final PlayerStyleConfig? styling;

  const AdaptiveLiveIndicator({
    super.key,
    required this.isLive,
    this.qualities,
    this.onQualitySelected,
    this.onAnalyticsEvent,
    this.messages,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    final liveColor = styling?.progressBarPlayedColor ?? Colors.red;

    if (isLive) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: liveColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              messages?.liveText ?? PlayerStrings.live,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final liveQuality = qualities?.where((q) => q.isLive).firstOrNull;
    if (liveQuality != null) {
      return GestureDetector(
        onTap: () {
          onAnalyticsEvent?.call(PlayerEvents.switchedToLive, {});
          onQualitySelected?.call(liveQuality);
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                messages?.goLiveText ?? 'GO LIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
