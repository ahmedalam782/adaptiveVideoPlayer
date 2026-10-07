import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../youtube_player/models/player_style_config.dart';

/// A floating vertical volume popup slider used when hovering or tapping volume controls.
class AdaptiveVolumePopup extends StatelessWidget {
  final LayerLink link;
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const AdaptiveVolumePopup({
    super.key,
    required this.link,
    required this.controller,
    this.styling,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onVolumeChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = styling?.volumeSliderActiveColor ??
        styling?.progressBarPlayedColor ??
        Colors.white;
    final thumbColor = styling?.volumeSliderThumbColor ??
        styling?.progressBarHandleColor ??
        activeColor;
    final inactiveColor = styling?.volumeSliderInactiveColor ??
        styling?.progressBarBackgroundColor ??
        Colors.white.withValues(alpha: 0.24);
    final containerColor =
        styling?.controlsBackgroundColor ?? const Color(0xFF1B313F);

    return Positioned(
      width: 38,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: const Offset(0, -8),
        child: MouseRegion(
          onEnter: (_) => onHoverEnter(),
          onExit: (_) => onHoverExit(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 38,
              height: 114,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, VideoPlayerValue value, _) {
                  return RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: styling?.volumeSliderTrackHeight ?? 3.5,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius:
                              styling?.volumeSliderThumbRadius ?? 6.0,
                          pressedElevation: 3.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: activeColor,
                        inactiveTrackColor: inactiveColor,
                        thumbColor: thumbColor,
                      ),
                      child: Slider(
                        value: value.volume.clamp(0.0, 1.0),
                        min: 0.0,
                        max: 1.0,
                        onChangeStart: onChangeStart,
                        onChanged: onVolumeChanged,
                        onChangeEnd: onChangeEnd,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
