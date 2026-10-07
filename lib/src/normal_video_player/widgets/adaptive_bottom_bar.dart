import 'package:flutter/material.dart';
import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_circle_pill_button.dart';
import 'adaptive_duration_display.dart';
import 'adaptive_fullscreen_button.dart';
import 'adaptive_loop_toggle.dart';
import 'adaptive_play_pause_button.dart';
import 'adaptive_settings_button.dart';
import 'adaptive_stop_button.dart';
import 'adaptive_subtitles_button.dart';
import 'adaptive_volume_control.dart';

/// Bottom bar for normal player with play/pause, volume, time, settings, and fullscreen.
///
/// Refactored following Clean Architecture, Single Responsibility (SRP),
/// and Dependency Injection / Inversion principles.
class AdaptiveBottomBar extends StatelessWidget {
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
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onMiniPlayerPressed;
  final bool showSkipButtons;
  final Duration skipDuration;

  /// When false, the timestamp stays off this row so it can sit with the end icons.
  final bool showTimestamp;

  /// When false, picture-in-picture stays off this row.
  final bool showMiniPlayerHere;

  /// When false, fullscreen stays off this row.
  final bool showFullscreenHere;

  const AdaptiveBottomBar({
    super.key,
    required this.controller,
    required this.isFullScreen,
    this.isLive = false,
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
    this.showTimestamp = true,
    this.showMiniPlayerHere = true,
    this.showFullscreenHere = true,
  });

  void _seekRelative(Duration delta) {
    final current = controller.value.position;
    final duration = controller.value.duration;
    var target = current + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
    onAnalyticsEvent?.call(PlayerEvents.videoSeek, {
      PlayerEvents.paramToPosition: target.inSeconds,
      'direction': delta.isNegative ? -10 : 10,
    });
  }

  Color get _pillColor =>
      styling?.controlsBackgroundColor ?? const Color(0x8C000000);

  @override
  Widget build(BuildContext context) {
    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;

    final effectiveVisibility = visibility ?? const PlayerVisibilityConfig();

    return Directionality(
      textDirection: textDirection,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;
          final isCompact = constraints.maxWidth < 460;
          final defaultStartEnd = isCompact ? 14.0 : 20.0;
          final defaultBottom = isCompact ? 8.0 : 12.0;
          final dynamicPadding = styling?.bottomBarPadding ??
              EdgeInsetsDirectional.fromSTEB(
                defaultStartEnd,
                4.0,
                defaultStartEnd,
                defaultBottom,
              );
          final dynamicMargin = styling?.bottomBarMargin;

          Widget barContent = Padding(
            padding: dynamicPadding,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, VideoPlayerValue value, child) {
                final isPlaying = value.isPlaying;
                final position = value.position;
                final duration = value.duration;
                final canShowSkip = showSkipButtons &&
                    effectiveVisibility.showSkipButtons &&
                    !isLive &&
                    !isCompact;

                final showVolume = effectiveVisibility.showVolumeButton;
                final showTime = showTimestamp &&
                    effectiveVisibility.showTimeDisplay &&
                    !isLive;
                final showFullscreen = showFullscreenHere &&
                    effectiveVisibility.showFullscreenButton;
                final showSettings = effectiveVisibility.showSettingsButton;
                final showMiniPlayer = showMiniPlayerHere &&
                    effectiveVisibility.showMiniPlayerButton &&
                    onMiniPlayerPressed != null &&
                    !isFullScreen;
                final showLoop = effectiveVisibility.showLoopSetting;
                final showSubtitlesQuick =
                    effectiveVisibility.showCaptionsSetting;

                return Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Flanking -10s, play/pause, and +10s buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canShowSkip)
                                    AdaptiveCirclePillButton(
                                      backgroundColor: _pillColor,
                                      playerIcon: styling?.icons.skipBackwardIcon,
                                      icon: Icons.replay_10_rounded,
                                      tooltip: messages?.skipBackwardText ??
                                          PlayerStrings.seekBackward,
                                      onTap: () => _seekRelative(-skipDuration),
                                    ),
                                  if (canShowSkip) const SizedBox(width: 6),

                                  // Central Play/Pause circular pill button
                                  AdaptivePlayPauseButton(
                                    controller: controller,
                                    isPlaying: isPlaying,
                                    styling: styling,
                                    messages: messages,
                                    onAnalyticsEvent: onAnalyticsEvent,
                                    pillColor: _pillColor,
                                  ),

                                  if (effectiveVisibility.showStopButton) ...[
                                    const SizedBox(width: 6),
                                    AdaptiveStopButton(
                                      controller: controller,
                                      styling: styling,
                                      tooltip: messages?.stopVideoText ?? PlayerStrings.stop,
                                      onAnalyticsEvent: onAnalyticsEvent,
                                      pillColor: _pillColor,
                                    ),
                                  ],

                                  if (canShowSkip) const SizedBox(width: 6),
                                  // Flanking +10s circular pill button
                                  if (canShowSkip)
                                    AdaptiveCirclePillButton(
                                      backgroundColor: _pillColor,
                                      playerIcon: styling?.icons.skipForwardIcon,
                                      icon: Icons.forward_10_rounded,
                                      tooltip: messages?.skipForwardText ??
                                          PlayerStrings.seekForward,
                                      onTap: () => _seekRelative(skipDuration),
                                    ),
                                ],
                              ),

                              if (showVolume) ...[
                                SizedBox(width: isCompact ? 4 : 8),
                                // YouTube-style Volume Pill
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _pillColor,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: AdaptiveVolumeControl(
                                    controller: controller,
                                    styling: styling,
                                    messages: messages,
                                  ),
                                ),
                              ],

                              if (showTime) ...[
                                SizedBox(width: isCompact ? 4 : 8),
                                Container(
                                  height: 38,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 8.0 : 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _pillColor,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    widthFactor: 1.0,
                                    child: AdaptiveDurationDisplay(
                                      position: position,
                                      duration: duration,
                                      isWide: !isCompact,
                                      styling: styling,
                                      visibility: effectiveVisibility,
                                      chapters: chapters,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((isWide && (showLoop || showSubtitlesQuick)) ||
                        showSettings ||
                        showMiniPlayer ||
                        showFullscreen) ...[
                      SizedBox(width: isCompact ? 4 : 6),

                      // YouTube-style Right Action Pill (Loop/Autoplay, CC, Settings, MiniPlayer, Fullscreen)
                      Container(
                        height: 38,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 4.0 : 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: _pillColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isWide) ...[
                              if (showLoop) ...[
                                AdaptiveLoopToggle(
                                  controller: controller,
                                  isLooping: value.isLooping,
                                  styling: styling,
                                  messages: messages,
                                ),
                                const SizedBox(width: 2),
                              ],
                              if (showSubtitlesQuick) ...[
                                AdaptiveSubtitlesButton(
                                  subtitles: subtitles,
                                  currentSubtitleTrack: currentSubtitleTrack,
                                  onSubtitleSelected: onSubtitleSelected,
                                  onSettingsPressed: onSettingsPressed,
                                  styling: styling,
                                  messages: messages,
                                ),
                                const SizedBox(width: 2),
                              ],
                            ],
                            if (showSettings)
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
                            if (showMiniPlayer) ...[
                              SizedBox(width: isCompact ? 4 : 8),
                              Tooltip(
                                message: messages?.miniPlayerText ?? PlayerStrings.miniPlayer,
                                waitDuration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: onMiniPlayerPressed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 4.0,
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        return PlayerIcon.resolve(
                                          context,
                                          icon: styling?.icons.miniPlayerIcon,
                                          fallbackIcon:
                                              Icons.picture_in_picture_alt_rounded,
                                          defaultColor:
                                              styling?.iconColor ?? Colors.white,
                                          defaultSize: 19,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (showFullscreen) ...[
                              SizedBox(width: isCompact ? 4 : 8),
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
                      ),
                    ],
                  ],
                );
              },
            ),
          );

          if (dynamicMargin != null) {
            barContent = Padding(
              padding: dynamicMargin,
              child: barContent,
            );
          }

          return barContent;
        },
      ),
    );
  }
}
