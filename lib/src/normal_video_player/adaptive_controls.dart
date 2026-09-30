import 'dart:async';
import 'package:flutter/material.dart';

import '../youtube_player/models/youtube_player_config.dart';
import 'models/video_config.dart';
import 'utils/adaptive_player_keyboard_handler.dart';
import 'utils/subtitle_parser.dart';
import 'utils/video_player_web_safe.dart';
import 'widgets/adaptive_buffering_indicator.dart';
import 'widgets/adaptive_controls_layer.dart';
import 'widgets/adaptive_seek_feedback_overlay.dart';
import 'widgets/adaptive_subtitle_layer.dart';
import 'widgets/adaptive_video_surface.dart';
import 'widgets/adaptive_volume_hud_overlay.dart';

export 'widgets/adaptive_controls_layer.dart';

class BaseAdaptiveVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final bool isFullScreen;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final List<VideoChapter>? chapters;
  final bool isLive;
  final String? viewerCount;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onMiniPlayerPressed;
  final PlayerPlaybackConfig? playback;

  const BaseAdaptiveVideoPlayer({
    super.key,
    required this.controller,
    this.showControls = true,
    this.isFullScreen = false,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.chapters,
    this.isLive = false,
    this.viewerCount,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onMiniPlayerPressed,
  });

  @override
  State<BaseAdaptiveVideoPlayer> createState() =>
      _BaseAdaptiveVideoPlayerState();
}

class _BaseAdaptiveVideoPlayerState extends State<BaseAdaptiveVideoPlayer> {
  bool _controlsVisible = true;
  int _seekDirection = 0; // -1 for backward, 1 for forward, 0 for none
  Timer? _hideTimer;
  final FocusNode _focusNode = FocusNode();
  double? _feedbackVolume;
  Timer? _volumeFeedbackTimer;
  bool _videoEndedEventSent = false;
  String _currentSubtitleText = '';
  int _seekSeconds = 10;
  Timer? _seekResetTimer;
  bool _isHold2xActive = false;
  double _previousPlaybackSpeed = 1.0;

  AdaptivePlayerKeyboardHandler get _keyboardHandler =>
      AdaptivePlayerKeyboardHandler(
        controller: widget.controller,
        isLive: widget.isLive,
        isFullScreen: widget.isFullScreen,
        onTogglePlay: _togglePlay,
        onSeek: _triggerSeekFeedback,
        onVolumeChanged: _showVolumeFeedback,
        onEnterFullscreen: widget.onEnterFullscreen,
        onExitFullscreen: widget.onExitFullscreen,
      );

  @override
  void initState() {
    super.initState();
    _startHideTimer();

    // Add listener to fire events
    widget.controller.addListener(_videoListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onAnalyticsEvent?.call('video_initialized',
            {'duration': widget.controller.value.duration.inSeconds});
      }
    });
  }

  void _togglePlay() {
    final isPlaying = widget.controller.value.isPlaying;
    if (isPlaying) {
      widget.controller.pause();
      widget.onAnalyticsEvent?.call('video_paused',
          {'position': widget.controller.value.position.inSeconds});
    } else {
      widget.controller.play();
      widget.onAnalyticsEvent?.call('video_played',
          {'position': widget.controller.value.position.inSeconds});
    }
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  void _videoListener() {
    if (widget.isLive) return; // Prevent listener overhead on high-framerate live streams
    final position = widget.controller.value.position;
    final duration = widget.controller.value.duration;

    if (position >= duration && duration.inMilliseconds > 0) {
      if (!_videoEndedEventSent) {
        _videoEndedEventSent = true;
        widget.onAnalyticsEvent?.call('video_ended', {});
      }
    } else {
      _videoEndedEventSent = false;
    }

    _updateSubtitle(position);
  }

  void _updateSubtitle(Duration position) {
    if (widget.parsedSubtitles == null || widget.parsedSubtitles!.isEmpty) {
      if (_currentSubtitleText.isNotEmpty) {
        setState(() => _currentSubtitleText = '');
      }
      return;
    }

    String newText = '';
    for (final item in widget.parsedSubtitles!) {
      if (position >= item.start && position <= item.end) {
        newText = item.text;
        break;
      }
    }

    if (_currentSubtitleText != newText && mounted) {
      setState(() => _currentSubtitleText = newText);
    }
  }

  @override
  void didUpdateWidget(BaseAdaptiveVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_videoListener);
      widget.controller.addListener(_videoListener);
      _videoEndedEventSent = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    _hideTimer?.cancel();
    _volumeFeedbackTimer?.cancel();
    _seekResetTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerSeekFeedback(int direction) {
    if (!mounted) return;
    _seekResetTimer?.cancel();
    final skipSec = widget.visibility?.skipDuration.inSeconds ?? 10;
    setState(() {
      if (_seekDirection == direction) {
        _seekSeconds += skipSec;
      } else {
        _seekDirection = direction;
        _seekSeconds = skipSec;
      }
    });
    _startHideTimer();
    _seekResetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _seekDirection = 0;
          _seekSeconds = widget.visibility?.skipDuration.inSeconds ?? 10;
        });
      }
    });
  }

  void _showVolumeFeedback(double volume) {
    if (!(widget.visibility?.showVolumeFeedback ?? true)) return;
    _volumeFeedbackTimer?.cancel();
    setState(() {
      _feedbackVolume = volume;
    });
    final timeout = widget.visibility?.volumeFeedbackTimeout ??
        const Duration(milliseconds: 1200);
    _volumeFeedbackTimer = Timer(timeout, () {
      if (mounted) setState(() => _feedbackVolume = null);
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    final timeout = widget.visibility?.controlsHideTimeout ??
        const Duration(seconds: 3);
    _hideTimer = Timer(timeout, () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (widget.isLive) return;

    final width = MediaQuery.of(context).size.width;
    final position = details.globalPosition.dx;
    final currentPosition = widget.controller.value.position;
    final wasPlaying = widget.controller.value.isPlaying;
    final duration = widget.controller.value.duration;
    final isRtl = (widget.messages ?? const PlayerTextConfig())
            .resolveTextDirection(context) ==
        TextDirection.rtl;
    final tappedRightHalf = position > width / 2;
    final isForward = isRtl ? !tappedRightHalf : tappedRightHalf;
    final skipDuration =
        widget.visibility?.skipDuration ?? const Duration(seconds: 10);

    if (isForward) {
      _triggerSeekFeedback(1);
      final newPosition = currentPosition + skipDuration;
      widget.controller
          .seekTo(newPosition > duration ? duration : newPosition);
    } else {
      _triggerSeekFeedback(-1);
      final newPosition = currentPosition - skipDuration;
      widget.controller
          .seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    }

    if (wasPlaying) {
      widget.controller.play();
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.isLive) return;
    _previousPlaybackSpeed = widget.controller.value.playbackSpeed;
    setState(() => _isHold2xActive = true);
    widget.controller.setPlaybackSpeed(2.0);
    widget.onAnalyticsEvent?.call('playback_speed_hold_start', {'speed': 2.0});
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _stopHold2xSpeed();
  }

  void _stopHold2xSpeed() {
    if (!_isHold2xActive) return;
    setState(() => _isHold2xActive = false);
    widget.controller.setPlaybackSpeed(_previousPlaybackSpeed);
    widget.onAnalyticsEvent
        ?.call('playback_speed_hold_end', {'speed': _previousPlaybackSpeed});
  }

  @override
  Widget build(BuildContext context) {
    final videoContent = AdaptiveVideoSurface(
      controller: widget.controller,
      subtitleBuilder: widget.subtitleBuilder,
    );

    final playerContent = Container(
      color: Colors.black,
      width: widget.isFullScreen ? double.infinity : null,
      height: widget.isFullScreen ? double.infinity : null,
      child: Stack(
        fit: widget.isFullScreen ? StackFit.expand : StackFit.loose,
        alignment: Alignment.center,
        children: [
          widget.isFullScreen ? Center(child: videoContent) : videoContent,

          // Buffering/Loading Indicator Overlay
          AdaptiveBufferingIndicator(
            controller: widget.controller,
            styling: widget.styling,
          ),

          // Visual feedback overlay for Double-Tap seeking (+10s, +20s, +30s...)
          AdaptiveSeekFeedbackOverlay(
            seekDirection: _seekDirection,
            seekSeconds: _seekSeconds,
          ),

          // Sleek Volume HUD Feedback Overlay
          AdaptiveVolumeHudOverlay(
            volume: _feedbackVolume,
            isFullScreen: widget.isFullScreen,
          ),

          // YouTube-style Hold-to-2x Speed Pill Badge at top-center
          if (_isHold2xActive)
            Positioned(
              top: widget.isFullScreen ? 32 : 14,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xBF000000),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.messages?.speed2xText ?? '2x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.fast_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Subtitle layer
          AdaptiveSubtitleLayer(
            subtitleText: _currentSubtitleText,
            showControls: widget.showControls,
            controlsVisible: _controlsVisible,
            isFullScreen: widget.isFullScreen,
            subtitleBuilder: widget.subtitleBuilder,
            styling: widget.styling,
          ),

          if (widget.showControls)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _focusNode.requestFocus();
                  _toggleControls();
                },
                onDoubleTapDown: _handleDoubleTap,
                onLongPressStart: _handleLongPressStart,
                onLongPressEnd: _handleLongPressEnd,
                onLongPressCancel: _stopHold2xSpeed,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: widget.controlsBuilder != null
                      ? widget.controlsBuilder!(
                          context, widget.controller, widget.isFullScreen)
                      : AdaptiveControlsLayer(
                          controller: widget.controller,
                          isFullScreen: widget.isFullScreen,
                          styling: widget.styling,
                          messages: widget.messages,
                          visibility: widget.visibility,
                          playback: widget.playback,
                          onAnalyticsEvent: widget.onAnalyticsEvent,
                          qualities: widget.qualities,
                          currentQuality: widget.currentQuality,
                          onQualitySelected: widget.onQualitySelected,
                          subtitles: widget.subtitles,
                          currentSubtitleTrack: widget.currentSubtitleTrack,
                          onSubtitleSelected: widget.onSubtitleSelected,
                          parsedSubtitles: widget.parsedSubtitles,
                          chapters: widget.chapters,
                          controlsBuilder: widget.controlsBuilder,
                          subtitleBuilder: widget.subtitleBuilder,
                          isLive: widget.isLive,
                          viewerCount: widget.viewerCount,
                          onEnterFullscreen: widget.onEnterFullscreen,
                          onExitFullscreen: widget.onExitFullscreen,
                          onMiniPlayerPressed: widget.onMiniPlayerPressed,
                        ),
                ),
              ),
            ),
        ],
      ),
    );

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _keyboardHandler.handleKeyEvent,
      child: MouseRegion(
        cursor: _controlsVisible
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        onHover: (_) {
          _startHideTimer();
          if (!_controlsVisible) {
            setState(() => _controlsVisible = true);
          }
        },
        child: playerContent,
      ),
    );
  }
}
