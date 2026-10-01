import 'dart:async';
import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Interactive volume button and hoverable / touch-expandable slider.
class AdaptiveVolumeControl extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final bool alwaysShowSlider;

  const AdaptiveVolumeControl({
    super.key,
    required this.controller,
    this.styling,
    this.messages,
    this.alwaysShowSlider = false,
  });

  @override
  State<AdaptiveVolumeControl> createState() => _AdaptiveVolumeControlState();
}

class _AdaptiveVolumeControlState extends State<AdaptiveVolumeControl> {
  bool _isVolumeHovered = false;
  bool _isDraggingVolume = false;
  bool _isTouchExpanded = false;
  Timer? _collapseTimer;
  double _lastNonZeroVolume = 1.0;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _resetCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isDraggingVolume) {
        setState(() => _isTouchExpanded = false);
      }
    });
  }

  void _handleVolumeTap(VideoPlayerValue value, bool isMuted, bool showSlider) {
    // On mobile / touch screens (when slider is collapsed):
    // First tap expands the volume slider so user can adjust it!
    if (!showSlider) {
      setState(() => _isTouchExpanded = true);
      _resetCollapseTimer();
      return;
    }

    // When already showing slider, tap toggles mute/unmute
    if (isMuted) {
      final target = _lastNonZeroVolume > 0 ? _lastNonZeroVolume : 1.0;
      widget.controller.setVolume(target);
    } else {
      _lastNonZeroVolume = value.volume > 0 ? value.volume : 1.0;
      widget.controller.setVolume(0);
    }
    _resetCollapseTimer();
  }

  void _handleVolumeLongPress(VideoPlayerValue value, bool isMuted) {
    if (isMuted) {
      final target = _lastNonZeroVolume > 0 ? _lastNonZeroVolume : 1.0;
      widget.controller.setVolume(target);
    } else {
      _lastNonZeroVolume = value.volume > 0 ? value.volume : 1.0;
      widget.controller.setVolume(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, VideoPlayerValue value, child) {
        final isMuted = value.volume == 0;
        final showSlider = widget.alwaysShowSlider ||
            _isVolumeHovered ||
            _isDraggingVolume ||
            _isTouchExpanded;
        final textDirection = widget.messages?.resolveTextDirection(context) ??
            Directionality.maybeOf(context) ??
            TextDirection.ltr;

        final tooltip = isMuted
            ? (widget.messages?.unmuteAudioText ?? 'Unmute')
            : (widget.messages?.muteAudioText ?? 'Mute');

        final activeColor =
            widget.styling?.progressBarPlayedColor ?? Colors.white;
        final thumbColor =
            widget.styling?.progressBarHandleColor ?? Colors.white;

        return Directionality(
          textDirection: textDirection,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isVolumeHovered = true),
            onExit: (_) {
              setState(() {
                _isVolumeHovered = false;
                _isTouchExpanded = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 38,
              padding: EdgeInsetsDirectional.only(
                start: 6.0,
                end: showSlider ? 10.0 : 6.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: tooltip,
                    waitDuration: const Duration(milliseconds: 500),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleVolumeTap(value, isMuted, showSlider),
                      onLongPress: () => _handleVolumeLongPress(value, isMuted),
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: Center(
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
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: showSlider ? 66 : 0,
                    curve: Curves.easeInOut,
                    child: ClipRect(
                      child: showSlider
                          ? SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5.5,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 10.0,
                                ),
                                activeTrackColor: activeColor,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: thumbColor,
                              ),
                              child: Slider(
                                value: value.volume.clamp(0.0, 1.0),
                                min: 0.0,
                                max: 1.0,
                                onChangeStart: (_) {
                                  _collapseTimer?.cancel();
                                  setState(() => _isDraggingVolume = true);
                                },
                                onChanged: (newVolume) {
                                  if (newVolume > 0) {
                                    _lastNonZeroVolume = newVolume;
                                  }
                                  widget.controller.setVolume(newVolume);
                                },
                                onChangeEnd: (_) {
                                  setState(() => _isDraggingVolume = false);
                                  _resetCollapseTimer();
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
