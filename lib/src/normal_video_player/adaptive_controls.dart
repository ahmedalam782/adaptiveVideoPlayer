import 'package:flutter/material.dart';

import '../youtube_player/models/youtube_player_config.dart';
import 'mixins/adaptive_player_gestures_mixin.dart';
import 'mixins/adaptive_player_subtitles_sync_mixin.dart';
import 'mixins/adaptive_player_visibility_mixin.dart';
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

class _BaseAdaptiveVideoPlayerState extends State<BaseAdaptiveVideoPlayer>
    with
        AdaptivePlayerVisibilityMixin,
        AdaptivePlayerGesturesMixin,
        AdaptivePlayerSubtitlesSyncMixin {
  final FocusNode _focusNode = FocusNode();
  bool _videoEndedEventSent = false;

  AdaptivePlayerKeyboardHandler get _keyboardHandler =>
      AdaptivePlayerKeyboardHandler(
        controller: widget.controller,
        isLive: widget.isLive,
        isFullScreen: widget.isFullScreen,
        onTogglePlay: _togglePlay,
        onSeek: (dir) => triggerSeekFeedback(dir, startHideTimer),
        onVolumeChanged: showVolumeFeedback,
        onEnterFullscreen: widget.onEnterFullscreen,
        onExitFullscreen: widget.onExitFullscreen,
      );

  @override
  void initState() {
    super.initState();
    startHideTimer();

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
    setState(() => controlsVisible = true);
    startHideTimer();
  }

  void _videoListener() {
    if (widget.isLive) return;
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

    updateSubtitle(position);
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
    disposeVisibilityTimer();
    disposeGesturesTimers();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoFit = widget.styling?.videoFit ?? BoxFit.contain;
    final isCover = videoFit == BoxFit.cover || videoFit == BoxFit.fill;

    final videoContent = AdaptiveVideoSurface(
      controller: widget.controller,
      subtitleBuilder: widget.subtitleBuilder,
      fit: videoFit,
    );

    final playerContent = Container(
      color: Colors.black,
      width: (widget.isFullScreen || isCover) ? double.infinity : null,
      height: (widget.isFullScreen || isCover) ? double.infinity : null,
      child: Stack(
        fit:
            (widget.isFullScreen || isCover) ? StackFit.expand : StackFit.loose,
        alignment: Alignment.center,
        children: [
          Center(
            child: isCover
                ? SizedBox.expand(child: videoContent)
                : videoContent,
          ),

          // Buffering/Loading Indicator Overlay
          AdaptiveBufferingIndicator(
            controller: widget.controller,
            styling: widget.styling,
          ),

          // Visual feedback overlay for Double-Tap seeking (+10s, +20s, +30s...)
          AdaptiveSeekFeedbackOverlay(
            seekDirection: seekDirection,
            seekSeconds: seekSeconds,
            styling: widget.styling,
          ),

          // Sleek Volume HUD Feedback Overlay
          AdaptiveVolumeHudOverlay(
            volume: feedbackVolume,
            isFullScreen: widget.isFullScreen,
            styling: widget.styling,
          ),

          // YouTube-style Hold-to-2x Speed Pill Badge at top-center
          if (isHold2xActive)
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
            subtitleText: currentSubtitleText,
            showControls: widget.showControls,
            controlsVisible: controlsVisible,
            isFullScreen: widget.isFullScreen,
            subtitleBuilder: widget.subtitleBuilder,
            styling: widget.styling,
          ),

          if (widget.showControls)
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _focusNode.requestFocus();
                      toggleControls();
                    },
                    onDoubleTapDown: (details) =>
                        handleDoubleTap(details, startHideTimer),
                    onLongPressStart: handleLongPressStart,
                    onLongPressEnd: handleLongPressEnd,
                    onLongPressCancel: stopHold2xSpeed,
                  ),
                  AnimatedOpacity(
                    opacity: controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !controlsVisible,
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
                ],
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
        cursor:
            controlsVisible ? SystemMouseCursors.basic : SystemMouseCursors.none,
        onHover: (_) {
          startHideTimer();
          if (!controlsVisible) {
            setState(() => controlsVisible = true);
          }
        },
        child: playerContent,
      ),
    );
  }
}
