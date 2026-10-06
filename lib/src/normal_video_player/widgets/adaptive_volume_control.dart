import 'dart:async';
import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// Interactive volume button. The slider opens above the icon, not beside it.
class AdaptiveVolumeControl extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final bool alwaysShowSlider;
  final bool allowExpand;

  const AdaptiveVolumeControl({
    super.key,
    required this.controller,
    this.styling,
    this.messages,
    this.alwaysShowSlider = false,
    this.allowExpand = true,
  });

  @override
  State<AdaptiveVolumeControl> createState() => _AdaptiveVolumeControlState();
}

class _AdaptiveVolumeControlState extends State<AdaptiveVolumeControl> {
  bool _isVolumeHovered = false;
  bool _isDraggingVolume = false;
  bool _isTouchExpanded = false;
  Timer? _collapseTimer;
  Timer? _hoverExitTimer;
  double _lastNonZeroVolume = 1.0;

  final LayerLink _link = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _desiredOverlay = false;
  bool _overlaySyncScheduled = false;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    _hoverExitTimer?.cancel();
    _removeOverlay();
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

  void _onHoverEnter() {
    _hoverExitTimer?.cancel();
    if (!_isVolumeHovered) {
      setState(() => _isVolumeHovered = true);
    }
  }

  void _onHoverExit() {
    _hoverExitTimer?.cancel();
    _hoverExitTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted || _isDraggingVolume) return;
      setState(() {
        _isVolumeHovered = false;
        _isTouchExpanded = false;
      });
    });
  }

  void _handleVolumeTap(VideoPlayerValue value, bool isMuted, bool showSlider) {
    if (!showSlider && widget.allowExpand) {
      setState(() => _isTouchExpanded = true);
      _resetCollapseTimer();
      return;
    }

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

  void _requestOverlay(bool show) {
    if (_desiredOverlay == show) return;
    _desiredOverlay = show;
    if (_overlaySyncScheduled) return;
    _overlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      if (!mounted) return;
      if (_desiredOverlay) {
        _insertOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _insertOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _overlayEntry = OverlayEntry(builder: _buildVolumePopup);
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildVolumePopup(BuildContext context) {
    final activeColor =
        widget.styling?.volumeSliderActiveColor ??
        widget.styling?.progressBarPlayedColor ??
        Colors.white;
    final thumbColor = widget.styling?.volumeSliderThumbColor ??
        widget.styling?.progressBarHandleColor ??
        activeColor;
    final inactiveColor = widget.styling?.volumeSliderInactiveColor ??
        widget.styling?.progressBarBackgroundColor ??
        Colors.white.withValues(alpha: 0.24);
    final containerColor =
        widget.styling?.controlsBackgroundColor ?? const Color(0xFF1B313F);

    return Positioned(
      width: 38,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: const Offset(0, -8),
        child: MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
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
                valueListenable: widget.controller,
                builder: (context, VideoPlayerValue value, _) {
                  return RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight:
                            widget.styling?.volumeSliderTrackHeight ?? 3.5,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius:
                              widget.styling?.volumeSliderThumbRadius ?? 6.0,
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
                        onChangeStart: (_) {
                          _collapseTimer?.cancel();
                          _hoverExitTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, VideoPlayerValue value, child) {
        final isMuted = value.volume == 0;
        final showSlider = widget.allowExpand &&
            (widget.alwaysShowSlider ||
                _isVolumeHovered ||
                _isDraggingVolume ||
                _isTouchExpanded);
        _requestOverlay(showSlider);

        final tooltip = isMuted
            ? (widget.messages?.unmuteAudioText ?? 'Unmute')
            : (widget.messages?.muteAudioText ?? 'Mute');

        return CompositedTransformTarget(
          link: _link,
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: Tooltip(
              message: tooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleVolumeTap(value, isMuted, showSlider),
                onLongPress: () => _handleVolumeLongPress(value, isMuted),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final PlayerIcon? customVolIcon;
                        final IconData fallbackVolIcon;
                        if (isMuted) {
                          customVolIcon = widget.styling?.icons.volumeMuteIcon;
                          fallbackVolIcon = Icons.volume_off_rounded;
                        } else if (value.volume < 0.5) {
                          customVolIcon = widget.styling?.icons.volumeLowIcon;
                          fallbackVolIcon = Icons.volume_down_rounded;
                        } else {
                          customVolIcon = widget.styling?.icons.volumeHighIcon;
                          fallbackVolIcon = Icons.volume_up_rounded;
                        }

                        return PlayerIcon.resolve(
                          context,
                          icon: customVolIcon,
                          fallbackIcon: fallbackVolIcon,
                          defaultColor:
                              widget.styling?.iconColor ?? Colors.white,
                          defaultSize: 20,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
