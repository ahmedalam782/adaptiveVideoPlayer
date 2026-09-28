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

        final playedColor =
            styling?.progressBarPlayedColor ?? const Color(0xFFFF0033);
        final handleColor =
            styling?.progressBarHandleColor ?? const Color(0xFFFF0033);

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: SizedBox(
              height: 20,
              child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.5,
                  pressedElevation: 4.0,
                ),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
                activeTrackColor: playedColor,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                thumbColor: handleColor,
                trackShape: GradientSliderTrackShape(
                  gradient: LinearGradient(
                    colors: [playedColor, handleColor],
                  ),
                  buffered: value.buffered,
                  duration: value.duration,
                ),
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
          ),
          ),
        );
      },
    );
  }
}
