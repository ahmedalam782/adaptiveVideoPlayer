import 'package:flutter/material.dart';
import '../../core/constants/player_events.dart';
import '../../core/constants/player_strings.dart';
import '../../core/widgets/adaptive_glassmorphic_container.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_circle_pill_button.dart';
import 'adaptive_duration_display.dart';
import 'adaptive_fullscreen_button.dart';
import 'adaptive_loop_toggle.dart';
import 'adaptive_next_episode_button.dart';
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

  /// Optional video/episode title for centered bottom bar display
  final String? title;

  /// Optional list of episodes
  final List<VideoEpisode>? episodes;

  /// Callback when Next Episode button is pressed
  final VoidCallback? onNextEpisode;

  /// Callback when Episodes button is pressed
  final VoidCallback? onEpisodesPressed;

  /// Optional audio tracks
  final List<AudioTrack>? audioTracks;

  /// Callback when Audio & Subtitles button is pressed
  final VoidCallback? onAudioSubtitlesPressed;

  /// Callback when Speed button is pressed
  final VoidCallback? onSpeedPressed;

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
    this.title,
    this.episodes,
    this.onNextEpisode,
    this.onEpisodesPressed,
    this.audioTracks,
    this.onAudioSubtitlesPressed,
    this.onSpeedPressed,
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
      styling?.controlsBackgroundColor ?? Colors.black.withValues(alpha: 0.40);

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
                    constraints.maxWidth > 650;

                final canShowVolume = effectiveVisibility.showVolumeButton &&
                    constraints.maxWidth > 520;
                final showTime = showTimestamp &&
                    effectiveVisibility.showTimeDisplay &&
                    !isLive;
                final inTopBar = effectiveVisibility.showActionsInTopBar;
                final showFullscreen = showFullscreenHere &&
                    effectiveVisibility.showFullscreenButton;
                final showSettings = !inTopBar && effectiveVisibility.showSettingsButton;
                final canShowMiniPlayer = !inTopBar &&
                    showMiniPlayerHere &&
                    effectiveVisibility.showMiniPlayerButton &&
                    onMiniPlayerPressed != null &&
                    !isFullScreen &&
                    constraints.maxWidth > 480;
                final showLoop = !inTopBar && effectiveVisibility.showLoopSetting;
                final showSubtitlesQuick = !inTopBar &&
                    effectiveVisibility.showCaptionsSetting;

                final canShowCenteredTitle = effectiveVisibility.showCenteredTitle &&
                    title != null &&
                    title!.isNotEmpty &&
                    constraints.maxWidth > 720;

                final canShowNextEpisode =
                    effectiveVisibility.showNextEpisodeButton &&
                    onNextEpisode != null &&
                    constraints.maxWidth > 450;

                final canShowEpisodes = !inTopBar &&
                    effectiveVisibility.showEpisodesButton &&
                    episodes != null &&
                    episodes!.isNotEmpty &&
                    onEpisodesPressed != null &&
                    constraints.maxWidth > 600;

                final canShowAudioSubtitles = !inTopBar &&
                    effectiveVisibility.showAudioSubtitlesButton &&
                    onAudioSubtitlesPressed != null &&
                    ((audioTracks != null && audioTracks!.isNotEmpty) ||
                        (subtitles != null && subtitles!.isNotEmpty)) &&
                    constraints.maxWidth > 620;

                final canShowSpeed = !inTopBar &&
                    effectiveVisibility.showSpeedButton &&
                    onSpeedPressed != null &&
                    constraints.maxWidth > 560;

                final hasRightActions = (isWide && (showLoop || showSubtitlesQuick)) ||
                    canShowNextEpisode ||
                    canShowEpisodes ||
                    canShowAudioSubtitles ||
                    canShowSpeed ||
                    showSettings ||
                    canShowMiniPlayer ||
                    showFullscreen;

                return Row(
                  children: [
                    // Left Controls (Natural sizing, no squished icons)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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

                        if (canShowSkip) ...[
                          const SizedBox(width: 6),
                          AdaptiveCirclePillButton(
                            backgroundColor: _pillColor,
                            playerIcon: styling?.icons.skipBackwardIcon,
                            icon: Icons.replay_10_rounded,
                            tooltip: messages?.skipBackwardText ??
                                PlayerStrings.seekBackward,
                            onTap: () => _seekRelative(-skipDuration),
                          ),
                          const SizedBox(width: 6),
                          AdaptiveCirclePillButton(
                            backgroundColor: _pillColor,
                            playerIcon: styling?.icons.skipForwardIcon,
                            icon: Icons.forward_10_rounded,
                            tooltip: messages?.skipForwardText ??
                                PlayerStrings.seekForward,
                            onTap: () => _seekRelative(skipDuration),
                          ),
                        ],

                        if (canShowVolume) ...[
                          SizedBox(width: isCompact ? 4 : 8),
                          // Glassmorphic Volume Pill
                          AdaptiveGlassmorphicContainer(
                            height: 38,
                            borderRadius: 24,
                            blur: 10,
                            color: _pillColor,
                            child: AdaptiveVolumeControl(
                              controller: controller,
                              styling: styling,
                              messages: messages,
                            ),
                          ),
                        ],

                        if (showTime) ...[
                          SizedBox(width: isCompact ? 4 : 8),
                          // Glassmorphic Time Pill
                          AdaptiveGlassmorphicContainer(
                            height: 38,
                            borderRadius: 24,
                            blur: 10,
                            color: _pillColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 10.0 : 14.0,
                            ),
                            alignment: Alignment.center,
                            child: AdaptiveDurationDisplay(
                              position: position,
                              duration: duration,
                              isWide: isWide,
                              styling: styling,
                              visibility: effectiveVisibility,
                              chapters: chapters,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (canShowCenteredTitle)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    if (hasRightActions) ...[
                      SizedBox(width: isCompact ? 4 : 6),

                      // Glassmorphic Right Action Pill
                      AdaptiveGlassmorphicContainer(
                        height: 38,
                        borderRadius: 24,
                        blur: 10,
                        color: _pillColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 6.0 : 8.0,
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
                            // Next Episode Button (>|)
                            if (canShowNextEpisode)
                              AdaptiveNextEpisodeButton(
                                onNextEpisode: onNextEpisode,
                                styling: styling,
                                messages: messages,
                              ),

                            // Episodes Drawer Button
                            if (canShowEpisodes) ...[
                              Tooltip(
                                message: messages?.episodesText ?? 'Episodes',
                                waitDuration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: onEpisodesPressed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                    child: Icon(
                                      Icons.video_library_outlined,
                                      color: styling?.iconColor ?? Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Dual-Column Audio & Subtitles Button
                            if (canShowAudioSubtitles) ...[
                              Tooltip(
                                message: messages?.audioAndSubtitlesText ?? 'Audio & Subtitles',
                                waitDuration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: onAudioSubtitlesPressed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                    child: Icon(
                                      Icons.subtitles_outlined,
                                      color: styling?.iconColor ?? Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Discrete Speed Stepper Button
                            if (canShowSpeed) ...[
                              Tooltip(
                                message: messages?.playbackSpeedText ?? 'Playback Speed',
                                waitDuration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: onSpeedPressed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                    child: Icon(
                                      Icons.speed_rounded,
                                      color: styling?.iconColor ?? Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
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
                            if (canShowMiniPlayer) ...[
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
                                          defaultColor: styling?.iconColor ?? Colors.white,
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
