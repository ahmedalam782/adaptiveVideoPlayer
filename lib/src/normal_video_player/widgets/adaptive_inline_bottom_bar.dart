import 'package:flutter/material.dart';
import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_fullscreen_button.dart';
import 'adaptive_settings_button.dart';
import 'adaptive_volume_control.dart';
import 'buffer_slider.dart';

/// Single-row unified floating capsule bottom control bar.
///
/// Features play/pause, timestamp, inline progress slider, volume,
/// and fullscreen inside a single rounded pill container.
class AdaptiveInlineBottomBar extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isLive;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<VideoChapter>? chapters;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onMiniPlayerPressed;
  final bool showSkipButtons;
  final Duration skipDuration;
  final double? dragPosition;
  final ValueChanged<double>? onDragChanged;
  final ValueChanged<double>? onDragEnd;

  const AdaptiveInlineBottomBar({
    super.key,
    required this.controller,
    required this.isFullScreen,
    required this.isLive,
    this.styling,
    this.messages,
    this.visibility,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.chapters,
    this.onAnalyticsEvent,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onSettingsPressed,
    this.onMiniPlayerPressed,
    this.showSkipButtons = true,
    this.skipDuration = const Duration(seconds: 10),
    this.dragPosition,
    this.onDragChanged,
    this.onDragEnd,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _seekRelative(Duration offset) {
    final current = controller.value.position;
    final total = controller.value.duration;
    final target = (current + offset);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > total ? total : target);
    controller.seekTo(clamped);
    onAnalyticsEvent?.call(PlayerEvents.videoSeek, {
      PlayerEvents.paramToPosition: clamped.inSeconds,
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveVisibility = visibility ?? const PlayerVisibilityConfig();
    final playedColor = styling?.progressBarPlayedColor ?? const Color(0xFF00A3FF);
    final handleColor = styling?.progressBarHandleColor ?? playedColor;
    final containerColor = styling?.controlsBackgroundColor ?? const Color(0xFF1B313F);
    final iconColor = styling?.iconColor ?? Colors.white;
    final textColor = styling?.textColor ?? Colors.white;

    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;
          final isUltraCompact = constraints.maxWidth < 320;
          final canShowSkip = showSkipButtons &&
              effectiveVisibility.showSkipButtons &&
              !isLive &&
              constraints.maxWidth > 580;

          final showVolume = effectiveVisibility.showVolumeButton;
          final showTime = effectiveVisibility.showTimeDisplay && !isLive;
          final showFullscreen = effectiveVisibility.showFullscreenButton;
          final showMiniPlayer = effectiveVisibility.showMiniPlayerButton &&
              onMiniPlayerPressed != null &&
              !isFullScreen;
          final showSettings = effectiveVisibility.showSettingsButton &&
              constraints.maxWidth > 300;
          final showProgressBar = effectiveVisibility.showProgressBar && !isLive;

          final dynamicHeight =
              styling?.bottomBarHeight ?? (isCompact ? 42.0 : 46.0);
          final dynamicMargin = styling?.bottomBarMargin ??
              EdgeInsets.fromLTRB(
                isCompact ? 10.0 : 16.0,
                0.0,
                isCompact ? 10.0 : 16.0,
                isCompact ? 8.0 : 14.0,
              );
          final dynamicPadding = styling?.bottomBarPadding ??
              EdgeInsets.symmetric(
                horizontal: isCompact ? 10.0 : 14.0,
                vertical: 2.0,
              );
          final dynamicRadius = styling?.bottomBarBorderRadius ??
              BorderRadius.circular(16);

          return Padding(
            padding: dynamicMargin,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, VideoPlayerValue value, child) {
                final isPlaying = value.isPlaying;
                final position = value.position;
                final duration = value.duration;

                final currentMs = (dragPosition ?? position.inMilliseconds.toDouble())
                    .clamp(0.0, duration.inMilliseconds.toDouble());
                final maxMs = duration.inMilliseconds > 0
                    ? duration.inMilliseconds.toDouble()
                    : 0.0;

                return Container(
                  height: dynamicHeight,
                  padding: dynamicPadding,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: dynamicRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 1. Play / Pause Button
                      Tooltip(
                        message: isPlaying
                            ? (messages?.pauseText ?? PlayerStrings.pause)
                            : (messages?.playText ?? PlayerStrings.play),
                        waitDuration: const Duration(milliseconds: 500),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (isPlaying) {
                              controller.pause();
                              onAnalyticsEvent?.call(PlayerEvents.videoPaused, {
                                PlayerEvents.paramPosition: controller.value.position.inSeconds,
                              });
                            } else {
                              if (value.position >= value.duration &&
                                  value.duration > Duration.zero) {
                                controller.seekTo(Duration.zero);
                              }
                              controller.play();
                              onAnalyticsEvent?.call(PlayerEvents.videoPlayed, {
                                PlayerEvents.paramPosition: controller.value.position.inSeconds,
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 2.0 : 4.0,
                            ),
                            child: PlayerIcon.resolve(
                              context,
                              icon: isPlaying
                                  ? styling?.icons.pauseIcon
                                  : styling?.icons.playIcon,
                              fallbackIcon: isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_outlined,
                              defaultColor: iconColor,
                              defaultSize: isCompact ? 20 : 24,
                            ),
                          ),
                        ),
                      ),

                      // Optional Stop Button
                      if (effectiveVisibility.showStopButton) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: messages?.stopVideoText ?? PlayerStrings.stop,
                          waitDuration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              controller.pause();
                              controller.seekTo(Duration.zero);
                              onAnalyticsEvent?.call(PlayerEvents.videoStopped, {
                                PlayerEvents.paramPosition: 0,
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: PlayerIcon.resolve(
                                context,
                                icon: styling?.icons.stopIcon,
                                fallbackIcon: Icons.stop_rounded,
                                defaultColor: iconColor,
                                defaultSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Optional Skip Backward & Skip Forward
                      if (canShowSkip) ...[
                        const SizedBox(width: 2),
                        Tooltip(
                          message: messages?.skipBackwardText ?? 'Rewind 10s',
                          waitDuration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _seekRelative(-skipDuration),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: PlayerIcon.resolve(
                                context,
                                icon: styling?.icons.skipBackwardIcon,
                                fallbackIcon: Icons.replay_10_rounded,
                                defaultColor: iconColor,
                                defaultSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Tooltip(
                          message: messages?.skipForwardText ?? 'Forward 10s',
                          waitDuration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _seekRelative(skipDuration),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: PlayerIcon.resolve(
                                context,
                                icon: styling?.icons.skipForwardIcon,
                                fallbackIcon: Icons.forward_10_rounded,
                                defaultColor: iconColor,
                                defaultSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(width: isCompact ? 3.0 : 6.0),

                      // 2. Duration text: "00:00 / 04:32"
                      if (showTime) ...[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: (styling?.timeTextStyle ??
                                          TextStyle(
                                            fontSize: isCompact ? 11.5 : 12.5,
                                            fontWeight: FontWeight.w600,
                                          ))
                                      .copyWith(color: textColor),
                                ),
                                if (!isUltraCompact) ...[
                                  Text(
                                    ' / ',
                                    style: (styling?.timeTextStyle ??
                                            TextStyle(
                                              fontSize: isCompact ? 11.5 : 12.5,
                                              fontWeight: FontWeight.w500,
                                            ))
                                        .copyWith(
                                          color: textColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: (styling?.timeTextStyle ??
                                            TextStyle(
                                              fontSize: isCompact ? 11.5 : 12.5,
                                              fontWeight: FontWeight.w600,
                                            ))
                                        .copyWith(
                                          color: textColor.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        SizedBox(width: isCompact ? 4.0 : 8.0),
                      ],

                      // 3. Inline Progress Slider (Expanded)
                      if (showProgressBar)
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: styling?.progressBarTrackHeight ?? 3.5,
                              thumbShape: styling?.progressBarThumbShape ??
                                  ((styling?.showProgressBarThumb ?? true)
                                      ? RoundSliderThumbShape(
                                          enabledThumbRadius:
                                              styling?.progressBarThumbRadius ?? 6.0,
                                          pressedElevation: 3.0,
                                        )
                                      : const RoundSliderThumbShape(
                                          enabledThumbRadius: 0.0)),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: styling?.progressBarOverlayRadius ?? 12.0,
                              ),
                              activeTrackColor: playedColor,
                              inactiveTrackColor: styling?.progressBarBackgroundColor ??
                                  Colors.white.withValues(alpha: 0.22),
                              thumbColor: handleColor,
                              trackShape: GradientSliderTrackShape(
                                gradient: LinearGradient(colors: [playedColor, handleColor]),
                                buffered: value.buffered,
                                bufferedColor: styling?.progressBarBufferedColor,
                                duration: value.duration,
                                chapters: chapters,
                              ),
                            ),
                            child: Slider(
                              value: currentMs,
                              min: 0.0,
                              max: maxMs,
                              onChanged: (val) {
                                onDragChanged?.call(val);
                                controller.seekTo(Duration(milliseconds: val.round()));
                              },
                              onChangeEnd: (val) {
                                onDragEnd?.call(val);
                                onAnalyticsEvent?.call(PlayerEvents.videoSeek, {
                                  PlayerEvents.paramToPosition: (val / 1000).round(),
                                });
                              },
                            ),
                          ),
                        )
                      else
                        const Spacer(),

                      // 4. Volume Control
                      if (showVolume) ...[
                        SizedBox(width: isCompact ? 3.0 : 6.0),
                        AdaptiveVolumeControl(
                          controller: controller,
                          styling: styling,
                          messages: messages,
                          allowExpand: constraints.maxWidth > 380,
                        ),
                      ],

                      // Optional Settings Button
                      if (showSettings) ...[
                        SizedBox(width: isCompact ? 2.0 : 4.0),
                        AdaptiveSettingsButton(
                          isFullScreen: isFullScreen,
                          styling: styling,
                          messages: messages,
                          qualities: qualities,
                          currentQuality: currentQuality,
                          onQualitySelected: onQualitySelected,
                          subtitles: subtitles,
                          currentSubtitleTrack: currentSubtitleTrack,
                          onSubtitleSelected: onSubtitleSelected,
                          onAnalyticsEvent: onAnalyticsEvent,
                          onPressed: onSettingsPressed,
                        ),
                      ],

                      // Optional MiniPlayer Button
                      if (showMiniPlayer) ...[
                        SizedBox(width: isCompact ? 2.0 : 4.0),
                        Tooltip(
                          message: messages?.miniPlayerText ?? 'Miniplayer',
                          waitDuration: const Duration(milliseconds: 500),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onMiniPlayerPressed,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 2.0 : 4.0,
                                vertical: 4.0,
                              ),
                              child: PlayerIcon.resolve(
                                context,
                                icon: styling?.icons.miniPlayerIcon,
                                fallbackIcon:
                                    Icons.picture_in_picture_alt_rounded,
                                defaultColor: iconColor,
                                defaultSize: isCompact ? 18 : 20,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // 5. Fullscreen Button
                      if (showFullscreen) ...[
                        SizedBox(width: isCompact ? 3.0 : 6.0),
                        AdaptiveFullscreenButton(
                          isFullScreen: isFullScreen,
                          styling: styling,
                          messages: messages,
                          onEnterFullscreen: onEnterFullscreen,
                          onExitFullscreen: onExitFullscreen,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
