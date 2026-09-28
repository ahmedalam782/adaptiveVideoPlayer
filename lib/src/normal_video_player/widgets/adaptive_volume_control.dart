import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Interactive volume button and hoverable slider.
class AdaptiveVolumeControl extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final bool alwaysShowSlider;

  const AdaptiveVolumeControl({
    super.key,
    required this.controller,
    this.styling,
    this.alwaysShowSlider = false,
  });

  @override
  State<AdaptiveVolumeControl> createState() => _AdaptiveVolumeControlState();
}

class _AdaptiveVolumeControlState extends State<AdaptiveVolumeControl> {
  bool _isVolumeHovered = false;
  double _lastNonZeroVolume = 1.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, VideoPlayerValue value, child) {
        final isMuted = value.volume == 0;
        final showSlider = widget.alwaysShowSlider || _isVolumeHovered;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isVolumeHovered = true),
            onExit: (_) => setState(() => _isVolumeHovered = false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isMuted) {
                    widget.controller.setVolume(_lastNonZeroVolume);
                  } else {
                    _lastNonZeroVolume = value.volume;
                    widget.controller.setVolume(0);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : value.volume < 0.5
                            ? Icons.volume_down_rounded
                            : Icons.volume_up_rounded,
                    color: widget.styling?.iconColor ?? Colors.white,
                    size: 20,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: showSlider ? 64 : 0,
                curve: Curves.easeInOut,
                child: ClipRect(
                  child: showSlider
                      ? SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5.5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10.0),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: value.volume.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            onChanged: (newVolume) {
                              widget.controller.setVolume(newVolume);
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}
