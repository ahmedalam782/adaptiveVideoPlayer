import 'package:flutter/material.dart';
import '../models/video_config.dart';

/// Live badge indicator with optional "GO LIVE" button.
class AdaptiveLiveIndicator extends StatelessWidget {
  final bool isLive;
  final List<VideoQuality>? qualities;
  final void Function(VideoQuality)? onQualitySelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  const AdaptiveLiveIndicator({
    super.key,
    required this.isLive,
    this.qualities,
    this.onQualitySelected,
    this.onAnalyticsEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (isLive) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
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
            const Text(
              'LIVE',
              style: TextStyle(
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
          onAnalyticsEvent?.call('switched_to_live', {});
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
              const Text(
                'GO LIVE',
                style: TextStyle(
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
