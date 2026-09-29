import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_fullscreen_button.dart';
import 'adaptive_settings_button.dart';
import 'adaptive_volume_control.dart';

/// Bottom bar for normal player with play/pause, volume, time, settings, and fullscreen.
class AdaptiveBottomBar extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isLive;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
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

  const AdaptiveBottomBar({
    super.key,
    required this.controller,
    required this.isFullScreen,
    this.isLive = false,
    this.styling,
    this.messages,
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
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _seekRelative(Duration delta) {
    final current = controller.value.position;
    final duration = controller.value.duration;
    var target = current + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
    onAnalyticsEvent?.call('video_seek', {
      'to_position': target.inSeconds,
      'direction': delta.isNegative ? -10 : 10,
    });
  }

  static const Color _pillColor = Color(0x8C000000);

  Widget _buildCirclePillButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
    double size = 20,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: _pillColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: Icon(
                icon,
                color: color ?? styling?.iconColor ?? Colors.white,
                size: size,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(bool isPlaying) {
    return _buildCirclePillButton(
      icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
      tooltip: isPlaying ? 'Pause' : 'Play',
      size: 22,
      onTap: () {
        if (isPlaying) {
          controller.pause();
          onAnalyticsEvent?.call('video_paused',
              {'position': controller.value.position.inSeconds});
        } else {
          controller.play();
          onAnalyticsEvent?.call('video_played',
              {'position': controller.value.position.inSeconds});
        }
      },
    );
  }

  Widget _buildDurationText(
    Duration position,
    Duration duration, {
    required bool isWide,
  }) {
    final style = styling?.timeTextStyle ??
        styling?.settingItemTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        );

    final textColor = styling?.textColor ?? Colors.white;
    final activeChapter = VideoChapter.findChapterAt(chapters, position);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(position),
          style: style.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' / ',
          style: style.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        Text(
          _formatDuration(duration),
          style: style.copyWith(
            color: textColor.withValues(alpha: 0.9),
          ),
        ),
        if (isWide && activeChapter != null) ...[
          Text(
            '  •  ',
            style: style.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              activeChapter.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoopToggle(VideoPlayerValue value) {
    final isLooping = value.isLooping;
    return Tooltip(
      message: messages?.loopVideoText ?? 'Loop Video',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.setLooping(!isLooping);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          child: Container(
            width: 30,
            height: 16,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isLooping
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: isLooping
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLooping ? Icons.repeat_rounded : Icons.pause_rounded,
                size: 9,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitlesQuickButton() {
    final hasSubtitles = subtitles != null && subtitles!.isNotEmpty;
    final isSubtitlesActive = currentSubtitleTrack != null;

    return Tooltip(
      message: messages?.subtitlesText ?? 'Subtitles / CC',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasSubtitles
            ? () {
                if (isSubtitlesActive) {
                  onSubtitleSelected?.call(null);
                } else {
                  onSubtitleSelected?.call(subtitles!.first);
                }
              }
            : onSettingsPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.subtitles_outlined,
                color: (styling?.iconColor ?? Colors.white)
                    .withValues(alpha: hasSubtitles ? 1.0 : 0.45),
                size: 19,
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSubtitlesActive ? 14 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: styling?.progressBarPlayedColor ??
                      const Color(0xFFFF0033),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;

          return Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 10.0),
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, VideoPlayerValue value, child) {
                final isPlaying = value.isPlaying;
                final position = value.position;
                final duration = value.duration;
                final canShowSkip = showSkipButtons && !isLive;

                return Row(
                children: [
                  // Flanking -10s circular pill button
                  if (canShowSkip)
                    _buildCirclePillButton(
                      icon: Icons.replay_10_rounded,
                      tooltip: messages?.skipBackwardText ?? 'Rewind 10s',
                      onTap: () => _seekRelative(-skipDuration),
                    ),
                  if (canShowSkip) const SizedBox(width: 6),

                  // Central Play/Pause circular pill button
                  _buildPlayPauseButton(isPlaying),

                  if (canShowSkip) const SizedBox(width: 6),
                  // Flanking +10s circular pill button
                  if (canShowSkip)
                    _buildCirclePillButton(
                      icon: Icons.forward_10_rounded,
                      tooltip: messages?.skipForwardText ?? 'Forward 10s',
                      onTap: () => _seekRelative(skipDuration),
                    ),

                  const SizedBox(width: 8),

                  // YouTube-style Volume Pill (Speaker + White Slider)
                  Container(
                    height: 38,
                    padding:
                        EdgeInsets.symmetric(horizontal: isWide ? 10.0 : 4.0),
                    decoration: BoxDecoration(
                      color: _pillColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AdaptiveVolumeControl(
                      controller: controller,
                      styling: styling,
                      alwaysShowSlider: isWide,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // YouTube-style Time Display Pill (0:00 / 1:22 • Chapter)
                  if (!isLive)
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: _pillColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: _buildDurationText(
                        position,
                        duration,
                        isWide: isWide,
                      ),
                    ),

                  const Spacer(),

                  // YouTube-style Right Action Pill (Loop/Autoplay, CC, Settings, MiniPlayer, Fullscreen)
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: _pillColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isWide) ...[
                          _buildLoopToggle(value),
                          const SizedBox(width: 2),
                          _buildSubtitlesQuickButton(),
                          const SizedBox(width: 2),
                        ],
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
                        if (onMiniPlayerPressed != null &&
                            !isFullScreen &&
                            !isLive) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Miniplayer',
                            waitDuration: const Duration(milliseconds: 500),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onMiniPlayerPressed,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 4.0,
                                ),
                                child: Icon(
                                  Icons.picture_in_picture_alt_rounded,
                                  color: styling?.iconColor ?? Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        AdaptiveFullscreenButton(
                          isFullScreen: isFullScreen,
                          styling: styling,
                          onEnterFullscreen: onEnterFullscreen,
                          onExitFullscreen: onExitFullscreen,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      ),
    );
  }
}
