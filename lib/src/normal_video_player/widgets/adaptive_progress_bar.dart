import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';
import 'buffer_slider.dart';

/// Progress bar slider for video scrubbing with gradient track and buffered progress.
class AdaptiveProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final double? dragPosition;
  final ValueChanged<double> onDragChanged;
  final ValueChanged<double> onDragEnd;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  const AdaptiveProgressBar({
    super.key,
    required this.controller,
    required this.dragPosition,
    required this.onDragChanged,
    required this.onDragEnd,
    this.styling,
    this.onAnalyticsEvent,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final duration = value.duration.inMilliseconds.toDouble();
        final position = dragPosition ?? value.position.inMilliseconds.toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              activeTrackColor: styling?.progressBarPlayedColor ?? Colors.red,
              inactiveTrackColor: Colors.white24,
              thumbColor: styling?.progressBarHandleColor ?? Colors.red,
              trackShape: const GradientSliderTrackShape(),
            ),
            child: Slider(
              value: position.clamp(0.0, duration > 0 ? duration : 0.0),
              min: 0.0,
              max: duration > 0 ? duration : 0.0,
              onChanged: onDragChanged,
              onChangeEnd: (newPosition) {
                onDragEnd(newPosition);
                onAnalyticsEvent?.call('video_seek',
                    {'to_position': (newPosition / 1000).round()});
              },
            ),
          ),
        );
      },
    );
  }
}
